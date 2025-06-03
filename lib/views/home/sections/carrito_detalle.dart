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
      expandedHeight: 20,
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
                      return _buildCartItem(context, item, cartViewModel);
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
          ...cartItems.map<Widget>(
              (item) => _buildCartItem(context, item, cartViewModel)),
          const SizedBox(height: 24),
          _buildResumen(context, cartViewModel),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, dynamic item, CartViewModel cartViewModel) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imagenUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text("Precio: \$${item.precio.toStringAsFixed(2)}"),
                    Text(
                        "Subtotal: \$${(item.precio * item.cantidad).toStringAsFixed(2)}"),
                    if (item.stock < 5)
                      Text("\u00a1Solo ${item.stock} disponibles!",
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCantidadButton(
                          icon: Icons.remove,
                          onPressed: () async {
                            if (item.cantidad == 1) {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("\u00bfEliminar producto?"),
                                  content: const Text(
                                      "\u00bfDeseas eliminar este producto del carrito?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancelar"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("Eliminar"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmar == true) {
                                await cartViewModel
                                    .eliminarItemDeCarrito(item.id);
                              }
                            } else {
                              await cartViewModel
                                  .decrementarCantidadItem(item.productoId);
                            }
                            setState(() {});
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('${item.cantidad}',
                              style: const TextStyle(fontSize: 16)),
                        ),
                        _buildCantidadButton(
                          icon: Icons.add,
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

  Widget _buildCantidadButton(
      {required IconData icon, required VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            onPressed != null ? Colors.orange.shade100 : Colors.grey.shade300,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.orange[800]),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildResumen(BuildContext context, CartViewModel cartViewModel) {
    final total = cartViewModel.total;
    final cantidad = cartViewModel.cantidad;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.receipt_long_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Resumen de compra',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cantidad:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                '${cantidad}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Text(
            "🚚 El envío se paga al recibir. Varía entre \$10 y \$30.",
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            "🛠️ Armado entre \$15 y \$20. Se coordina al entregar.",
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            "⏰ Envío estimado: 1.5 - 2 meses.",
            style: TextStyle(fontSize: 13),
          ),
          const Divider(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                const montoMinimo = 0.10;
                if (total < montoMinimo) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      title: const Text('Monto insuficiente'),
                      content: Text(
                          'El total debe ser mayor a \$${montoMinimo.toStringAsFixed(2)} para continuar.'),
                      actions: [
                        TextButton(
                          child: const Text('Aceptar'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MetodoPagoPage(
                      total: total,
                      cantidad: cantidad,
                    ),
                  ),
                );
              },
              icon:
                  const Icon(Icons.shopping_cart_checkout, color: Colors.white),
              label: const Text(
                "Finalizar compra",
                style: TextStyle(
                  color: Colors.white, // 👈 Texto blanco
                  fontWeight: FontWeight.bold, // 👈 Negrita
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
