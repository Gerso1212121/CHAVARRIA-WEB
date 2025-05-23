import 'package:final_project/data/models/carrito.dart';
import 'package:final_project/views/home/widgets/custom_showdialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get total => _items.fold(0, (sum, item) => sum + item.total);

  Future<void> loadItemsFromSupabase() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final response = await supabase.from('carrito_items').select('''
        id,
        cantidad,
        productos(id, nombre, url_imagen, precio),
        carrito!carrito_items_carrito_id_fkey(usuario_id)
      ''').filter('carrito.usuario_id', 'eq', user.id);

    final data = response as List;

    _items.clear();
    _items.addAll(data.where((item) => item['productos'] != null).map((item) {
      final product = item['productos'];
      return CartItem(
        id: item['id'],
        nombre: product['nombre'] ?? 'Sin nombre',
        imagenUrl: product['url_imagen'] ?? '',
        cantidad: item['cantidad'],
        precio: (product['precio'] as num?)?.toDouble() ?? 0.0,
      );
    }));
    notifyListeners();
  }

  // Otros métodos como agregarProducto, eliminarProducto, etc.
bool _isLoading = false;
bool get isLoading => _isLoading;

void _setLoading(bool value) {
  _isLoading = value;
  notifyListeners();
}

Future<void> agregarProductoAlCarritoYActualizarEstado(
    BuildContext context, int productoId) async {
  if (_isLoading) return; // Prevenir múltiples clics

  _setLoading(true);
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    _setLoading(false);
    showFeedbackDialog(
      context: context,
      title: 'Inicia sesión',
      message: 'Debes iniciar sesión para agregar productos al carrito.',
      isSuccess: false,
    );
    return;
  }

  try {
    final producto = await supabase
        .from('productos')
        .select()
        .eq('id', productoId)
        .maybeSingle();

    if (producto == null) {
      _setLoading(false);
      showFeedbackDialog(
        context: context,
        title: 'Producto no encontrado',
        message: 'El producto que intentas agregar no está registrado.',
        isSuccess: false,
      );
      return;
    }

    final carrito = await supabase
        .from('carrito')
        .select()
        .eq('usuario_id', user.id)
        .maybeSingle();

    int carritoId;
    if (carrito == null) {
      final nuevoCarrito = await supabase
          .from('carrito')
          .insert({'usuario_id': user.id})
          .select()
          .single();
      carritoId = nuevoCarrito['id'];
    } else {
      carritoId = carrito['id'];
    }

    final itemExistente = await supabase
        .from('carrito_items')
        .select()
        .eq('carrito_id', carritoId)
        .eq('producto_id', productoId)
        .maybeSingle();

    if (itemExistente != null) {
      await supabase.from('carrito_items').update({
        'cantidad': itemExistente['cantidad'] + 1,
      }).eq('id', itemExistente['id']);
    } else {
      await supabase.from('carrito_items').insert({
        'carrito_id': carritoId,
        'producto_id': productoId,
        'cantidad': 1,
      });
    }

    await loadItemsFromSupabase();

    showFeedbackDialog(
      context: context,
      title: '¡Agregado!',
      message: 'El producto se agregó correctamente al carrito.',
      isSuccess: true,
    );
  } catch (e) {
    showFeedbackDialog(
      context: context,
      title: 'Error',
      message: 'No se pudo agregar al carrito: $e',
      isSuccess: false,
    );
  }

  _setLoading(false);
}


  void eliminarProducto(int id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void incrementarCantidad(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].cantidad++;
      notifyListeners();
    }
  }

  void decrementarCantidad(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1 && _items[index].cantidad > 1) {
      _items[index].cantidad--;
      notifyListeners();
    }
  }

  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }
}
