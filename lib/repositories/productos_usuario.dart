import 'package:final_project/data/models/productos.dart';
import 'package:final_project/data/services/products_service.dart';

class ProductRepository {
  final ProductService _productService;

  ProductRepository(this._productService);

  Future<List<Producto>> fetchProducts() async {
    final data = await _productService.getProducts();
    return data.map((map) => Producto.fromMap(map)).toList();
  }

  Future<void> createProduct(Producto producto) async {
    await _productService.addProduct(producto.toMap());
  }

  Future<void> removeProduct(int id) async {
    await _productService.deleteProduct(id);
  }

  Future<void> updateProduct(Producto producto) async {
    await _productService.updateProduct(producto.idProducto, producto.toMap());
  }

  Future<Producto?> getProductById(int id) async {
    final data = await _productService.getProductById(id);
    if (data == null) return null;
    return Producto.fromMap(data);
  }

  Future<List<Producto>> getProductsByCategory(int idCategoria) async {
    final data = await _productService.getProductsByCategory(idCategoria);
    return data.map((map) => Producto.fromMap(map)).toList();
  }
}
