import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> obtenerHistorialPedidos(
    String clienteId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('pedido').select('''
  id_pedido,
  fecha,
  monto_total,
  detallepedido (
    cantidad,
    precio_unitario,
    subtotal,
    producto!fk_detallepedido_producto (
      nombre
    )
  )
''').eq('id_cliente', clienteId).order('fecha', ascending: false);

  if (response is List) {
    return response.cast<Map<String, dynamic>>();
  }

  return [];
}
