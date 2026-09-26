<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Test config AI - DinoDetective</title>
    <style>
        body { font-family: monospace; max-width: 800px; margin: 2em auto; padding: 0 1em; }
        .ok { color: ##0066CC; font-weight: bold; }
        .ko { color: red; font-weight: bold; }
        section { border: 1px solid ##ccc; border-radius: 8px; padding: 1em; margin-bottom: 1em; }
        h1 { font-size: 1.4em; }
        h2 { font-size: 1.1em; margin-top: 0; }
        pre { background: ##f5f5f5; padding: 1em; overflow-x: auto; }
    </style>
</head>
<body>
<cfoutput>
<h1>🦕 AI configuration test (#application.CurrentAgent# → #application.dinoDetectiveConnection#)</h1>

<!--- Test 1: environment variable for the active engine API key --->
<!--- Clés lues uniquement depuis le .env de la racine du codespace (docker-compose env_file) --->
<cfset envVarName = uCase(application.CurrentAgent) & "_API_KEY_CFC">
<section>
    <h2>1. Environment variable #envVarName#</h2>
    <cfif structKeyExists(server.system.environment, envVarName)>
        <cfset cle = server.system.environment[envVarName]>
        <p class="ok">✔ #envVarName# is set (length: #len(cle)# characters,
        starts with: #left(cle, 7)#...)</p>
    <cfelse>
        <p class="ko">✖ #envVarName# is not in server.system.environment</p>
        <p>→ Add <code>#envVarName#</code> to /workspaces/AR/.env, then <code>docker compose up -d app-cfml</code>.</p>
    </cfif>
</section>

<!--- Test 2: AI session creation --->
<section>
    <h2>2. createAISession("#application.dinoDetectiveConnection#")</h2>
    <cftry>
        <cfset aiSession = createAISession(
            name = application.dinoDetectiveConnection,
            systemMessage = "You are an assistant who responds very briefly in English."
        )>
        <p class="ok">✔ AI session created</p>

        <!--- Test 3: live request to the active engine --->
        <h2>3. inquiryAISession() — live request</h2>
        <cfset reponse = inquiryAISession(aiSession, "Answer in one sentence: what is the largest dinosaur known?")>

        <!--- Safety: if a multipart response (array) arrives, use the text part --->
        <cfif isArray(reponse)>
            <cfloop array="#reponse#" index="part">
                <cfif structKeyExists(part, "content")>
                    <cfset reponse = part.content>
                    <cfbreak>
                </cfif>
            </cfloop>
        </cfif>

        <p class="ok">✔ Response received:</p>
        <pre>#encodeForHtml(reponse)#</pre>

        <cfcatch type="any">
            <p class="ko">✖ Error: #encodeForHtml(cfcatch.type)#</p>
            <pre>#encodeForHtml(cfcatch.message)#

#encodeForHtml(cfcatch.detail)#</pre>
        </cfcatch>

    </cftry>
</section>

<p><small>Diagnostic page — remove before deploying to production.</small></p>
</cfoutput>
</body>
</html>
