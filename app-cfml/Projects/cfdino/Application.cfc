component {
    // --- Configuration de base de l'application ---
    this.name = "CFdino";  // Nom unique pour ton application (à adapter)
    this.applicationTimeout = createTimeSpan(0, 0, 0, 0);   // 0 en DEV
    this.sessionManagement = true;  // Active la gestion des sessions
    this.sessionTimeout = createTimeSpan(0, 2, 0, 0);     // 2 h : Dino Detective garde le dino identifié en session
    this.setClientCookies = true;  // Autorise les cookies pour les sessions

    // --- Dossier de l'application (le site tourne sous /cfdino/, pas à la racine du serveur) ---
    local.appDir = getDirectoryFromPath(getCurrentTemplatePath());

    // Les chemins "absolus" du code (/app/..., /lab/...) pointent vers le dossier cfdino.
    this.mappings["/app"] = local.appDir & "app";
    this.mappings["/lab"] = local.appDir & "lab";

    local.hostName = lCase(listFirst(cgi.http_host, ":"));

    if (listFindNoCase("cfdino.com,www.cfdino.com,cfdino.fr,www.cfdino.fr", local.hostName)) {
        this.env = "prod";
    } else {
        this.env = "dev";
    }

    // Cookies de domaine uniquement sur le vrai domaine. Sur le tunnel dev
    // (*.app.github.dev) le domaine calculé (.github.dev) est un suffixe public :
    // le navigateur rejette CFID/CFTOKEN et chaque requête démarre une nouvelle
    // session (session.dinoActuel perdu entre l'identification et le chat).
    this.setDomainCookies = (this.env EQ "prod");

    // --- Secrets : .env unique à la racine du codespace (/workspaces/AR/.env),
    // injecté dans le conteneur par docker-compose (env_file) -> variables d'environnement.
    local.envVars = server.system.environment;

    // --- Configuration AI (Lucee 7) — Dino Detective (/lab/dd/) ---
    local.claudeApiKey = structKeyExists(local.envVars, "CLAUDE_API_KEY_CFC") ? local.envVars["CLAUDE_API_KEY_CFC"] : "";
    local.geminiApiKey = structKeyExists(local.envVars, "GEMINI_API_KEY_CFC") ? local.envVars["GEMINI_API_KEY_CFC"] : "";
    local.groqApiKey = structKeyExists(local.envVars, "GROQ_API_KEY_CFC") ? local.envVars["GROQ_API_KEY_CFC"] : "";
    this.dinoDetectiveClaudeApiKey = local.claudeApiKey;
    this.dinoDetectiveClaudeModel = "claude-haiku-4-5-20251001";

    this.ai = {
        "claude" = {
            class: "lucee.runtime.ai.anthropic.ClaudeEngine",
            custom: {
                apikey: local.claudeApiKey,
                model: this.dinoDetectiveClaudeModel,
                message: "You are a friendly paleontology assistant who responds concisely in English."
            }
        },
        "gemini" = {
            class: "lucee.runtime.ai.google.GeminiEngine",
            custom: {
                apikey: local.geminiApiKey,
                model: "gemini-2.5-flash",
                message: "You are a friendly paleontology assistant who responds concisely in English."
            }
        },
        "groq" = {
            class: "lucee.runtime.ai.openai.OpenAIEngine",
            custom: {
                secretKey: local.groqApiKey,
                model: "openai/gpt-oss-120b",
                url: "https://api.groq.com/openai/v1/",
                message: "You are a friendly paleontology assistant who responds concisely in English."
            }
        }
    };

    this.CurrentAgent = "groq";           // moteur du chat
    this.CurrentVisionAgent = "claude";   // moteur de l'identification (doit gérer les images)
    this.dinoDetectiveConnection = lCase(this.CurrentAgent);
    this.dinoDetectiveVisionConnection = lCase(this.CurrentVisionAgent);

    // --- Gestion de l'URL racine et de l'environnement ---
    this.onApplicationStart = function() {
        application.env = this.env;
        application.dinoDetectiveClaudeApiKey = this.dinoDetectiveClaudeApiKey;
        application.dinoDetectiveClaudeModel = this.dinoDetectiveClaudeModel;
        application.CurrentAgent = lCase(this.CurrentAgent);
        application.dinoDetectiveConnection = this.dinoDetectiveConnection;
        application.CurrentVisionAgent = lCase(this.CurrentVisionAgent);
        application.dinoDetectiveVisionConnection = this.dinoDetectiveVisionConnection;

        if (this.env EQ "prod") {
            application.root = "https://cfdino.com";
            application.env="prod";
        } else {
            application.root = "https://literate-bassoon-xrr7x4qwqqv4hq4-8001.app.github.dev/cfdino";  // sans slash final : le code ajoute "/css/...", "/img/..."
            application.env="dev";
        }

        return true;
    };

    /* Datasources désactivées (pas de base MySQL dans ce stack Docker pour l'instant)
    // --- Configuration des datasources (bases de données) ---
    if (this.env EQ "prod") {
        this.datasources = {
            "cfdinoco_test" = {
                type = "MySQL",
                host = "mysql.9planethosting.com",
                port = 3306,
                database = "cfdinoco_test",
                username = "cfdinoco_test",
                password = structKeyExists(local.envVars, "CFDINOCO_TEST_PROD") ? local.envVars["CFDINOCO_TEST_PROD"] : "",
                connectionLimit = 10,
                connectionTimeout = 30,
                useUnicode = true,
                characterEncoding = "UTF-8"
            }
        };

    } else {
        this.datasources = {
            "cfdinoco_test" = {
                type = "MySQL",
                host = "db",
                port = 3306,
                database = "cfdino",
                username = "root",
                password = structKeyExists(local.envVars, "CFDINOCO_TEST_DEV") ? local.envVars["CFDINOCO_TEST_DEV"] : "",
                connectionLimit = 10,
                connectionTimeout = 30,
                useUnicode = true,
                characterEncoding = "UTF-8"
            }
        };
    }
    */

    // Serveur SMTP : mot de passe = CFDINOMAILSENDER dans le .env de la racine du codespace
    this.mailservers = [
        {
            server: "mail.cfdino.com",
            port: 587,
            username: "site@cfdino.com",
            password: structKeyExists(local.envVars, "CFDINOMAILSENDER") ? local.envVars["CFDINOMAILSENDER"] : "",
            useSSL: false,
            useTLS: true
        }
    ];

    // --- Gestion des erreurs ---
    this.onMissingTemplate = function(target) {
        request.errorStatusCode = 404;
        request.errorTarget = arguments.target;
        include "error.cfm";
        return true;
    };

    this.onRequestStart = function(targetPage) {
        var hostName = lCase(listFirst(cgi.http_host, ":"));
        var requestedLanguage = structKeyExists(url, "lang") ? lCase(trim(url.lang)) : "";
        var cookieLanguage = structKeyExists(cookie, "lang") ? lCase(trim(cookie.lang)) : "";
        var resolvedLanguage = "en";

        if (this.env EQ "prod" AND listFindNoCase("cfdino.fr,www.cfdino.fr", hostName)) {
            location(url = "https://cfdino.com/?lang=fr", addToken = false, statusCode = 301);
        }

        if (listFindNoCase("en,fr", requestedLanguage)) {
            resolvedLanguage = requestedLanguage;
        } else if (listFindNoCase("en,fr", cookieLanguage)) {
            resolvedLanguage = cookieLanguage;
        } else if (structKeyExists(session, "lang") AND listFindNoCase("en,fr", session.lang)) {
            resolvedLanguage = session.lang;
        }

        session.lang = resolvedLanguage;

        if (listFindNoCase("en,fr", requestedLanguage) OR !listFindNoCase("en,fr", cookieLanguage)) {
            cookie name = "lang" value = resolvedLanguage expires = 90 path = "/";
        }

        // Déclare le mode debug si demandé via l'URL.
        if (structKeyExists(url, "deb")) {
            request.debugMode = true;
        }
    };

    this.onRequest = function(targetPage) {
        // Inclure le template demandé
        include targetPage;
    };

    this.onRequestEnd = function() {
        // Code exécuté à la fin de chaque requête
    };

    this.onSessionStart = function() {
        // Session conservée seulement si elle est ensuite réellement utilisée.
    };

    this.onSessionEnd = function(sessionScope, appScope) {
        // Nettoyer les variables de session si nécessaire.
    };

    this.onError = function(any exception, string eventName) {
        request.errorStatusCode = 500;
        request.errorException = arguments.exception;
        request.errorEventName = arguments.eventName;
        include "error.cfm";
        abort;
    };

}
