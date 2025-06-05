import 'package:final_project/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/views/home/sections/info_producto.dart';
import 'package:final_project/views/home/widgets/animations/custom_chargin.dart';
import 'package:final_project/views/home/widgets/custom_showdialog.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/viewmodels/servicios/favoritos.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductCard extends StatefulWidget {
  final Producto producto;

  const ProductCard({super.key, required this.producto});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    verificarFavorito();
  }

  Future<void> verificarFavorito() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final result = await Supabase.instance.client
        .from('favoritos')
        .select('id_producto')
        .eq('id_cliente', user.id)
        .eq('id_producto', widget.producto.idProducto)
        .maybeSingle();

    if (result != null) {
      setState(() {
        isFavorite = true;
      });
    }
  }

  double get precioConDescuento {
    final p = widget.producto;
    if (p.porcentajeDescuento > 0 && p.precio != null) {
      return p.precio! * (1 - p.porcentajeDescuento / 100);
    }
    return p.precio ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (p.porcentajeDescuento > 0 && p.stock > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-${p.porcentajeDescuento.toInt()}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Debes iniciar sesión para agregar a favoritos')),
                      );
                      return;
                    }

                    await toggleFavorito(user.id, p.idProducto);

                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ],
            ),
          ),

          // Imagen
          Flexible(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(producto: p),
                  ),
                );
              },
              child: Center(
                child: Container(
                  width: isMobile ? double.infinity : 160,
                  height: isMobile ? 200 : 160,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amberAccent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      p.urlImagen ?? '',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 60),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Información
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                Text(
                  p.nombreCategoria ?? 'Sin categoría',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.nombre ?? '',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
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
                          '\$${precioConDescuento.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (p.porcentajeDescuento > 0)
                          Text(
                            '\$${p.precio!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    if (p.tieneEnvio)
                      const Icon(Icons.local_shipping,
                          size: 20, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),

          // Botón "Agregar al carrito"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 152, 34),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
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
                            MaterialPageRoute(builder: (_) => LoginPage()),
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
                final result = await cartVM.agregarProductoDirectoOptimizado(
                  producto: p, // ✅ Este es el correcto
                  cantidad: 1,
                );

                Navigator.of(context).pop();

                String title, message;
                bool isSuccess;

                switch (result) {
                  case AgregadoResultado.yaExiste:
                    title = 'Ya agregado';
                    message = 'Este producto ya se encuentra en tu carrito.';
                    isSuccess = false;
                    break;
                  case AgregadoResultado.sinStock:
                    title = 'Sin stock';
                    message = 'Este producto está agotado actualmente.';
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
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
