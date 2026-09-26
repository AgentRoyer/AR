<cfparam name="url.datasource" default="cfdinoco_test">
<cfparam name="url.host" default="db">
<cfparam name="url.port" default="3306">
<cfparam name="url.database" default="cfdino">
<cfparam name="url.username" default="root">
<cfparam name="url.password" default="MonSuperMotDePasseAdmin123">

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <title>DB Test MariaDB</title>
</head>
<body>
    <h1>Test de connexion MariaDB</h1>
    <p>Ce fichier tente une connexion via le datasource Lucee configuré.</p>

    <cftry>
        <cfquery name="dbTest" datasource="#url.datasource#">
            SELECT DATABASE() AS current_db, NOW() AS server_time
        </cfquery>

        <cfoutput>
            <p><strong>État :</strong> OK</p>
            <p><strong>Datasource :</strong> #encodeForHTML(url.datasource)#</p>
            <p><strong>Base courante :</strong> #encodeForHTML(dbTest.current_db[1])#</p>
            <p><strong>Heure serveur :</strong> #encodeForHTML(dbTest.server_time[1])#</p>
        </cfoutput>

    <cfcatch type="any">
        <cfoutput>
            <p><strong>État :</strong> Échec</p>
            <p><strong>Message :</strong> #encodeForHTML(cfcatch.message)#</p>
            <p><strong>Détails :</strong> #encodeForHTML(cfcatch.detail)#</p>
            <p><strong>Datasource demandé :</strong> #encodeForHTML(url.datasource)#</p>
        </cfoutput>

        <p>Vérifiez que :</p>
        <ul>
            <li>le conteneur MariaDB est bien démarré,</li>
            <li>le datasource existe dans Lucee,</li>
            <li>le nom de base et les credentials correspondent à la configuration Docker.</li>
        </ul>
    </cfcatch>
    </cftry>

    <hr>
    <h2>Paramètres attendus</h2>
    <cfoutput>
    <pre>
        host=#url.host#
        port=#url.port#
        database=#url.database#
        username=#url.username#
    </pre>
    </cfoutput>
</body>
</html>
