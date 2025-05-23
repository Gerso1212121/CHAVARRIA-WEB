import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  /// Iniciar sesión con correo y contraseña
  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Registro de nuevo usuario
  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Error al registrarse: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      final response = await supabase.auth.signOut();
      print('CERRASTE SESIÓN CORRECTAMENTE');
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// Obtener usuario actual (si está logueado)
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Verificar si la sesión está activa
  Future<bool> isSessionActive() async {
    final session = supabase.auth.currentSession;
    return session != null;
  }
}

//////  funciones de productService      /////////

class ProductService {
  final supabase = Supabase.instance.client;

  /// Obtener todos los productos
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await supabase.from('products').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error inesperado al obtener productos: $e');
    }
  }

  /// Agregar un nuevo producto
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await supabase.from('products').insert(productData);
    } catch (e) {
      throw Exception('Error inesperado al agregar producto: $e');
    }
  }

  /// Eliminar producto por id
  Future<void> deleteProduct(int productId) async {
    try {
      await supabase.from('products').delete().eq('id', productId);
    } catch (e) {
      throw Exception('Error inesperado al eliminar producto: $e');
    }
  }
}
