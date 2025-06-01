import 'package:final_project/viewmodels/servicios/viewmodel_pedidos.dart';
import 'package:flutter/material.dart';

class HistorialPedidos extends StatelessWidget {
  final String clienteId;

  const HistorialPedidos(this.clienteId, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: obtenerHistorialPedidos(clienteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          print('❌ Error en FutureBuilder: ${snapshot.error}');
          return const Text('Error cargando pedidos.');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('📭 No hay pedidos para el cliente $clienteId');
          return const Text('No tienes pedidos aún.');
        }

        final pedidos = snapshot.data!;
        print('✅ Pedidos encontrados: ${pedidos.length}');
        print('📦 Detalle de pedidos: $pedidos');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pedidos.map((pedido) {
            final detalles = List<Map<String, dynamic>>.from(pedido['detallepedido']);
            print('📑 Pedido #${pedido['id_pedido']} con ${detalles.length} items');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🧾 Pedido: ${pedido['id_pedido']} - ${pedido['fecha']}'),
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                  },
                  children: [
                    const TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('Producto')),
                        Padding(padding: EdgeInsets.all(8), child: Text('Cantidad')),
                        Padding(padding: EdgeInsets.all(8), child: Text('Precio U.')),
                        Padding(padding: EdgeInsets.all(8), child: Text('Subtotal')),
                      ],
                    ),
                    ...detalles.map((detalle) {
                      final producto = detalle['producto'] ?? {};
                      print('🛒 Item: $detalle');

                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(8), child: Text(producto['nombre'] ?? '')),
                          Padding(padding: const EdgeInsets.all(8), child: Text('${detalle['cantidad']}')),
                          Padding(padding: const EdgeInsets.all(8), child: Text('\$${detalle['precio_unitario']}')),
                          Padding(padding: const EdgeInsets.all(8), child: Text('\$${detalle['subtotal']}')),
                        ],
                      );
                    }).toList()
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
