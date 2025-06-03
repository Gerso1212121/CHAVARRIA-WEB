import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/data/models/carrito.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:final_project/views/home/widgets/custom_APPBARUNIVERSAL.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailPage extends StatelessWidget {
  final Producto producto;

  const ProductDetailPage({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductViewModel>().todosLosProductos;

    return UniversalTopBarWrapper(
      allProducts: productos,
      expandedHeight: 0,
      appBarColor: const Color.fromARGB(255, 51, 51, 51),
      flexibleSpace: const SizedBox.shrink(),
      child: Consumer<CartViewModel>(
        builder: (context, cartVM, _) {
          final isWide = MediaQuery.of(context).size.width > 700;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
                  label: const Text(
                    'Regresar',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    producto.urlImagen ?? '',
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(child: _buildDetails(context)),
                            ],
                          )
                        : Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  producto.urlImagen ?? '',
                                  height: 250,
                                  fit: isWide ? BoxFit.contain : BoxFit.cover,
                                ),
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

  Widget _buildDetails(BuildContext context) {
    final double precioConDescuento =
        (producto.porcentajeDescuento > 0 && producto.precio != null)
            ? producto.precio! * (1 - producto.porcentajeDescuento / 100)
            : producto.precio ?? 0.0;

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
        int contadorLocal = 1;

        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('\$${precioConDescuento.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                    if (producto.porcentajeDescuento > 0 &&
                        producto.precio != null) ...[
                      const SizedBox(width: 12),
                      Text('\$${producto.precio!.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                if (producto.porcentajeDescuento > 0)
                  Chip(
                    label: Text(
                      'Descuento: ${producto.porcentajeDescuento}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                const Divider(height: 30),
                _buildSpecItem('Stock', producto.stock.toString()),
                _buildSpecItem('Categoría', producto.nombreCategoria),
                _buildSpecItem('Dimensiones', producto.dimensiones),
                _buildSpecItem('Peso', '${producto.peso ?? '-'} kg'),
                _buildSpecItem('Código de barras', producto.codigoBarras),
                _buildSpecItem(
                    'Envío gratis', producto.tieneEnvio ? 'Sí' : 'No'),
                const Divider(height: 30),
                const Text('Cantidad a agregar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      onPressed: contadorLocal > 1
                          ? () => setState(() => contadorLocal--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '$contadorLocal',
                        key: ValueKey(contadorLocal),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          contadorLocal < (producto.stock - cantidadActual)
                              ? () => setState(() => contadorLocal++)
                              : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: producto.stock == 0
                          ? Colors.grey
                          : Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: producto.stock == 0
                        ? null
                        : () => _handleAddToCart(
                              context,
                              cartVM,
                              contadorLocal,
                              () => setState(() => contadorLocal = 1),
                            ),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: Text(
                      producto.stock == 0
                          ? 'Producto agotado'
                          : 'Agregar $contadorLocal al carrito',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Descripción',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(producto.descripcion ?? 'Sin descripción disponible.'),
              ],
            ),
          ),
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _handleAddToCart(
    BuildContext context,
    CartViewModel cartVM,
    int cantidad,
    void Function() setState,
  ) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('¡Ups!',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              'Debes iniciar sesión para agregar productos al carrito.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sesión'),
            ),
          ],
        ),
      );
      return;
    }

    final resultado = await cartVM.agregarProductoDirecto(
      productoId: producto.idProducto,
      cantidad: cantidad,
    );

    setState();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              resultado == AgregadoResultado.agregadoNuevo
                  ? Icons.check_circle
                  : resultado == AgregadoResultado.yaExiste
                      ? Icons.info
                      : resultado == AgregadoResultado.sinStock
                          ? Icons.warning_amber
                          : Icons.error,
              color: resultado == AgregadoResultado.agregadoNuevo
                  ? Colors.green
                  : resultado == AgregadoResultado.yaExiste
                      ? Colors.blueGrey
                      : resultado == AgregadoResultado.sinStock
                          ? Colors.orange
                          : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 10),
            Text(
              resultado == AgregadoResultado.agregadoNuevo
                  ? '¡Éxito!'
                  : resultado == AgregadoResultado.yaExiste
                      ? 'Ya agregado'
                      : resultado == AgregadoResultado.sinStock
                          ? 'Sin stock'
                          : 'Error',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          resultado == AgregadoResultado.agregadoNuevo
              ? 'Producto agregado al carrito.'
              : resultado == AgregadoResultado.yaExiste
                  ? 'Este producto ya está en tu carrito.'
                  : resultado == AgregadoResultado.sinStock
                      ? 'No hay suficiente stock para agregar este producto.'
                      : 'Ocurrió un error al agregar el producto.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar')),
        ],
      ),
    );
  }
}
