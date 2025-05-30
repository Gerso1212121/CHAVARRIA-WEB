const express = require('express');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Paso 1: Obtener access_token desde Wompi
async function obtenerAccessToken() {
  try {
    const data = new URLSearchParams({
      grant_type: 'client_credentials',
      audience: 'wompi_api',
      client_id: process.env.WOMPI_CLIENT_ID,
      client_secret: process.env.WOMPI_CLIENT_SECRET,
    });

    console.log('🔐 Solicitando token...');
    const response = await axios.post('https://id.wompi.sv/connect/token', data, {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    });

    console.log('✅ Token recibido:', response.data.access_token);
    return response.data.access_token;
  } catch (err) {
    console.error('❌ Error al obtener token:', err.response?.data || err.message);
    throw new Error('No se pudo obtener token de Wompi');
  }
}

// Paso 2: Crear enlace de pago
app.post('/generar-link', async (req, res) => {
  try {
    const { total, correo } = req.body;
    console.log('📨 Datos recibidos:', req.body);

    if (!total || !correo) {
      console.warn('⚠️ Faltan parámetros obligatorios');
      return res.status(400).json({ error: 'Faltan parámetros (total o correo)' });
    }

    const montoCents = Math.round(parseFloat(total) * 100);
    const referencia = `orden_${Date.now()}`;
    const token = await obtenerAccessToken();

    const payload = {
      nombreProducto: 'Compra desde Flutter',
      descripcionProducto: 'Pago personalizado por app',
      monto: montoCents,
      moneda: 'USD',
      cantidad: 1,
      editableMonto: false,
      editableCantidad: false,
      identificador_unico: referencia, // ⚠️ Wompi SV requiere snake_case
      datosCliente: {
        correoElectronico: correo,
      },
      formasDePago: {
        tarjeta: true,
        quickPay: true,
        puntos: false,
        bitcoin: false,
      },
    };

    console.log('📦 Payload a enviar:', JSON.stringify(payload, null, 2));

    const response = await axios.post('https://api.wompi.sv/EnlacePago', payload, {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        Accept: 'application/json', // ⚠️ Importante para evitar errores silenciosos
      },
    });

    console.log('✅ Link generado:', response.data.url);
    res.json({ url: response.data.url });
  } catch (e) {
    console.error('❌ Error al generar enlace de pago:');
    console.error(e.response?.data || e.message);

    res.status(500).json({
      error: 'Error al generar enlace de pago',
      detalle: e.response?.data || e.message,
    });
  }
});

app.listen(PORT, () => console.log(`🚀 Servidor corriendo en puerto ${PORT}`));
