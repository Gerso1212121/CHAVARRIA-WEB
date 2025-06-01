require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const nodemailer = require('nodemailer');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(cors({ origin: '*' }));
app.use(express.json());

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);
const DURACION_MINUTOS = 10;
const DOMAIN_URL = process.env.DOMAIN_URL;

app.post('/api/wompi/enlace', async (req, res) => {
    try {
        const { referencia, montoCents, nombreProducto, clienteId } = req.body;

        const tokenResp = await axios.post(
            process.env.WOMPI_AUTH + 'connect/token',
            new URLSearchParams({
                grant_type: 'client_credentials',
                client_id: process.env.WOMPI_CLIENT_ID,
                client_secret: process.env.WOMPI_CLIENT_SECRET,
                audience: 'wompi_api',
            }).toString(),
            { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
        );

        const token = tokenResp.data.access_token;

        const payload = {
            identificadorEnlaceComercio: referencia,
            monto: montoCents,
            nombreProducto,
            configuracion: {
                duracionInterfazIntentoMinutos: DURACION_MINUTOS,
                urlWebhook: process.env.WEBHOOK_URL,
                urlRedirect: `${DOMAIN_URL}/#/verificacion-pago?referencia=${referencia}`,
            },
        };

        const wompiResp = await axios.post(process.env.WOMPI_API + 'EnlacePago', payload, {
            headers: {
                Authorization: `Bearer ${token}`,
                'Content-Type': 'application/json',
            },
        });

        const expira = new Date(Date.now() + DURACION_MINUTOS * 60 * 1000);

        const insertResp = await supabase.from('pagos').insert([{
            referencia_pago: referencia,
            monto_total: montoCents / 100,
            metodo_pago: 'Tarjeta',
            estado: 'pendiente',
            expira_en: expira.toISOString(),
            id_cliente: clienteId ?? null,
        }]);

        if (insertResp.error) {
            console.error('❌ Error insertando en DB:', insertResp.error);
            return res.status(500).json({ ok: false, error: 'Error guardando en base de datos.' });
        }

        res.json({
            ok: true,
            urlEnlace: wompiResp.data.urlEnlace,
            idEnlace: wompiResp.data.idEnlace,
            expiraEn: expira,
        });
    } catch (err) {
        console.error('❌ Error creando enlace:', err.response?.data || err.message);
        res.status(400).json({ ok: false, error: err.response?.data || err.message });
    }
});

app.post('/webhook/wompi', async (req, res) => {
    const evento = req.body?.event;
    const referencia = req.body?.data?.referencia || req.body?.data?.transaccion?.referencia;

    if (evento === 'transaccion_exitosa' && referencia) {
        const { data: pago } = await supabase.from('pagos').select('*').eq('referencia_pago', referencia).single();
        if (!pago) return res.sendStatus(404);

        await supabase.from('pagos').update({ estado: 'procesado' }).eq('referencia_pago', referencia);
        await procesarPedidoPorReferencia(referencia);

        const { data: cliente } = await supabase
            .from('cliente')
            .select('correo, nombre')
            .eq('id_cliente', pago.id_cliente)
            .single();

        const { data: pedidos } = await supabase
            .from('pedido')
            .select('id_pedido')
            .eq('id_cliente', pago.id_cliente)
            .order('fecha', { ascending: false })
            .limit(1);

        const pedidoId = pedidos?.[0]?.id_pedido;

        const { data: detalles } = await supabase
            .from('detallepedido')
            .select('cantidad, precio_unitario, subtotal, producto(nombre)')
            .eq('id_pedido', pedidoId);

        const tablaHTML = detalles?.map(item => `
      <tr>
        <td>${item.producto?.nombre || 'Producto'}</td>
        <td>${item.cantidad}</td>
        <td>$${item.precio_unitario.toFixed(2)}</td>
        <td>$${item.subtotal.toFixed(2)}</td>
      </tr>
    `).join('');

        const htmlContent = `
      <h2>Hola ${cliente?.nombre || 'Cliente'},</h2>
      <p>Gracias por tu compra. Aquí está el detalle de tu pedido:</p>
      <p><strong>Referencia:</strong> ${referencia}</p>
      <table border="1" cellpadding="8" cellspacing="0" style="border-collapse: collapse;">
        <thead>
          <tr>
            <th>Producto</th>
            <th>Cantidad</th>
            <th>Precio Unitario</th>
            <th>Subtotal</th>
          </tr>
        </thead>
        <tbody>
          ${tablaHTML}
        </tbody>
      </table>
      <p><strong>Total pagado:</strong> $${pago.monto_total.toFixed(2)}</p>
      <p>¡Gracias por confiar en Carpintería Chavarría!</p>
    `;

        if (cliente?.correo) {
            const transporter = nodemailer.createTransport({
                service: 'gmail',
                auth: {
                    user: process.env.EMAIL_USER,
                    pass: process.env.EMAIL_PASS,
                },
            });

            const mailOptions = {
                from: 'Carpintería Chavarría <no-reply@carpinteriachavarria.com>',
                to: cliente.correo,
                subject: '🧾 Confirmación de compra - Carpintería Chavarría',
                html: htmlContent,
            };

            try {
                await transporter.sendMail(mailOptions);
                console.log(`📧 Correo enviado a ${cliente.correo}`);
            } catch (err) {
                console.error('❌ Error enviando correo:', err);
            }
        }
    }

    res.sendStatus(200);
});

async function procesarPedidoPorReferencia(referencia) {
    const { data: pago } = await supabase.from('pagos').select('*').eq('referencia_pago', referencia).single();
    if (!pago || pago.estado !== 'procesado') return;

    const clienteId = pago.id_cliente;
    const { data: carrito } = await supabase.from('carrito').select('id').eq('usuario_id', clienteId).single();
    if (!carrito) return;

    const { data: items } = await supabase.from('carrito_items').select('*, producto(precio)').eq('carrito_id', carrito.id);
    if (!items || items.length === 0) return;

    const pedidoRes = await supabase.from('pedido').insert([{ id_cliente: clienteId, monto_total: pago.monto_total, metodo_pago: pago.metodo_pago }]).select('*').single();
    const pedidoId = pedidoRes.data.id_pedido;

    const detalleList = [];
    for (const item of items) {
        const precio = item.producto?.precio || 0;
        const subtotal = precio * item.cantidad;

        detalleList.push({
            id_pedido: pedidoId,
            id_producto: item.producto_id,
            cantidad: item.cantidad,
            precio_unitario: precio,
            subtotal,
            armado_incluido: false,
            envoltura: false,
        });

        await supabase.rpc('disminuir_stock', { pid: item.producto_id, cantidad: item.cantidad });
    }

    await supabase.from('detallepedido').insert(detalleList);
    await supabase.from('carrito_items').delete().eq('carrito_id', carrito.id);
}

app.get('/api/pagos/:referencia', async (req, res) => {
    const { referencia } = req.params;
    const { data, error } = await supabase.from('pagos').select('estado, expira_en').eq('referencia_pago', referencia).single();

    if (error) return res.status(404).json({ ok: false, error: 'Pago no encontrado' });

    const vencido = new Date() > new Date(data.expira_en);
    const pagado = data.estado === 'procesado';

    res.json({ ok: true, pagado, vencido, estado: data.estado });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Servidor corriendo en puerto ${PORT}`));