<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sonde Blue Puck - Lecture par annonces BLE</title>
    <style>
        body { font-family: sans-serif; padding: 20px; text-align: center; background: #f4f4f9; }
        button { padding: 15px 25px; font-size: 16px; background: #28a745; color: white; border: none; border-radius: 5px; cursor: pointer; margin: 8px; }
        button.secondary { background: #6c757d; }
        #log { margin-top: 20px; padding: 15px; background: white; border-radius: 5px; text-align: left; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .valeur { font-size: 32px; color: #007bff; font-weight: bold; margin: 10px 0; }
        .warn { background: #fff3cd; padding: 12px; border-radius: 5px; text-align: left; margin-top: 15px; font-size: 14px; }
        code { background: #eee; padding: 2px 5px; border-radius: 3px; }
    </style>
</head>
<body>

    <h1>Sonde Blue Puck (ELA Innovation)</h1>

    <button id="scanBtn">🛰️ Scan brut (requestLEScan - recommandé)</button>
    <button id="watchBtn" class="secondary">📡 Écouter les annonces (watchAdvertisements)</button>
    <button id="connectBtn" class="secondary">🔌 Essai connexion GATT (batterie)</button>
    <button id="stopBtn" class="secondary" style="display:none;">⏹️ Arrêter le scan</button>

    <div id="log">Clique sur "Scan brut (requestLEScan)" pour recevoir la température diffusée par la sonde.</div>

    <div class="warn">
        ⚠️ Le bouton <code>requestLEScan</code> nécessite le même drapeau expérimental de Chrome. Va dans
        <code>chrome://flags/#enable-experimental-web-platform-features</code>, active-le, redémarre Chrome, puis réessaie.<br><br>
        Contrairement à <code>watchAdvertisements()</code> (bug connu où <code>serviceData</code>/<code>manufacturerData</code>
        restent vides sur beaucoup d'appareils), <code>requestLEScan()</code> expose fiablement le contenu brut des annonces.
    </div>

    <script>
    const logDiv = document.getElementById('log');

    // Standard Temperature UUID (0x2A6E) in its full 128-bit form
    const TEMP_UUID = '00002a6e-0000-1000-8000-00805f9b34fb';
    const HUMIDITY_UUID = '00002a6f-0000-1000-8000-00805f9b34fb';
    const ELA_COMPANY_ID = 0x0757; // Company Identifier ELA Innovation

    function formatServiceData(map) {
        let out = '';
        map.forEach((view, uuid) => {
            out += `<li><code>${uuid}</code> → ${bytesToHex(view)}</li>`;
        });
        return out;
    }

    function bytesToHex(view) {
        let s = '';
        for (let i = 0; i < view.byteLength; i++) {
            s += view.getUint8(i).toString(16).padStart(2, '0') + ' ';
        }
        return s.trim();
    }

    let activeScan = null;
    let scanCount = 0;

    function renderAdvertisement(event, sourceLabel) {
        scanCount++;
        let html = `<h3>${sourceLabel} — Annonce #${scanCount} de ${event.device.name || '(sans nom)'}</h3>`;
        html += `RSSI : ${event.rssi} dBm`;
        if (event.txPower !== null && event.txPower !== undefined && event.txPower !== -128) {
            html += ` — TX Power : ${event.txPower}`;
        }
        html += `<br>`;

        if (event.uuids && event.uuids.length) {
            html += `<b>UUIDs annoncés :</b> ${event.uuids.join(', ')}<br>`;
        }

        const tempView = event.serviceData.get(TEMP_UUID);
        if (tempView) {
            const tempC = tempView.getInt16(0, true) * 0.01;
            html += `<div class="valeur">🌡️ ${tempC.toFixed(2)} °C</div>`;
        }

        const humView = event.serviceData.get(HUMIDITY_UUID);
        if (humView) {
            html += `<div>💧 Humidité : ${humView.getUint8(0)} %</div>`;
        }

        const mfrView = event.manufacturerData.get(ELA_COMPANY_ID);
        if (mfrView && mfrView.byteLength >= 3 && mfrView.getUint8(0) === 0x12) {
            const tempC2 = mfrView.getInt16(1, true) * 0.01;
            html += `<div class="valeur">🌡️ (Mfr Data) ${tempC2.toFixed(2)} °C</div>`;
        }

        html += `<hr><p><b>Contenu brut complet de cette annonce :</b></p>`;
        html += `<p><u>Service Data</u> (${event.serviceData.size} entrée(s)) :</p>`;
        html += event.serviceData.size === 0
            ? `<p><i>— vide —</i></p>`
            : `<ul>${formatServiceData(event.serviceData)}</ul>`;

        html += `<p><u>Manufacturer Data</u> (${event.manufacturerData.size} entrée(s)) :</p>`;
        if (event.manufacturerData.size === 0) {
            html += `<p><i>— vide —</i></p>`;
        } else {
            let mfrHtml = '';
            event.manufacturerData.forEach((view, companyId) => {
                mfrHtml += `<li>Company ID : <code>0x${companyId.toString(16).padStart(4, '0')}</code> (${companyId}) → ${bytesToHex(view)}</li>`;
            });
            html += `<ul>${mfrHtml}</ul>`;
        }

        logDiv.innerHTML = html;
    }

    document.getElementById('scanBtn').addEventListener('click', async () => {
        try {
            logDiv.innerHTML = "Démarrage du scan brut (requestLEScan)... Autorise la demande qui va apparaître.";
            scanCount = 0;

            // Use one global navigator.bluetooth listener for requestLEScan
            navigator.bluetooth.addEventListener('advertisementreceived', (event) => {
                renderAdvertisement(event, '🛰️ requestLEScan');
            });

            activeScan = await navigator.bluetooth.requestLEScan({
                filters: [{ namePrefix: 'P T' }],
                keepRepeatedDevices: true
            });

            document.getElementById('stopBtn').style.display = 'inline-block';
            logDiv.innerHTML = "Scan actif, en attente de la première annonce de la sonde...";

        } catch (error) {
            logDiv.innerHTML = `❌ Erreur requestLEScan : ${error.message}`;
            console.error(error);
        }
    });

    document.getElementById('stopBtn').addEventListener('click', () => {
        if (activeScan) {
            activeScan.stop();
            activeScan = null;
            document.getElementById('stopBtn').style.display = 'none';
        }
    });

    document.getElementById('watchBtn').addEventListener('click', async () => {
        try {
            logDiv.innerHTML = "Recherche de la sonde (choisis-la dans la liste)...";

            const device = await navigator.bluetooth.requestDevice({
                filters: [{ namePrefix: 'P T' }],
                // Do not request any GATT services: this reads advertisements without connecting
                optionalServices: []
            });

            logDiv.innerHTML = `Sonde sélectionnée : <b>${device.name}</b>. En attente de la première annonce Bluetooth...<br>(cela peut prendre quelques secondes selon l'intervalle d'émission de la sonde)`;

            device.addEventListener('advertisementreceived', (event) => {
                renderAdvertisement(event, '📡 watchAdvertisements');
            });

            await device.watchAdvertisements();

        } catch (error) {
            logDiv.innerHTML = `❌ Erreur : ${error.message}<br><br>
            Si l'erreur mentionne que <code>watchAdvertisements</code> n'est pas une fonction,
            active le drapeau Chrome mentionné en bas de page.`;
            console.error(error);
        }
    });

    // Secondary button: traditional GATT connection test, only useful for reading
    // the battery level (standard service 0x180F), not the temperature.
    document.getElementById('connectBtn').addEventListener('click', async () => {
        try {
            logDiv.innerHTML = "Recherche de la sonde...";
            const device = await navigator.bluetooth.requestDevice({
                filters: [{ namePrefix: 'P T' }],
                optionalServices: [
                    'battery_service',        // 0x180F
                    'device_information',     // 0x180A
                    'generic_access',         // 0x1800
                    'generic_attribute'       // 0x1801
                ]
            });

            logDiv.innerHTML = `Connexion à ${device.name}...`;
            const server = await device.gatt.connect();

            const services = await server.getPrimaryServices();
            let out = `<h3>Services GATT trouvés sur ${device.name} :</h3><ul>`;
            for (const service of services) {
                out += `<li><code>${service.uuid}</code></li>`;
            }
            out += `</ul><p>Note : la température n'est en général PAS exposée ici — elle est diffusée uniquement dans les paquets d'annonce (voir bouton "Écouter les annonces").</p>`;
            logDiv.innerHTML = out;

        } catch (error) {
            logDiv.innerHTML = `❌ Erreur GATT : ${error.message}<br><br>
            C'est attendu : ce modèle de sonde (Blue Puck / ELA Innovation) fonctionne surtout
            en mode "Advertising" et n'expose pas forcément de connexion GATT ouverte au public.`;
            console.error(error);
        }
    });
    </script>
</body>
</html>
