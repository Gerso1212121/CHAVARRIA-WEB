import 'package:supabase_flutter/supabase_flutter.dart';

//////  funciones de productService      /////////

class ProductService {
  final supabase = Supabase.instance.client;

  /// Obtener todos los productos
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await supabase.from('productos').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error inesperado al obtener productos: $e');
    }
  }

  /// Agregar un nuevo producto
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await supabase.from('productos').insert(productData);
    } catch (e) {
      throw Exception('Error inesperado al agregar producto: $e');
    }
  }

  /// Eliminar producto por id
  Future<void> deleteProduct(int productId) async {
    try {
      await supabase.from('productos').delete().eq('id', productId);
    } catch (e) {
      throw Exception('Error inesperado al eliminar producto: $e');
    }
  }
}
