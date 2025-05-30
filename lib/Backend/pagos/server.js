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
    // Imprime el error recibido para que lo puedas ver en los logs
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
