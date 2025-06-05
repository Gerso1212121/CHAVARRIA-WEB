import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/viewmodels/servicios/viewmodel_pedidos.dart';

class HistorialPedidos extends StatelessWidget {
  final String clienteId;

  const HistorialPedidos(this.clienteId, {super.key});

  String _formatearFecha(String fecha) {
    final parsed = DateTime.tryParse(fecha);
    if (parsed == null) return fecha;
    return DateFormat('dd/MM/yyyy').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: obtenerHistorialPedidos(clienteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('❌ Error cargando pedidos.');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('📭 No tienes pedidos aún.');
        }

        final pedidos = snapshot.data!;

        return Column(
          children: pedidos.map((pedido) {
            final detalles = List<Map<String, dynamic>>.from(pedido['detallepedido']);

            final totalPedido = detalles.fold<double>(0.0, (sum, item) {
              return sum + (item['subtotal'] as num).toDouble();
            });

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(41, 0, 0, 0),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧾 Pedido #${pedido['id_pedido']} - ${_formatearFecha(pedido['fecha'])}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Table(
                    border: TableBorder.all(color: Colors.orange.shade100, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFFFF8E1)),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Precio U.', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      ...detalles.map((detalle) {
                        final producto = detalle['producto'] ?? {};
                        final nombre = producto['nombre'] ?? '';
                        final cantidad = detalle['cantidad'];
                        final precio = (detalle['precio_unitario'] as num).toDouble();
                        final subtotal = (detalle['subtotal'] as num).toDouble();

                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(nombre),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('$cantidad'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('\$${precio.toStringAsFixed(2)}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('\$${subtotal.toStringAsFixed(2)}'),
                            ),
                          ],
                        );
                      }).toList(),
                      // Fila final de total limpia
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFFFF3E0)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Total del pedido:',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          const SizedBox(),
                          const SizedBox(),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              '\$${totalPedido.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.deepOrange,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

