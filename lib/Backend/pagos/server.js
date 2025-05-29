import express from 'express';
import dotenv from 'dotenv';
import handleWebhook from './wompiWebhookHandler.js';

dotenv.config();
const app = express();
app.use(express.json());

app.post('/webhook-wompi', handleWebhook);

app.listen(3000, () => console.log('Servidor escuchando en puerto 3000'));
