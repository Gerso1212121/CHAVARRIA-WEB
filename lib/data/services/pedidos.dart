import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<List<Map<String, dynamic>>> obtenerPedidosDeCliente(String clienteId) async {
  final response = await supabase
      .from('pedido')
      .select()
      .eq('id_cliente', clienteId)
      .order('fecha', ascending: false);

  return response;
}
