class EnvioModel {
  final int idEnvio;
  final int idPedido;
  final String direccionEntrega;
  final DateTime? fechaEnvio;
  final DateTime? fechaEstimada;
  final String estado;
  final String? observaciones;

  EnvioModel({
    required this.idEnvio,
    required this.idPedido,
    required this.direccionEntrega,
    this.fechaEnvio,
    this.fechaEstimada,
    required this.estado,
    this.observaciones,
  });

  factory EnvioModel.fromMap(Map<String, dynamic> map) {
    return EnvioModel(
      idEnvio: map['id_envio'],
      idPedido: map['id_pedido'],
      direccionEntrega: map['direccion_entrega'] ?? '',
      fechaEnvio: map['fecha_envio'] != null ? DateTime.tryParse(map['fecha_envio']) : null,
      fechaEstimada: map['fecha_estimada'] != null ? DateTime.tryParse(map['fecha_estimada']) : null,
      estado: map['estado'] ?? 'Pendiente',
      observaciones: map['observaciones'],
    );
  }
}
