import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/data/models/carrito.dart';

enum AgregadoResultado {
  agregadoNuevo,
  yaExiste,
  sinStock,
  error,
}

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  bool cargadoInicial = false;

  double get total => _items.fold(0, (sum, item) => sum + item.total);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  VoidCallback? onCerrarSesion;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> _getOrCreateCarritoId(String userId) async {
    final supabase = Supabase.instance.client;

    final existing = await supabase
        .from('carrito')
        .select('id_carrito')
        .eq('usuario_id', userId)
        .maybeSingle();

    if (existing != null) {
      return existing['id_carrito']?.toString();
    }

    final inserted = await supabase
        .from('carrito')
        .insert({'usuario_id': userId})
        .select('id_carrito')
        .maybeSingle();

    return inserted?['id_carrito']?.toString();
  }

  Future<void> loadItemsFromSupabase({bool inicial = false}) async {
    if (inicial) _setLoading(true);

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (inicial) _setLoading(false);
      return;
    }

    final carritoId = await _getOrCreateCarritoId(user.id);
    if (carritoId == null) {
      if (inicial) _setLoading(false);
      return;
    }

    final response = await supabase.from('carrito_items').select('''
      id,
      producto:producto_id(id_producto,nombre,url_imagen,precio,stock)
    ''').eq('carrito_id', carritoId);

    final data = response as List;

    _items.clear();
    for (final item in data) {
      final p = item['producto'];
      if (p == null) continue;

      _items.add(
        CartItem(
          id: item['id'],
          productoId: p['id_producto'],
          nombre: p['nombre'],
          cantidad: 1,
          precio: (p['precio'] as num).toDouble(),
          imagenUrl: p['url_imagen'] ?? "",
          stock: p['stock'] ?? 0,
        ),
      );
    }

    cargadoInicial = true;
    notifyListeners();

    if (inicial) _setLoading(false);
  }

  Future<AgregadoResultado?> agregarProductoDirecto({
    required int productoId,
    int cantidad = 1,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return AgregadoResultado.error;

    final carritoId = await _getOrCreateCarritoId(user.id);
    if (carritoId == null) return AgregadoResultado.error;

    final producto = await supabase
        .from('producto')
        .select('id_producto,nombre,stock,precio,url_imagen')
        .eq('id_producto', productoId)
        .maybeSingle();

    if (producto == null || (producto['stock'] ?? 0) <= 0) {
      return AgregadoResultado.sinStock;
    }

    final stockDisponible = producto['stock'] as int;
    if (cantidad > stockDisponible) return AgregadoResultado.sinStock;

    final itemExistente = await supabase
        .from('carrito_items')
        .select('id, cantidad')
        .eq('carrito_id', carritoId)
        .eq('producto_id', productoId)
        .maybeSingle();

    if (itemExistente != null) {
      final nuevaCantidad = (itemExistente['cantidad'] as int) + cantidad;
      if (nuevaCantidad > stockDisponible) return AgregadoResultado.sinStock;

      await supabase
          .from('carrito_items')
          .update({'cantidad': nuevaCantidad}).eq('id', itemExistente['id']);

      final index = _items.indexWhere((i) => i.productoId == productoId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(cantidad: nuevaCantidad);
      }
      notifyListeners();
      return AgregadoResultado.yaExiste;
    }

    final inserted = await supabase
        .from('carrito_items')
        .insert({
          'carrito_id': carritoId,
          'producto_id': productoId,
          'cantidad': cantidad,
        })
        .select('id')
        .maybeSingle();

    _items.add(CartItem(
      id: inserted?['id'],
      productoId: producto['id_producto'],
      nombre: producto['nombre'],
      cantidad: cantidad,
      precio: (producto['precio'] as num).toDouble(),
      imagenUrl: producto['url_imagen'] ?? "",
      stock: producto['stock'] ?? 0,
    ));
    notifyListeners();
    return AgregadoResultado.agregadoNuevo;
  }

  Future<void> eliminarItemDeCarrito(int itemId) async {
    final supabase = Supabase.instance.client;
    await supabase.from('carrito_items').delete().eq('id', itemId);
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }

  Future<void> limpiarCarritoRemoto() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final carritoId = await _getOrCreateCarritoId(user.id);
    if (carritoId == null) return;

    await supabase.from('carrito_items').delete().eq('carrito_id', carritoId);
    limpiarCarrito();
  }

  Future<void> cerrarSesion() async {
    await Supabase.instance.client.auth.signOut();
    limpiarCarrito();
    onCerrarSesion?.call();
  }

  Future<void> incrementarCantidadItem(int productoId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final carritoId = await _getOrCreateCarritoId(user.id);
    if (carritoId == null) return;

    final index = _items.indexWhere((i) => i.productoId == productoId);
    if (index == -1) return;

    final item = _items[index];
    if (item.cantidad + 1 > item.stock) return; // No pasar del stock disponible

    final nuevaCantidad = item.cantidad + 1;

    await supabase
        .from('carrito_items')
        .update({'cantidad': nuevaCantidad})
        .eq('carrito_id', carritoId)
        .eq('producto_id', productoId);

    _items[index] = item.copyWith(cantidad: nuevaCantidad);
    notifyListeners();
  }

  Future<void> decrementarCantidadItem(int productoId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final carritoId = await _getOrCreateCarritoId(user.id);
    if (carritoId == null) return;

    final index = _items.indexWhere((i) => i.productoId == productoId);
    if (index == -1) return;

    final item = _items[index];
    if (item.cantidad <= 1) return; // Evita que baje de 1

    final nuevaCantidad = item.cantidad - 1;

    await supabase
        .from('carrito_items')
        .update({'cantidad': nuevaCantidad})
        .eq('carrito_id', carritoId)
        .eq('producto_id', productoId);

    _items[index] = item.copyWith(cantidad: nuevaCantidad);
    notifyListeners();
  }

  decrementarItemCantidad(int idProducto) {}
}
