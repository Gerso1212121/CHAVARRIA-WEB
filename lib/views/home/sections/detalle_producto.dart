import 'package:final_project/data/models/productos.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatelessWidget {
  final Producto producto;

  const ProductDetailPage({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(producto.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  producto.urlImagen,
                  height: 200,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              producto.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Categoría
            Text(
              'Categoría: ${producto.categoria}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Precio
            Row(
              children: [
                Text(
                  '\$${producto.precio}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                if (producto.porcentajeDescuento > 0 &&
                    producto.precioAnterior != null)
                  Text(
                    '\$${producto.precioAnterior}',
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),

            if (producto.porcentajeDescuento > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${producto.porcentajeDescuento}% de descuento',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),

            const SizedBox(height: 20),

            // Envío
            if (producto.tieneEnvio)
              const Text(
                '✅ Envío gratuito incluido',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),

            const SizedBox(height: 30),

            // Botón
            Consumer<CartViewModel>(
              builder: (context, cartViewModel, _) {
                final isLoading = cartViewModel.isLoading;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            cartViewModel
                                .agregarProductoAlCarritoYActualizarEstado(
                              context,
                              producto.id,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Agregar al carrito',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
