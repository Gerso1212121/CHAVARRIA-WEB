import 'package:final_project/data/models/productos.dart';
import 'package:final_project/repositories/productos_usuario.dart';
import 'package:flutter/material.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductViewModel(this._repository);

  List<Producto> _todos = [];
  List<Producto> _visibles = [];
  List<Producto> get productos => _visibles;
  List<Producto> get todosLosProductos => _todos;

  List<Producto> get productosSinOferta =>
      _visibles.where((p) => p.porcentajeDescuento == 0).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _repository.fetchProducts();
      _visibles = [..._todos];
    } catch (e) {
      debugPrint('Error al cargar productos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    await _repository.removeProduct(id);
    await loadProducts();
  }

  void buscar(String query) {
    final texto = query.toLowerCase().trim();

    if (texto.isEmpty) {
      _visibles = [..._todos];
    } else {
      _visibles = _todos.where((p) {
        final nombre = p.nombre.toLowerCase();
        final categoria = p.nombreCategoria?.toLowerCase() ?? '';
        return nombre.contains(texto) || categoria.contains(texto);
      }).toList();
    }

    notifyListeners();
  }

  List<String> obtenerCategorias() {
    final categorias = _todos
        .map((p) => p.nombreCategoria ?? 'Sin categoría')
        .toSet()
        .toList();
    categorias.sort();
    return categorias;
  }

  List<Producto> filtrarProductos({String? categoria, String? ordenPrecio}) {
    List<Producto> filtrados = [..._todos];

    if (categoria != null && categoria.isNotEmpty) {
      filtrados = filtrados
          .where((producto) =>
              (producto.nombreCategoria ?? '').toLowerCase() ==
              categoria.toLowerCase())
          .toList();
    }

    if (ordenPrecio != null) {
      if (ordenPrecio == 'asc') {
        filtrados.sort((a, b) => (a.precio ?? 0).compareTo(b.precio ?? 0));
      } else if (ordenPrecio == 'desc') {
        filtrados.sort((a, b) => (b.precio ?? 0).compareTo(a.precio ?? 0));
      }
    }

    return filtrados;
  }
}
