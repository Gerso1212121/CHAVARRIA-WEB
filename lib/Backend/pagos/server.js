require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const nodemailer = require('nodemailer');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(cors({ origin: '*' }));
app.use(express.urlencoded({ extended: true })); // Soporte para x-www-form-urlencoded
app.use(express.json()); // Soporte para JSON

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);
const DURACION_MINUTOS = 10;
const DOMAIN_URL = process.env.DOMAIN_URL;

// Crear enlace de pago
app.post('/api/wompi/enlace', async (req, res) => {
    try {
        const { referencia, montoCents, nombreProducto, clienteId } = req.body;

        console.log('➡️ Creando enlace de pago:', referencia);

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
                urlRedirect: `${DOMAIN_URL}/redir.html?referencia=${referencia}`,
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
            monto_total: montoCents,
            metodo_pago: 'Tarjeta',
            estado: 'pendiente',
            expira_en: expira.toISOString(),
            id_cliente: clienteId ?? null,
        }]);

        if (insertResp.error) {
            console.error('❌ Error insertando en DB:', insertResp.error);
            return res.status(500).json({ ok: false, error: 'Error guardando en base de datos.' });
        }

        console.log('✅ Enlace de pago creado correctamente.');

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

// Webhook de Wompi
app.post('/webhook/wompi', async (req, res) => {
    console.log('📥 Webhook headers:', req.headers);
    console.log('📥 Webhook body:', JSON.stringify(req.body, null, 2));

    const evento = req.body?.ResultadoTransaccion;
    const referencia = req.body?.EnlacePago?.IdentificadorEnlaceComercio;

    console.log('📥 Webhook recibido. Evento:', evento, 'Referencia:', referencia);

    if (evento !== 'ExitosaAprobada' || !referencia) {
        console.warn('⚠️ Webhook sin evento exitoso o referencia inválida.');
        return res.sendStatus(400);
    }

    try {
        const { data: pago } = await supabase
            .from('pagos')
            .select('*')
            .eq('referencia_pago', referencia)
            .single();

        if (!pago) {
            console.error('❌ Pago no encontrado en la base de datos.');
            return res.sendStatus(404);
        }

        console.log('💳 Pago encontrado. Actualizando estado...');
        await supabase
            .from('pagos')
            .update({ estado: 'procesado' })
            .eq('referencia_pago', referencia);

        await procesarPedidoPorReferencia(referencia);

        const { data: cliente } = await supabase
            .from('cliente')
            .select('correo, nombre, direccion')
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
            .select(`
        cantidad,
        precio_unitario,
        subtotal,
        producto!fk_detallepedido_producto(nombre, codigo_barras)
      `)
            .eq('id_pedido', pedidoId);

        const tablaHTML = detalles?.map(item => `
      <tr>
        <td>${item.producto?.nombre || 'Producto'}</td>
        <td>${item.producto?.codigo_barras || '-'}</td>
        <td>${item.cantidad}</td>
        <td>$${item.precio_unitario.toFixed(2)}</td>
        <td>$${item.subtotal.toFixed(2)}</td>
      </tr>
    `).join('');

        const htmlContent = `
  <div style="font-family: Arial, sans-serif; color: #333;">
    <h2 style="color: #D2691E;">Gracias por tu compra, ${cliente?.nombre}!</h2>
    <p>Tu pedido ha sido recibido correctamente y será procesado en breve.</p>

    <h3 style="margin-top: 30px; color: #444;">🛒 Detalles del Pedido:</h3>
    <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
      <thead>
        <tr style="background-color: #f2f2f2;">
          <th style="border: 1px solid #ddd; padding: 10px;">Producto</th>
          <th style="border: 1px solid #ddd; padding: 10px;">Código</th>
          <th style="border: 1px solid #ddd; padding: 10px;">Cantidad</th>
          <th style="border: 1px solid #ddd; padding: 10px;">Precio Unitario</th>
          <th style="border: 1px solid #ddd; padding: 10px;">Subtotal</th>
        </tr>
      </thead>
      <tbody>
        ${tablaHTML}
      </tbody>
    </table>

    <p style="margin-top: 30px;"><strong>Dirección de envío:</strong><br>${cliente?.direccion}</p>

    <p style="margin-top: 40px;">Si tienes alguna pregunta, no dudes en contactarnos.</p>

    <p style="color: #888; font-size: 13px; margin-top: 30px;">
      Este es un correo automático, por favor no responder directamente.
    </p>
  </div>
`;


        if (cliente?.correo) {
            try {
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

                await transporter.sendMail(mailOptions);
                console.log('📧 Correo enviado a', cliente.correo);
            } catch (err) {
                console.error('❌ Error enviando correo:', err);
            }
        }

        return res.sendStatus(200);
    } catch (error) {
        console.error('❌ Error procesando webhook:', error);
        return res.sendStatus(500);
    }
});

// Procesamiento del pedido
async function procesarPedidoPorReferencia(referencia) {
    const { data: pago } = await supabase.from('pagos').select('*').eq('referencia_pago', referencia).single();
    if (!pago || pago.estado !== 'procesado') return;

    console.log('📦 Procesando pedido para:', referencia);

    const clienteId = pago.id_cliente;

    const { data: carrito, error: carritoError } = await supabase
        .from('carrito')
        .select('id_carrito')
        .eq('usuario_id', clienteId)
        .single();


    if (!carrito) {
        console.error('❌ Carrito no encontrado:', carritoError);
        return;
    }

    const { data: items, error: itemsError } = await supabase
        .from('carrito_items')
        .select('id, cantidad, producto_id, producto!fk_carritoitems_producto(precio)')
        .eq('carrito_id', carrito.id_carrito)

    if (itemsError || !items || items.length === 0) {
        console.error('❌ Error obteniendo items del carrito:', itemsError);
        return;
    }

    console.log('🧪 Ítems obtenidos:', items);

    const pedidoRes = await supabase
        .from('pedido')
        .insert([{ id_cliente: clienteId, monto_total: pago.monto_total, metodo_pago: pago.metodo_pago }])
        .select('*')
        .single();

    if (pedidoRes.error) {
        console.error('❌ Error al crear pedido:', pedidoRes.error);
        return;
    }

    const pedidoId = pedidoRes.data.id_pedido;

    const detalleList = items.map(item => ({
        id_pedido: pedidoId,
        id_producto: item.producto_id,
        cantidad: item.cantidad,
        precio_unitario: item.producto?.precio ?? 0,
        subtotal: (item.producto?.precio ?? 0) * item.cantidad,
    }));

    console.log('📝 Detalle a insertar:', detalleList);

    const { error: insertError, data: inserted } = await supabase
        .from('detallepedido')
        .insert(detalleList)
        .select();

    if (insertError) {
        console.error('❌ Error insertando detallepedido:', insertError);
    } else {
        console.log('✅ Detalles insertados correctamente:', inserted);
    }
    for (const item of items) {
        console.log(`🛠️ Disminuyendo stock para producto ${item.producto_id} (${item.cantidad})`);

        const { error: stockError, data } = await supabase.rpc('disminuir_stock', {
            pid: item.producto_id,
            cantidad: item.cantidad,
        });

        if (stockError) {
            console.error(`❌ Error actualizando stock para producto ${item.producto_id}:`, stockError);
        } else {
            console.log(`✅ Stock actualizado para producto ${item.producto_id}`);
        }
    }

    await supabase.from('carrito_items').delete().eq('carrito_id', carrito.id_carrito);
    console.log('🧹 Carrito limpiado para usuario', clienteId);
}
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
});

