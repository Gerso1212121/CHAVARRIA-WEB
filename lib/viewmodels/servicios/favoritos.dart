import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> toggleFavorito(String idCliente, int idProducto) async {
  final supabase = Supabase.instance.client;

  try {
    final existing = await supabase
        .from('favoritos')
        .select()
        .eq('id_cliente', idCliente)
        .eq('id_producto', idProducto)
        .maybeSingle();

    if (existing != null) {
      // Eliminar favorito existente
      await supabase
          .from('favoritos')
          .delete()
          .eq('id_cliente', idCliente)
          .eq('id_producto', idProducto);

      return false; // ❌ Ya no es favorito
    } else {
      // Insertar nuevo favorito
      await supabase.from('favoritos').insert({
        'id_cliente': idCliente,
        'id_producto': idProducto,
      });

      return true; // ✅ Ahora es favorito
    }
  } catch (e) {
    print('❌ Error en toggleFavorito: $e');
    rethrow;
  }
}
