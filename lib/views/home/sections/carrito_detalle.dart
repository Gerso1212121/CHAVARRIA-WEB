import 'dart:ui';
import 'package:final_project/views/home/sections/realizar_compra.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_APPBARUNIVERSAL.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductViewModel>().todosLosProductos;

    return UniversalTopBarWrapper(
      allProducts: productos,
      expandedHeight: 200,
      appBarColor: const Color(0xFF333333),
      flexibleSpace: const SizedBox.shrink(),
      child: Consumer<CartViewModel>(
        builder: (context, cartViewModel, _) {
          final cartItems = cartViewModel.items;
          final isWide = MediaQuery.of(context).size.width > 700;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
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
                if (isWide)
                  _buildWideLayout(context, cartItems, cartViewModel)
                else
                  _buildMobileLayout(context, cartItems, cartViewModel),
                const SizedBox(height: 24),
                const AppFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(
      BuildContext context, List cartItems, CartViewModel cartViewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: cartItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tu carrito está vacío.'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cartItems.map<Widget>((item) {
                      return _buildCartItem(item, cartViewModel);
                    }).toList(),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildResumen(context, cartViewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, List cartItems, CartViewModel cartViewModel) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          ...cartItems
              .map<Widget>((item) => _buildCartItem(item, cartViewModel)),
          const SizedBox(height: 24),
          _buildResumen(context, cartViewModel),
        ],
      ),
    );
  }

  Widget _buildCartItem(dynamic item, CartViewModel cartViewModel) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFCE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.imagenUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imagenUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Precio: \$${item.precio.toStringAsFixed(2)}'),
                    Text(
                        'Subtotal: \$${(item.precio * item.cantidad).toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    Text('Stock disponible: ${item.stock}',
                        style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: item.cantidad > 1
                              ? () async {
                                  await cartViewModel
                                      .decrementarCantidadItem(item.productoId);
                                  setState(() {});
                                }
                              : null,
                        ),
                        Text('${item.cantidad}',
                            style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: item.cantidad < item.stock
                              ? () async {
                                  await cartViewModel
                                      .incrementarCantidadItem(item.productoId);
                                  setState(() {});
                                }
                              : null,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await cartViewModel.eliminarItemDeCarrito(item.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumen(BuildContext context, CartViewModel cartViewModel) {
    final total = cartViewModel.total;
    final cantidad = cartViewModel.cantidad;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalle del pedido',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text('Subtotal: \$${total}'),
          const SizedBox(height: 8),
          Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Divider(),
          // AVISOS IMPORTANTES
          const Text(
            "🚚 El pago del envío se realiza aparte al momento de la entrega.",
            style: TextStyle(fontSize: 13, color: Colors.redAccent),
          ),
          const SizedBox(height: 6),
          const Text(
            "El costo de envío varía entre \$10 y \$30 según la ubicación.",
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            "🛠️ El armado del mueble tiene un costo adicional de \$15 a \$20, dependiendo del tipo de mueble.",
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            "⏰ El tiempo estimado de envío es de 1 mes y medio a 2 meses.",
            style: TextStyle(fontSize: 13),
          ),
          const Divider(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MetodoPagoPage(total: total, cantidad: cantidad),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text("Comprar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
