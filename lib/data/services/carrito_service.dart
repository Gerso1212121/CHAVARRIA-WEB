import 'package:final_project/data/models/carrito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<CartItem>> fetchCartItems() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return [];

final response = await supabase
    .from('carrito_items')
    .select('''
      id,
      cantidad,
      productos(id, title, image_url, price),
      carrito!carrito_items_carrito_id_fkey(usuario_id)
    ''')
    .filter('carrito.usuario_id', 'eq', user.id);  // esta es la forma correcta


  return (response as List).where((item) => item['productos'] != null).map((item) {
    final product = item['productos'];
    return CartItem(
      id: item['id'],
      nombre: product['title'] ?? 'Sin nombre',
      imagenUrl: product['image_url'] ?? '',
      cantidad: item['cantidad'],
      precio: (product['price'] as num?)?.toDouble() ?? 0.0,
    );
  }).toList();
}
