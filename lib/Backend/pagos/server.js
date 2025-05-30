require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();

app.use(cors({ origin: '*' }));
app.use(express.json());

app.post('/api/wompi/enlace', async (req, res) => {
    console.log('🔵 Body recibido:', req.body);
    try {
        const { referencia, montoCents, nombreProducto } = req.body;

        // 1. Obtener el token correctamente
        const tokenResp = await axios.post(
            process.env.WOMPI_AUTH + 'connect/token',
            new URLSearchParams({
                grant_type: 'client_credentials',
                client_id: process.env.WOMPI_CLIENT_ID,
                client_secret: process.env.WOMPI_CLIENT_SECRET,
                audience: 'wompi_api'
            }).toString(),
            { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
        );
        const token = tokenResp.data.access_token;

        // 2. Armar payload y URL para Wompi
        const payload = {
            identificadorEnlaceComercio: referencia,
            monto: montoCents,
            nombreProducto,
            configuracion: {
                duracionInterfazIntentoMinutos: 10 // 60 minutos (1 hora)
                // Puedes agregar otros campos aquí si quieres, como urlRedirect, urlWebhook, etc.
            }
        };

        const wompiUrl = process.env.WOMPI_API + 'EnlacePago';

        // 🚨 Aquí imprime lo que se enviará a Wompi (¡antes del POST!)
        console.log('🌎 URL a Wompi:', wompiUrl);
        console.log('📦 Payload a Wompi:', payload);

        // 3. Hacer el POST real a Wompi
        const wompiResp = await axios.post(
            wompiUrl,
            payload,
            {
                headers: {
                    Authorization: `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            }
        );

        // 4. Responder a tu frontend
        res.json({
            ok: true,
            urlEnlace: wompiResp.data.urlEnlace,
            idEnlace: wompiResp.data.idEnlace
        });
    } catch (err) {
        console.error('❌ Error al generar enlace de pago:', err.response?.data || err.message, err.response?.status);
        res.status(400).json({ ok: false, error: err.response?.data || err.message });
    }
});

app.post('/webhook/wompi', (req, res) => {
    console.log('[WEBHOOK]', req.body);
    res.sendStatus(200);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log('Servidor corriendo en el puerto', PORT);
});