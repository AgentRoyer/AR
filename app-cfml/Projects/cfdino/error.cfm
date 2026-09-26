<cfparam name="request.errorStatusCode" default="500">
<cfparam name="request.errorTarget" default="#cgi.script_name#">
<cfparam name="request.errorEventName" default="">

<cfif request.errorStatusCode EQ 404>
    <cfheader statuscode="404" statustext="Not Found">
<cfelse>
    <cfheader statuscode="500" statustext="Internal Server Error">
</cfif>
<cfcontent type="text/html; charset=UTF-8">

<cfif application.env EQ "prod">
    <h1>An error has occured. Sorry !</h1>
<cfelse>
<cfoutput>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Erreur #request.errorStatusCode#</title>
    <style>
        body { font-family: sans-serif; background: ##f8f9fa; color: ##333; padding: 40px; }
        .error-container { max-width: 800px; margin: auto; background: ##fff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: ##dc3545; margin-top: 0; }
        pre { background: ##f1f3f5; padding: 15px; border-radius: 4px; overflow-x: auto; font-size: 13px; }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>Erreur #request.errorStatusCode#</h1>
        <p><strong>URL demandée :</strong> #encodeForHtml(request.errorTarget)#</p>
        <p><strong>Query string :</strong> #encodeForHtml(cgi.query_string)#</p>
        <p><strong>Referer :</strong> #encodeForHtml(cgi.http_referer)#</p>
        <p><strong>Adresse distante :</strong> #encodeForHtml(cgi.remote_addr)#</p>

        <cfif structKeyExists(request, "errorException")>
            <h2>Détails de l'exception</h2>
            <p><strong>Événement :</strong> #encodeForHtml(request.errorEventName)#</p>
            <p><strong>Message :</strong> #encodeForHtml(request.errorException.message)#</p>
            <cfif structKeyExists(request.errorException, "tagContext") AND arrayLen(request.errorException.tagContext)>
                <p><strong>Fichier :</strong> #encodeForHtml(request.errorException.tagContext[1].template)# (ligne #request.errorException.tagContext[1].line#)</p>
            </cfif>
        </cfif>

        <h2>Contexte de débogage</h2>
        <cfdump var="#request#" expand="true" label="Request">
        <cfdump var="#url#" expand="true" label="URL">
        <cfdump var="#form#" expand="true" label="Form">
        <cfdump var="#cgi#" expand="true" label="CGI">
        <cfdump var="#session#" expand="true" label="Session">
    </div>
</body>
</html>
</cfoutput>
</cfif>