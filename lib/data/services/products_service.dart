import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  /// Obtener todos los productos con el nombre de la categoría
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await supabase
          .from('producto')
          .select('*, categoria (nombre)');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error inesperado al obtener productos: $e');
    }
  }

  /// Agregar un nuevo producto
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await supabase.from('producto').insert(productData);
    } catch (e) {
      throw Exception('Error inesperado al agregar producto: $e');
    }
  }

  /// Eliminar producto por id_producto
  Future<void> deleteProduct(int productId) async {
    try {
      await supabase.from('producto').delete().eq('id_producto', productId);
    } catch (e) {
      throw Exception('Error inesperado al eliminar producto: $e');
    }
  }

  /// Actualizar producto
  Future<void> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      await supabase.from('producto').update(productData).eq('id_producto', productId);
    } catch (e) {
      throw Exception('Error inesperado al actualizar producto: $e');
    }
  }

  /// Obtener producto por ID con el nombre de la categoría
  Future<Map<String, dynamic>?> getProductById(int id) async {
    try {
      final response = await supabase
          .from('producto')
          .select('*, categoria (nombre)')
          .eq('id_producto', id)
          .single();
      return response;
    } catch (e) {
      throw Exception('Error al obtener producto por ID: $e');
    }
  }

  /// Obtener productos por categoría
  Future<List<Map<String, dynamic>>> getProductsByCategory(int idCategoria) async {
    try {
      final response = await supabase
          .from('producto')
          .select('*, categoria (nombre)')
          .eq('id_categoria', idCategoria);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }
}
