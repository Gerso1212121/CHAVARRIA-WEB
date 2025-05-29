import axios from 'axios';
import enviarFactura from './emailService.js';

export default async function handleWebhook(req, res) {
  const { transaction } = req.body.data;

  try {
    const response = await axios.get(
      `https://sandbox.wompi.sv/v1/transactions/${transaction.id}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.WOMPI_PRIVATE_KEY}`,
        },
      }
    );

    const data = response.data.data;

    if (data.status === 'APPROVED') {
      await enviarFactura(data.customer_email, data.reference);
    }

    res.sendStatus(200);
  } catch (err) {
    console.error('Error procesando webhook:', err);
    res.sendStatus(500);
  }
}
