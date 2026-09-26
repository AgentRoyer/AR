/**
 * DinoAgent.cfc
 * Harness Dino Detective aligné sur l'API réelle de Lucee 7 :
 * - createAISession(name:...) référence la connexion définie dans Application.cfc (this.ai)
 * - inquiryAISession() envoie texte et/ou fichier (image, PDF...)
 * - serializeAISession()/loadAISession() permettent de faire persister l'historique
 *   d'une requête HTTP à l'autre (le CFC lui-même reste sans état).
 */
component accessors="true" {

    property name="aiConnectionName";

    public DinoAgent function init(string connexion = "") {
        // Sans argument, le moteur utilisé est celui piloté par application.dinoDetectiveConnection
        // (dérivé de this.CurrentAgent dans Application.cfc) — doit correspondre à un nom défini dans this.ai.
        variables.aiConnectionName = len(arguments.connexion) ? arguments.connexion : application.dinoDetectiveConnection;
        return this;
    }

    /**
     * Identifie un dinosaure à partir d'une image.
     * Pas de responseSchema natif confirmé pour Claude : on impose le JSON par prompt,
     * puis on parse nous-mêmes (avec nettoyage défensif des ```json``` éventuels).
     */
    public struct function identifierImage(required string cheminImage, string lang = "en") {
        var aiSession = "";
        var reponseBrute = "";
        var resultat = {};
        var responseLanguage = lCase(arguments.lang) EQ "fr" ? "French" : "English";
        var nonIdentifiedLabel = lCase(arguments.lang) EQ "fr" ? "Non identifié" : "Non identified";

        try {
            var prompt = "Identify this dinosaur, fossil, toy, or dinosaur footprint. " &
                "Respond STRICTLY with a JSON object, with no text before or after it and no markdown, " &
                "using this exact format: " &
                '{"espece":"...", "periode":"...", "regime_alimentaire":"...", "taille_estimee":"...", ' &
                '"confiance":"haute|moyenne|basse", "anecdote":"..."}. ' &
                "Use #responseLanguage# for all values. If it is not a dinosaur, use '#nonIdentifiedLabel#' for 'espece' and explain why in 'anecdote'.";

            reponseBrute = analyserImageClaude(prompt, arguments.cheminImage, arguments.lang);

            // Sécurité : si jamais une réponse multipart (array) arrivait, on récupère la partie texte
            if (isArray(reponseBrute)) {
                for (var part in reponseBrute) {
                    if (structKeyExists(part, "content") AND (!structKeyExists(part, "contenttype") OR left(part.contenttype, 4) EQ "text")) {
                        reponseBrute = part.content;
                        break;
                    }
                }
            }

            resultat = parserJSONDefensif(reponseBrute);
            resultat["succes"] = true;

            // Validation légère du champ confiance pour ne pas casser l'affichage
            if (!structKeyExists(resultat, "confiance") OR NOT arrayFindNoCase(["haute", "moyenne", "basse"], resultat.confiance)) {
                resultat["confiance"] = "basse";
            }

        } catch (any e) {
            resultat = {
                "succes": false,
                "erreur": "Impossible d'analyser l'image : #e.message#"
            };
        }

        return resultat;
    }

    /**
     * Envoie un message à l'agent en conservant l'historique de conversation
     * via un état sérialisé (à stocker/récupérer côté appelant, ex: session CFML).
     * Le contexte du spécimen est réinjecté dans le systemMessage à CHAQUE appel :
     * - à la création de la session (systemMessage natif)
     * - ET en préfixe du 1er message (filet de sécurité pour les providers qui
     *   ne mélangeraient pas le system au contexte de conversation)
     * - ET à chaque reprise de session (loadAISession ne garantit pas que le
     *   systemMessage a survécu à la sérialisation/réhydratation).
     *
     * @serializedState  état renvoyé par un appel précédent (chaîne vide au 1er message)
     * @dinoActuel       fiche du dinosaure identifié, pour contextualiser la réponse
     */
    public struct function discuter(required string message, string serializedState = "", struct dinoActuel = {}, string lang = "en") {
        var aiSession = "";
        var reponse = "";
        var systemMessage = "";
        var contexte = "";
        var messageEffectif = arguments.message;
        var responseLanguage = lCase(arguments.lang) EQ "fr" ? "French" : "English";

        try {
            // Contexte spécimen : calculé une fois, réinjecté à chaque appel
            if (!structIsEmpty(arguments.dinoActuel)) {
                contexte = construireContexteDino(arguments.dinoActuel);
            }

            if (len(trim(arguments.serializedState))) {
                // Reprise d'une conversation existante (historique conservé par Lucee)
                aiSession = loadAISession(name = variables.aiConnectionName, data = arguments.serializedState);

                // loadAISession ne garantit pas la survie du systemMessage d'origine :
                // on re-précise le contexte à chaque relance pour éviter le "which creature?"
                if (len(contexte)) {
                    messageEffectif = "(Reminder of context: " & contexte & ")\n\n" & arguments.message;
                }
            } else {
                // Nouvelle conversation : systemMessage + préfixe de contexte au 1er message
                systemMessage = "You are a playful, precise paleontology assistant. Respond concisely in #responseLanguage#.";
                if (len(contexte)) {
                    systemMessage &= " " & contexte;
                }

                aiSession = createAISession(
                    name = variables.aiConnectionName,
                    systemMessage = systemMessage
                );

                if (len(contexte)) {
                    messageEffectif = "(" & contexte & ")\n\n" & arguments.message;
                }
            }

            reponse = inquiryAISession(aiSession, messageEffectif);

            if (isArray(reponse)) {
                for (var part in reponse) {
                    if (structKeyExists(part, "content")) {
                        reponse = part.content;
                        break;
                    }
                }
            }

            return {
                "succes": true,
                "texte": reponse,
                "serializedState": serializeAISession(aiSession)
            };

        } catch (any e) {
            return {
                "succes": false,
                "texte": "",
                "serializedState": arguments.serializedState
            };
        }
    }

    /**
     * Construit une phrase de contexte en langage naturel à partir de la fiche
     * du spécimen identifié par Claude, pour orienter la conversation.
     */
    private string function construireContexteDino(required struct dino) {
        var parties = [];
        var contexte = "";

        if (structKeyExists(arguments.dino, "espece") AND len(trim(arguments.dino.espece)) AND !arrayFindNoCase(["Non identified", "Non identifié"], arguments.dino.espece)) {
            contexte = "The user is asking about a specimen identified as " & arguments.dino.espece & ".";
        } else {
            contexte = "The user uploaded a specimen that could not be identified as a dinosaur.";
        }

        if (structKeyExists(arguments.dino, "periode") AND len(trim(arguments.dino.periode))) {
            arrayAppend(parties, "period: " & arguments.dino.periode);
        }
        if (structKeyExists(arguments.dino, "regime_alimentaire") AND len(trim(arguments.dino.regime_alimentaire))) {
            arrayAppend(parties, "diet: " & arguments.dino.regime_alimentaire);
        }
        if (structKeyExists(arguments.dino, "taille_estimee") AND len(trim(arguments.dino.taille_estimee))) {
            arrayAppend(parties, "estimated size: " & arguments.dino.taille_estimee);
        }
        if (structKeyExists(arguments.dino, "confiance") AND len(trim(arguments.dino.confiance))) {
            arrayAppend(parties, "identification confidence: " & arguments.dino.confiance);
        }
        if (structKeyExists(arguments.dino, "anecdote") AND len(trim(arguments.dino.anecdote))) {
            arrayAppend(parties, "fun fact: " & arguments.dino.anecdote);
        }

        if (arrayLen(parties)) {
            contexte &= " Known facts (" & arrayToList(parties, "; ") & ").";
        }

        return contexte & " Keep the conversation focused on this specimen.";
    }

    /**
     * Parse une réponse censée être du JSON pur, en nettoyant les artefacts
     * courants (balises ```json ... ``` que certains modèles ajoutent parfois
     * malgré la consigne).
     */
    private struct function parserJSONDefensif(required string texte) {
        var nettoye = trim(arguments.texte);

        if (left(nettoye, 3) EQ "```") {
            nettoye = reReplace(nettoye, "^```[a-zA-Z]*", "");
            nettoye = reReplace(nettoye, "```$", "");
            nettoye = trim(nettoye);
        }

        return deserializeJSON(nettoye);
    }

    private string function analyserImageClaude(required string prompt, required string cheminImage, string lang = "en") {
        var extension = lCase(listLast(arguments.cheminImage, "."));
        var mediaTypes = {
            "jpg" = "image/jpeg",
            "jpeg" = "image/jpeg",
            "png" = "image/png",
            "webp" = "image/webp"
        };
        var mediaType = structKeyExists(mediaTypes, extension) ? mediaTypes[extension] : "";
        var requestBody = {};
        var httpResponse = {};
        var responseBody = {};

        if (!len(application.dinoDetectiveClaudeApiKey)) {
            throw(message = "The Claude API key is not configured.", type = "DinoDetective.Configuration");
        }

        if (!len(mediaType)) {
            throw(message = "Unsupported image type.", type = "DinoDetective.Validation");
        }

        requestBody = {
            "model" = application.dinoDetectiveClaudeModel,
            "max_tokens" = 1024,
            "system" = "You are an educational paleontologist who responds exclusively in " & (lCase(arguments.lang) EQ "fr" ? "French" : "English") & ".",
            "messages" = [
                {
                    "role" = "user",
                    "content" = [
                        {
                            "type" = "image",
                            "source" = {
                                "type" = "base64",
                                "media_type" = mediaType,
                                "data" = toBase64(fileReadBinary(arguments.cheminImage))
                            }
                        },
                        {
                            "type" = "text",
                            "text" = arguments.prompt
                        }
                    ]
                }
            ]
        };

        cfhttp(
            url = "https://api.anthropic.com/v1/messages",
            method = "post",
            result = "httpResponse",
            timeout = 60
        ) {
            cfhttpparam(type = "header", name = "x-api-key", value = application.dinoDetectiveClaudeApiKey);
            cfhttpparam(type = "header", name = "anthropic-version", value = "2023-06-01");
            cfhttpparam(type = "header", name = "content-type", value = "application/json");
            cfhttpparam(type = "body", value = serializeJSON(requestBody));
        }

        responseBody = deserializeJSON(httpResponse.fileContent);

        if (left(httpResponse.statusCode, 3) NEQ "200") {
            throw(message = structKeyExists(responseBody, "error") ? responseBody.error.message : "Claude image request failed.", type = "DinoDetective.Claude");
        }

        return responseBody.content[1].text;
    }
}
