import 'package:final_project/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/sections/info_producto.dart';
import 'package:final_project/views/home/widgets/animations/custom_chargin.dart';
import 'package:final_project/views/home/widgets/custom_showdialog.dart';

class Catalogos extends StatelessWidget {
  const Catalogos({super.key});

  @override
  Widget build(BuildContext context) {
    final productosVM = Provider.of<ProductViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (productosVM.isLoading) {
      return const Center(child: FullScreenLoader());
    }

    final productosParaMostrar =
        productosVM.obtenerProductosParaVista(isMobile: isMobile);

    if (productosParaMostrar.isEmpty) {
      return const Center(child: Text("No hay productos disponibles."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileLayout = constraints.maxWidth < 600;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productosParaMostrar.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobileLayout ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final producto = productosParaMostrar[index];
            return ProductCard(producto: producto);
          },
        );
      },
    );
  }
}

class ProductCard extends StatefulWidget {
  final Producto producto;

  const ProductCard({super.key, required this.producto});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  double? get precioAnterior {
    final p = widget.producto;
    if (p.porcentajeDescuento > 0 && p.precio != null) {
      return p.precio! / (1 - p.porcentajeDescuento / 100);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final cardWidth = isMobile ? screenWidth * 0.9 : 220;

    return Container(
      width: cardWidth.toDouble(),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (p.porcentajeDescuento > 0 && p.stock > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    '-${p.porcentajeDescuento.toInt()}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  setState(() => isFavorite = !isFavorite);
                },
              ),
            ],
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(producto: p),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        p.urlImagen ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nombreCategoria ?? 'Sin categoría',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.nombre ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${p.precio?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (precioAnterior != null)
                          Text(
                            '\$${precioAnterior!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    if (p.tieneEnvio)
                      const Icon(
                        Icons.local_shipping,
                        size: 20,
                        color: Colors.green,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const FullScreenLoader(),
                      );

                      final isLoggedIn = await verificarSesionActiva();
                      if (!isLoggedIn) {
                        Navigator.of(context).pop();
                        showFeedbackDialog(
                          context: context,
                          title: 'Acceso requerido',
                          message: 'Por favor inicia sesión para continuar.',
                          isSuccess: false,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LoginPage()),
                                );
                              },
                              child: const Text('Iniciar sesión'),
                            ),
                          ],
                        );
                        return;
                      }

                      final cartVM =
                          Provider.of<CartViewModel>(context, listen: false);
                      final result = await cartVM.agregarProductoDirecto(
                          productoId: p.idProducto);

                      Navigator.of(context).pop();

                      String title, message;
                      bool isSuccess;

                      switch (result) {
                        case AgregadoResultado.yaExiste:
                          title = 'Ya agregado';
                          message =
                              'Este producto ya se encuentra en tu carrito.';
                          isSuccess = false;
                          break;
                        case AgregadoResultado.sinStock:
                          title = 'Sin stock';
                          message =
                              'Este producto está agotado actualmente.';
                          isSuccess = false;
                          break;
                        case AgregadoResultado.error:
                          title = 'Error';
                          message =
                              'No se pudo agregar el producto. Intenta de nuevo.';
                          isSuccess = false;
                          break;
                        default:
                          title = 'Producto agregado';
                          message =
                              'El producto se ha añadido a tu carrito correctamente.';
                          isSuccess = true;
                      }

                      showFeedbackDialog(
                        context: context,
                        title: title,
                        message: message,
                        isSuccess: isSuccess,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                    child: const Text(
                      'Agregar al carrito',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
