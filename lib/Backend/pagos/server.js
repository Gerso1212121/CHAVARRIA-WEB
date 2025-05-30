// server.js
require('dotenv').config();
const express = require('express');
const axios = require('axios');
const app = express();
app.use(express.json());

// Endpoint para crear el enlace de pago Wompi
app.post('/api/wompi/enlace', async (req, res) => {
  try {
    const { referencia, montoCents, nombreProducto } = req.body;

    // 1. Obtener el token de Wompi
    const tokenResp = await axios.post(
      process.env.WOMPI_API + 'connect/token',
      new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: process.env.WOMPI_CLIENT_ID,
        client_secret: process.env.WOMPI_CLIENT_SECRET,
        audience: 'api.wompi.sv'
      }).toString(),
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
    );
    const token = tokenResp.data.access_token;

    // 2. Crear enlace de pago
    const payload = {
      identificadorEnlaceComercio: referencia,
      monto: montoCents,
      nombreProducto,
      configuracion: {
        urlWebhook: process.env.WEBHOOK_URL
      }
    };

    const wompiResp = await axios.post(
      process.env.WOMPI_API + 'api/enlaces-de-pago',
      payload,
      { headers: { Authorization: `Bearer ${token}` } }
    );

    res.json({
      ok: true,
      urlEnlace: wompiResp.data.urlEnlace,
      idEnlace: wompiResp.data.idEnlace
    });
  } catch (err) {
    res.status(400).json({ ok: false, error: err.response?.data || err.message });
  }
});

// Webhook para recibir notificaciones de Wompi
app.post('/webhook/wompi', (req, res) => {
  console.log('[WEBHOOK]', req.body);

  // Aquí procesas el pago según ResultadoTransaccion, etc.
  // Puedes actualizar tu base de datos aquí.

  res.sendStatus(200); // Confirma a Wompi que recibiste el webhook
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log('Servidor corriendo en el puerto', PORT);
});
