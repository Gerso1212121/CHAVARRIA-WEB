import 'package:final_project/data/models/productos.dart';
import 'package:flutter/material.dart';
import 'package:final_project/repositories/productos_usuario.dart';
import 'package:final_project/views/home/widgets/custom_showdialog.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductViewModel(this._repository);

  List<Producto> _productos = [];
  List<Producto> get productos => _productos;

  // Productos sin descuento
  List<Producto> get productosSinOferta =>
      _productos.where((p) => p.porcentajeDescuento == 0).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _productos = await _repository.fetchProducts();
    } catch (e) {
      debugPrint('Error al cargar productos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Producto producto) async {
    await _repository.createProduct(producto);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _repository.removeProduct(id);
    await loadProducts();
  }
}
