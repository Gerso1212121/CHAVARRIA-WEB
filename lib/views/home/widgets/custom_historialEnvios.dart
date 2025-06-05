// views/home/widgets/historial_envios.dart
import 'package:final_project/views/home/widgets/custom_envio.dart';
import 'package:flutter/material.dart';
import 'package:final_project/viewmodels/servicios/viewmodel_pedidos.dart';

class HistorialEnvios extends StatelessWidget {
  final String clienteId;

  const HistorialEnvios(this.clienteId, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: obtenerHistorialPedidos(clienteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('📭 No hay envíos disponibles.');
        }

        final pedidos = snapshot.data!;

        return Column(
          children: pedidos.map((pedido) {
            return CardEnvio(idPedido: pedido['id_pedido']);
          }).toList(),
        );
      },
    );
  }
}
