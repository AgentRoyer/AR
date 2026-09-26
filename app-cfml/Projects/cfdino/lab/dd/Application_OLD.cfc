component {
    this.name = "CFdinoDinoDetective";
    this.applicationTimeout = createTimeSpan(0, 0, 0, 0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 2, 0, 0);
    this.setClientCookies = true;

    if (cgi.http_host contains "cfdino.com") {
        this.env = "prod";
    } else {
        this.env = "dev";
    }

    // Domain cookies only make sense on the real domain. On the dev tunnel
    // (*.app.github.dev) the computed domain (.github.dev) is a public suffix,
    // browsers reject the CFID/CFTOKEN cookies and every request starts a new
    // session (session.dinoActuel lost between identify and chat requests).
    this.setDomainCookies = (this.env EQ "prod");

    // --- Configuration AI (Lucee 7) ---
    local.envVars = chargerDotEnv(expandPath("/.env"));

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

    this.CurrentAgent = "groq";
    this.CurrentVisionAgent = "claude";
    this.dinoDetectiveConnection = lCase(this.CurrentAgent);
    this.dinoDetectiveVisionConnection = lCase(this.CurrentVisionAgent);

    this.onApplicationStart = function() {
        application.env = this.env;
        application.dinoDetectiveClaudeApiKey = this.dinoDetectiveClaudeApiKey;
        application.dinoDetectiveClaudeModel = this.dinoDetectiveClaudeModel;
        application.CurrentAgent = lCase(this.CurrentAgent);
        application.dinoDetectiveConnection = this.dinoDetectiveConnection;
        application.CurrentVisionAgent = lCase(this.CurrentVisionAgent);
        application.dinoDetectiveVisionConnection = this.dinoDetectiveVisionConnection;

        if (application.env EQ "prod") {
            application.root = "https://cfdino.com";
        } else {
            application.root = "https://fictional-acorn-9qg4vvrvjphx7rv-8888.app.github.dev";
        }

        return true;
    };

    this.onRequestStart = function(targetPage) {
        var requestedLanguage = structKeyExists(url, "lang") ? lCase(trim(url.lang)) : "";
        var cookieLanguage = structKeyExists(cookie, "lang") ? lCase(trim(cookie.lang)) : "";
        var resolvedLanguage = "en";

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

        return true;
    };

    private struct function chargerDotEnv(required string chemin) {
        var resultat = {};

        if (!fileExists(arguments.chemin)) {
            return resultat;
        }

        var contenu = fileRead(arguments.chemin);
        var lignes = listToArray(contenu, chr(10));

        for (var ligneBrute in lignes) {
            var ligne = trim(ligneBrute);

            if (len(ligne) EQ 0 OR left(ligne, 1) EQ "##") {
                continue;
            }

            if (find("=", ligne)) {
                var cle = trim(listFirst(ligne, "="));
                var valeur = trim(listRest(ligne, "="));
                if (len(valeur) GTE 2) {
                    if ((left(valeur, 1) EQ '"' AND right(valeur, 1) EQ '"')
                        OR (left(valeur, 1) EQ "'" AND right(valeur, 1) EQ "'")) {
                        valeur = mid(valeur, 2, len(valeur) - 2);
                    }
                }
                resultat[cle] = valeur;
            }
        }

        return resultat;
    }
}