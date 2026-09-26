<cfscript>
    // Chatbot COLDFINA — même API que RUSTINA / PYTHONA / GONA
    //   GET  chatbot.cfm?method=identity        -> identité + couleur
    //   GET  chatbot.cfm?method=health          -> état + couleur
    //   POST chatbot.cfm?method=chat {messages}  -> {message} (interface web)
    //   POST chatbot.cfm {"message": "..."}      -> {bot, user_input, response, identity, color}
    //   GET  chatbot.cfm?message=...             -> idem
    chatbotName = "COLDFINA";
    chatbotVersion = "1.0.0";
    botColor = "blue"; // Eau
    systemPrompt = "You are COLDFINA, a helpful AI chatbot powered by Groq under CFML. You know your name and identity. When asked who you are or what your name is, answer clearly and confidently.";
    groqUrl = "https://api.groq.com/openai/v1/chat/completions";
    groqModel = "openai/gpt-oss-20b";

    function sendJSON(required struct data, numeric status = 200) {
        cfheader(statuscode = arguments.status);
        cfcontent(type = "application/json; charset=utf-8", reset = true);
        writeOutput(serializeJSON(arguments.data));
        abort;
    }

    function groqComplete(required array messages) {
        // Clé fournie par le .env de la racine du codespace (docker-compose env_file)
        var apiKey = trim(server.system.environment["GROQ_API_KEY_CFC"] ?: "");
        if (!len(apiKey)) {
            throw(type = "Groq", message = "GROQ_API_KEY_CFC est manquante sur le serveur.");
        }
        // Identité : le prompt système précède toujours la conversation
        var allMessages = [{"role": "system", "content": systemPrompt}];
        allMessages.append(arguments.messages, true);
        var res = {};
        cfhttp(url = groqUrl, method = "post", result = "res", timeout = 60, charset = "utf-8") {
            cfhttpparam(type = "header", name = "Authorization", value = "Bearer " & apiKey);
            cfhttpparam(type = "header", name = "Content-Type", value = "application/json");
            cfhttpparam(type = "body", value = serializeJSON({"model": groqModel, "messages": allMessages, "temperature": 0.7}));
        }
        if (!structKeyExists(res, "status_code") OR res.status_code EQ 0) {
            throw(type = "Groq", message = "Impossible de joindre Groq : " & (res.errorDetail ?: ""));
        }
        if (res.status_code LT 200 OR res.status_code GT 299) {
            throw(type = "Groq", message = "Groq a renvoyé le statut " & res.statusCode & ".");
        }
        var data = deserializeJSON(res.fileContent);
        if (!structKeyExists(data, "choices") OR !arrayLen(data.choices)) {
            throw(type = "Groq", message = "Groq n’a renvoyé aucun message.");
        }
        return {"role": data.choices[1].message.role, "content": data.choices[1].message.content};
    }

    method = url.method ?: "";

    if (method EQ "identity") {
        sendJSON({"name": chatbotName, "system_prompt": systemPrompt, "version": chatbotVersion, "color": botColor, "knows_identity": true});
    }
    if (method EQ "health") {
        sendJSON({"status": "healthy", "bot": chatbotName, "color": botColor, "identity_aware": true});
    }

    // Corps JSON éventuel (POST)
    rawBody = getHttpRequestData().content;
    rawBody = isBinary(rawBody) ? charsetEncode(rawBody, "utf-8") : rawBody;
    payload = (len(trim(rawBody)) AND isJSON(rawBody)) ? deserializeJSON(rawBody) : {};

    try {
        // Interface web : historique complet
        if (method EQ "chat") {
            if (!isStruct(payload) OR !structKeyExists(payload, "messages") OR !isArray(payload.messages)) {
                sendJSON({"error": "JSON invalide : champ messages attendu"}, 400);
            }
            sendJSON({"message": groqComplete(payload.messages)});
        }

        // API commune : un seul message
        userMessage = "";
        if (isStruct(payload) AND structKeyExists(payload, "message")) {
            userMessage = payload.message;
        } else if (structKeyExists(form, "message")) {
            userMessage = form.message;
        } else if (structKeyExists(url, "message")) {
            userMessage = url.message;
        } else {
            sendJSON({"bot": chatbotName, "message": "Use POST or GET to send messages to chatbot", "color": botColor, "system_prompt": systemPrompt});
        }

        reply = groqComplete([{"role": "user", "content": userMessage}]);
        sendJSON({"bot": chatbotName, "user_input": userMessage, "response": reply.content, "identity": chatbotName, "color": botColor});
    } catch (Groq e) {
        sendJSON({"bot": chatbotName, "error": e.message, "color": botColor}, 502);
    }
</cfscript>
