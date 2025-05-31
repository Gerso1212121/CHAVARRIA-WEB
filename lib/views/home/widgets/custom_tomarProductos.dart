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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: productosParaMostrar.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final producto = productosParaMostrar[index];
        return ProductCard(producto: producto);
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
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // OFERTA + CORAZÓN
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (p.porcentajeDescuento > 0 && p.stock > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.yellow[700],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'OFERTA ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: '${p.porcentajeDescuento}%',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 4, right: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          // Imagen clickeable
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 140,
                        width: 140,
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Image.network(
                        p.urlImagen ?? '',
                        height: 160,
                        width: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 60),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Info del producto
          Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.brown.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        p.nombreCategoria ?? 'Sin categoría',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    if (p.tieneEnvio)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.local_shipping_outlined,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC7521),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
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
                        title: 'Inicia sesión',
                        message: 'Debes iniciar sesión para agregar productos al carrito.',
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
                                MaterialPageRoute(builder: (_) => LoginPage()),
                              );
                            },
                            child: const Text('Inicia aquí', style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      );
                      return;
                    }

                    final cartVM = Provider.of<CartViewModel>(context, listen: false);
                    final result = await cartVM.agregarProductoDirecto(productoId: p.idProducto);

                    Navigator.of(context).pop();

                    String title, message;
                    bool isSuccess;

                    switch (result) {
                      case AgregadoResultado.yaExiste:
                        title = 'Producto ya en carrito';
                        message = 'Este producto ya fue agregado previamente.';
                        isSuccess = false;
                        break;
                      case AgregadoResultado.sinStock:
                        title = 'Sin stock';
                        message = 'Este producto no tiene stock disponible.';
                        isSuccess = false;
                        break;
                      case AgregadoResultado.error:
                        title = 'Error';
                        message = 'Ocurrió un error al agregar el producto.';
                        isSuccess = false;
                        break;
                      default:
                        title = '¡Agregado!';
                        message = 'El producto fue agregado a tu carrito.';
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
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                  child: const Text(
                    'Agregar al carrito',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
