import 'package:final_project/data/models/envio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnvioService {
  final _client = Supabase.instance.client;

  Future<List<EnvioModel>> obtenerEnviosPorCliente(String clienteId) async {
    final response = await _client
        .from('envio')
        .select('*, pedido(id_cliente)')
        .eq('pedido.id_cliente', clienteId);

    if (response.isEmpty) return [];

    return response.map((e) => EnvioModel.fromMap(e)).toList();
  }

  Future<EnvioModel?> obtenerEnvioPorPedido(int idPedido) async {
    final data = await _client
        .from('envio')
        .select()
        .eq('id_pedido', idPedido)
        .maybeSingle();

    return data != null ? EnvioModel.fromMap(data) : null;
  }
}
