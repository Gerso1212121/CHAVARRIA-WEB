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
  const data = new URLSearchParams({
    grant_type: 'client_credentials',
    audience: 'wompi_api',
    client_id: process.env.WOMPI_CLIENT_ID,
    client_secret: process.env.WOMPI_CLIENT_SECRET,
  });

  const response = await axios.post('https://id.wompi.sv/connect/token', data, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });

  return response.data.access_token;
}

// Paso 2: Crear enlace de pago personalizado
app.post('/generar-link', async (req, res) => {
  try {
    const { total, correo } = req.body;

    if (!total || !correo) {
      return res.status(400).json({ error: 'Faltan parámetros' });
    }

    const montoCents = Math.round(parseFloat(total) * 100);
    const referencia = `orden_${Date.now()}`;

    const token = await obtenerAccessToken();

    const response = await axios.post(
      'https://api.wompi.sv/EnlacePago',
      {
        nombre: 'Compra desde Flutter',
        descripcion: 'Pago personalizado por app',
        monto: montoCents,
        moneda: 'USD',
        cantidad: 1,
        editableMonto: false,
        editableCantidad: false,
        referencia,
        datosCliente: { correoElectronico: correo },
        formasDePago: {
          tarjeta: true,
          quickPay: true,
          puntos: false,
          bitcoin: false,
        },
      },
      {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      }
    );

    res.json({ url: response.data.url });
  } catch (e) {
    console.error(e.message);
    res.status(500).json({ error: 'Error al generar enlace de pago' });
  }
});

app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));
