require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();

app.use(cors({ origin: '*' }));
app.use(express.json());

// 💾 Mapa en memoria para almacenar enlaces con expiración
const enlacesConExpiracion = new Map();

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

        // 2. Armar payload para Wompi
        const payload = {
            identificadorEnlaceComercio: referencia,
            monto: montoCents,
            nombreProducto,
            configuracion: {
                duracionInterfazIntentoMinutos: 10,
                urlWebhook: process.env.WEBHOOK_URL,
            }
        };

        const wompiUrl = process.env.WOMPI_API + 'EnlacePago';

        console.log('🌎 URL a Wompi:', wompiUrl);
        console.log('📦 Payload a Wompi:', payload);

        // 3. Crear enlace en Wompi
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

        // 4. Guardar enlace en memoria con expiración
        const duracionMinutos = 10;
        const tiempoExpiracion = Date.now() + duracionMinutos * 60 * 1000;

        enlacesConExpiracion.set(referencia, {
            idEnlace: wompiResp.data.idEnlace,
            urlEnlace: wompiResp.data.urlEnlace,
            expiraEn: tiempoExpiracion
        });

        // 5. Responder al frontend
        res.json({
            ok: true,
            urlEnlace: wompiResp.data.urlEnlace,
            idEnlace: wompiResp.data.idEnlace,
            expiraEn: tiempoExpiracion
        });

    } catch (err) {
        console.error('❌ Error al generar enlace de pago:', err.response?.data || err.message, err.response?.status);
        res.status(400).json({ ok: false, error: err.response?.data || err.message });
    }
});

// 🔍 Verificación de enlace activo por referencia
app.get('/api/wompi/enlace/:referencia', (req, res) => {
    const { referencia } = req.params;
    const enlace = enlacesConExpiracion.get(referencia);

    if (!enlace) {
        return res.status(404).json({ ok: false, error: 'Enlace no encontrado' });
    }

    if (Date.now() > enlace.expiraEn) {
        enlacesConExpiracion.delete(referencia);
        return res.status(400).json({ ok: false, error: 'El enlace ha expirado' });
    }

    res.json({ ok: true, urlEnlace: enlace.urlEnlace });
});

// 🔔 Webhook
app.post('/webhook/wompi', (req, res) => {
    console.log('[WEBHOOK]', req.body);
    res.sendStatus(200);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log('Servidor corriendo en el puerto', PORT);
});
