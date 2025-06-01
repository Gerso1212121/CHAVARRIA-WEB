import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HistorialPedidos extends StatelessWidget {
  final String clienteId;
  const HistorialPedidos(this.clienteId, {super.key});

  Future<List<Map<String, dynamic>>> obtenerPedidosYDetalles() async {
    final response = await supabase
        .from('pedido')
        .select('''
          id_pedido,
          fecha,
          monto_total,
          detallepedido(
            cantidad,
            precio_unitario,
            producto:fk_detallepedido_producto(nombre)
          )
        ''')
        .eq('id_cliente', clienteId)
        .order('fecha', ascending: false);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: obtenerPedidosYDetalles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No hay pedidos registrados.'),
          );
        }

        final pedidos = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📦 Historial de Pedidos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...pedidos.map((pedido) {
              final detalles = (pedido['detallepedido'] as List?) ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🧾 Pedido #${pedido['id_pedido']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('🗓 Fecha: ${pedido['fecha']}'),
                      Text('💰 Total: \$${pedido['monto_total']}'),
                      const SizedBox(height: 8),
                      const Divider(),
                      const Text(
                        'Productos:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...detalles.map((item) {
                        final producto = item['producto'] ?? {};
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                              '• ${producto['nombre'] ?? 'Producto'} x${item['cantidad']} - \$${item['precio_unitario']}'),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
