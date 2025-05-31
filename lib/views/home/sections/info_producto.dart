import 'package:final_project/data/models/carrito.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/sections/catalogos.dart';
import 'package:final_project/views/home/sections/realizar_compra.dart';
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

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.nombre,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '\$${producto.precio?.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, color: Colors.green),
                  ),
                  if (precioAnterior != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      '\$${precioAnterior!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.inventory_2, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Stock: ${producto.stock}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              if (producto.porcentajeDescuento > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Chip(
                    label: Text(
                      'Descuento: ${producto.porcentajeDescuento}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              const Divider(height: 32),

              /// Cantidad
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '$cantidadActual',
                      key: ValueKey(cantidadActual),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
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

              const SizedBox(height: 20),

              /// Botón de pago
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final supabase = Supabase.instance.client;
                      final user = supabase.auth.currentUser;

                      if (user == null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: const Text('¡Ups!',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              content: const Text(
                                  'Debes iniciar sesión para agregar productos al carrito.'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  icon: const Icon(Icons.login),
                                  label: const Text('Iniciar sesión'),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Cierra el diálogo
                                    Navigator.pushNamed(context, '/login');
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      final resultado = await cartVM.agregarProductoDirecto(
                        productoId: producto.idProducto,
                        cantidad: 1,
                      );

                      setState(() {}); // actualiza cantidad en la vista

                      String titulo;
                      String mensaje;
                      Icon icono;

                      switch (resultado) {
                        case AgregadoResultado.agregadoNuevo:
                          titulo = '¡Éxito!';
                          mensaje = 'Producto agregado al carrito.';
                          icono = const Icon(Icons.check_circle,
                              color: Colors.green, size: 48);
                          break;
                        case AgregadoResultado.yaExiste:
                          titulo = 'Ya agregado';
                          mensaje = 'Este producto ya está en tu carrito.';
                          icono = const Icon(Icons.info,
                              color: Colors.blueGrey, size: 48);
                          break;
                        case AgregadoResultado.sinStock:
                          titulo = 'Sin stock';
                          mensaje =
                              'No hay suficiente stock para agregar este producto.';
                          icono = const Icon(Icons.warning_amber,
                              color: Colors.orange, size: 48);
                          break;
                        default:
                          titulo = 'Error';
                          mensaje = 'Ocurrió un error al agregar el producto.';
                          icono = const Icon(Icons.error,
                              color: Colors.red, size: 48);
                      }

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: Row(
                              children: [
                                icono,
                                const SizedBox(width: 12),
                                Text(titulo,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            content: Text(mensaje),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Agregar al carrito',
                        style: TextStyle(fontSize: 18)),
                  )),

              const SizedBox(height: 32),

              /// Descripción
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Descripción del producto',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(producto.descripcion ??
                          'Sin descripción disponible.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Especificaciones
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Especificaciones',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildSpecItem('Categoría', producto.nombreCategoria),
                      _buildSpecItem('Dimensiones', producto.dimensiones),
                      _buildSpecItem('Peso',
                          producto.peso != null ? '${producto.peso} kg' : null),
                      _buildSpecItem('Código de barras', producto.codigoBarras),
                      _buildSpecItem(
                          'Envío gratis', producto.tieneEnvio ? 'Sí' : 'No'),
                    ],
                  ),
                ),
              ),
            ],
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
