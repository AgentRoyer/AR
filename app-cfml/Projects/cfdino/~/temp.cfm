<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Temp LA BIENVENUE</title>
    <style>
        body { font-family: sans-serif; padding: 20px; text-align: center; background: #f4f4f9; }
        button { padding: 15px 40px; font-size: 18px; background: #28a745; color: white; border: none; border-radius: 5px; cursor: pointer; }
        table { width: 100%; max-width: 400px; margin: 25px auto; border-collapse: collapse; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        td { padding: 18px; border: 1px solid #ddd; font-size: 20px; }
        td:first-child { font-weight: bold; text-align: left; }
        td:nth-child(2) { text-align: center; color: #888; font-size: 16px; }
        td:last-child { text-align: right; color: #007bff; font-weight: bold; }
        #status { margin-top: 15px; color: #666; font-size: 14px; }
    </style>
</head>
<body>

    <h1>🌡️ LA BIENVENUE</h1>
    <button id="scanBtn">Scan</button>
    <p id="status"></p>

    <table>
        <tr><td>FRIGO</td><td id="rssi-80EB52">--</td><td id="temp-80EB52">--</td></tr>
        <tr><td>CONGEL</td><td id="rssi-80EB53">--</td><td id="temp-80EB53">--</td></tr>
        <tr><td>CUISINE</td><td id="rssi-80EB54">--</td><td id="temp-80EB54">--</td></tr>
    </table>

    <script>
    const TEMP_UUID = '00002a6e-0000-1000-8000-00805f9b34fb';
    const ELA_COMPANY_ID = 0x0757;
    const status = document.getElementById('status');

    function updateTemp(name, tempC, rssi) {
        for (const suffix of ['80EB52', '80EB53', '80EB54']) {
            if (name && name.includes(suffix)) {
                document.getElementById('temp-' + suffix).textContent = tempC.toFixed(1) + ' °C';
                document.getElementById('rssi-' + suffix).textContent = rssi + ' dBm';
            }
        }
    }

    document.getElementById('scanBtn').addEventListener('click', async () => {
        try {
            status.textContent = 'Scan en cours...';

            navigator.bluetooth.addEventListener('advertisementreceived', (event) => {
                const name = event.device.name;

                let tempC = null;

                const tempView = event.serviceData.get(TEMP_UUID);
                if (tempView) {
                    tempC = tempView.getInt16(0, true) * 0.01;
                }

                const mfrView = event.manufacturerData.get(ELA_COMPANY_ID);
                if (tempC === null && mfrView && mfrView.byteLength >= 3 && mfrView.getUint8(0) === 0x12) {
                    tempC = mfrView.getInt16(1, true) * 0.01;
                }

                if (tempC !== null) {
                    updateTemp(name, tempC, event.rssi);
                    status.textContent = 'Dernière mise à jour : ' + name + ' (' + new Date().toLocaleTimeString() + ')';
                }
            });

            await navigator.bluetooth.requestLEScan({
                filters: [{ namePrefix: 'P T' }],
                keepRepeatedDevices: true
            });

        } catch (error) {
            status.textContent = '❌ Erreur : ' + error.message;
            console.error(error);
        }
    });
    </script>
</body>
</html>
