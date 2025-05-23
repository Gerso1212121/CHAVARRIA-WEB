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
}
