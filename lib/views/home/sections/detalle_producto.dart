import 'package:final_project/data/models/carrito.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/sections/productos.dart';
import 'package:final_project/views/home/sections/realizar%20compra.dart';
import 'package:final_project/views/home/widgets/custom_APPBARUNIVERSAL.dart';
import 'package:final_project/views/home/widgets/custom_appBar_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailPage extends StatelessWidget {
  final Producto producto;

  const ProductDetailPage({Key? key, required this.producto}) : super(key: key);

  static const Color naranja = Color(0xFFF57C00);
  static const Color marronClaro = Color(0xFF8D6E63);
  static const Color marronOscuro = Color(0xFF6D4C41);
  static const Color beige = Color(0xFFFDFCE5);

  double? get precioAnterior {
    if (producto.porcentajeDescuento > 0 && producto.precio != null) {
      return producto.precio! / (1 - producto.porcentajeDescuento / 100);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductViewModel>().todosLosProductos;

    return UniversalTopBarWrapper(
      allProducts: productos,
      expandedHeight: 0,
      appBarColor: const Color(0xFF333333),
      flexibleSpace: const SizedBox.shrink(),
      child: Consumer<CartViewModel>(
        // ✅ Aquí el cambio
        builder: (context, cartViewModel, _) {
          final cartItems = cartViewModel.items;
          final isWide = MediaQuery.of(context).size.width > 700;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.orange),
                  label: const Text(
                    'Regresar',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.maxWidth > 700
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  producto.urlImagen ?? '',
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(child: _buildDetails(context)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                producto.urlImagen ?? '',
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(height: 16),
                              _buildDetails(context),
                            ],
                          );
                  },
                ),
                const SizedBox(height: 24),
                const AppFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

// Dentro de _buildDetails(context)
  Widget _buildDetails(BuildContext context) {
    final cartVM = context.watch<CartViewModel>();

    return StatefulBuilder(
      builder: (context, setState) {
        final itemEnCarrito = cartVM.items.firstWhere(
          (item) => item.productoId == producto.idProducto,
          orElse: () => CartItem(
            id: 0,
            productoId: producto.idProducto,
            nombre: producto.nombre,
            cantidad: 0,
            precio: producto.precio ?? 0,
            imagenUrl: producto.urlImagen ?? '',
            stock: producto.stock,
          ),
        );

        int cantidadActual = itemEnCarrito.cantidad;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              producto.nombre,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${producto.precio?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 22, color: Colors.green),
                ),
                const SizedBox(width: 10),
                if (precioAnterior != null)
                  Text(
                    '\$${precioAnterior!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Stock disponible: ${producto.stock}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (producto.porcentajeDescuento > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Descuento: ${producto.porcentajeDescuento}%',
                  style: const TextStyle(fontSize: 16, color: Colors.redAccent),
                ),
              ),
            const Divider(height: 32),
            const Text(
              'Descripción del producto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(producto.descripcion ?? 'Sin descripción.',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text(
              'Especificaciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSpecItem('Categoría', producto.nombreCategoria),
            _buildSpecItem('Dimensiones', producto.dimensiones),
            _buildSpecItem(
                'Peso', producto.peso != null ? '${producto.peso} kg' : null),
            _buildSpecItem('Código de barras', producto.codigoBarras),
            _buildSpecItem('Envío gratis', producto.tieneEnvio ? 'Sí' : 'No'),
            const SizedBox(height: 24),
            const Text('Cantidad',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  onPressed: cantidadActual > 0
                      ? () async {
                          await cartVM
                              .decrementarCantidadItem(producto.idProducto);
                          setState(() {});
                        }
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$cantidadActual', style: const TextStyle(fontSize: 18)),
                IconButton(
                  onPressed: cantidadActual < producto.stock
                      ? () async {
                          if (cantidadActual == 0) {
                            await cartVM.agregarProductoDirecto(
                              productoId: producto.idProducto,
                              cantidad: 1,
                            );
                          } else {
                            await cartVM
                                .incrementarCantidadItem(producto.idProducto);
                          }
                          setState(() {});
                        }
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: cantidadActual > 0
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MetodoPagoPage(total: cartVM.total),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Ir a pagar', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecItem(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
