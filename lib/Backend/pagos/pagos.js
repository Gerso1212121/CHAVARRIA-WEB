const express = require('express');
const axios = require('axios');
const nodemailer = require('nodemailer');
const app = express();
app.use(express.json());

const PRIVATE_KEY = 'TU_PRIVATE_KEY_WOMPI';
const EMAIL_TRANSPORT = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'TUCORREO@gmail.com',
    pass: 'TU_APP_PASSWORD',
  },
});

app.post('/webhook-wompi', async (req, res) => {
  const { transaction } = req.body.data;
  const transactionId = transaction.id;

  try {
    const respuesta = await axios.get(`https://sandbox.wompi.sv/v1/transactions/${transactionId}`, {
      headers: {
        Authorization: `Bearer ${PRIVATE_KEY}`,
      },
    });

    const datos = respuesta.data.data;
    const estado = datos.status;
    const referencia = datos.reference;
    const correoCliente = datos.customer_email;

    if (estado === 'APPROVED') {
      // Enviar factura al correo
      await EMAIL_TRANSPORT.sendMail({
        from: 'TUCORREO@gmail.com',
        to: correoCliente,
        subject: 'Factura de tu compra',
        text: `Gracias por tu compra. Tu transacción fue aprobada con referencia: ${referencia}.`,
      });
    }

    res.sendStatus(200);
  } catch (error) {
    console.error('Error en webhook:', error);
    res.sendStatus(500);
  }
});

app.listen(3000, () => console.log('Escuchando en puerto 3000'));
