import 'package:final_project/data/models/envio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/data/services/envio.dart';

class CardEnvio extends StatelessWidget {
  final int idPedido;

  const CardEnvio({super.key, required this.idPedido});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EnvioModel?>(
      future: EnvioService().obtenerEnvioPorPedido(idPedido),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink(); // No mostrar nada si no hay envío
        }

        final envio = snapshot.data!;
        final colorEstado = envio.estado == 'Entregado'
            ? Colors.green
            : envio.estado == 'En proceso'
                ? Colors.orange
                : Colors.red;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(top: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorEstado.withOpacity(0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_shipping, color: colorEstado),
                    const SizedBox(width: 8),
                    Text(
                      'Estado: ${envio.estado}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorEstado,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (envio.fechaEstimada != null)
                  Text(
                    '📅 Fecha estimada: ${DateFormat('dd/MM/yyyy').format(envio.fechaEstimada!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                if (envio.direccionEntrega != null)
                  Text(
                    '📍 Dirección: ${envio.direccionEntrega}',
                    style: const TextStyle(fontSize: 14),
                  ),
                if (envio.observaciones != null &&
                    envio.observaciones!.isNotEmpty)
                  Text(
                    '📝 Observaciones: ${envio.observaciones}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
