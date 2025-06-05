import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/data/models/productos.dart';
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
    final isWide = MediaQuery.of(context).size.width > 700;

    return UniversalTopBarWrapper(
      allProducts: productos,
      expandedHeight: 0,
      appBarColor: const Color.fromARGB(255, 51, 51, 51),
      flexibleSpace: const SizedBox.shrink(),
      child: SingleChildScrollView(
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
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            producto.urlImagen ?? '',
                            height: 400,
                            fit: BoxFit.contain,
                            semanticLabel: producto.nombre,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: ProductDetailsCard(producto: producto)),
                    ],
                  )
                : Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          producto.urlImagen ?? '',
                          height: 250,
                          fit: BoxFit.contain,
                          semanticLabel: producto.nombre,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProductDetailsCard(producto: producto),
                    ],
                  ),
            const SizedBox(height: 24),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsCard extends StatefulWidget {
  final Producto producto;

  const ProductDetailsCard({super.key, required this.producto});

  @override
  State<ProductDetailsCard> createState() => _ProductDetailsCardState();
}

class _ProductDetailsCardState extends State<ProductDetailsCard> {
  int contadorLocal = 1;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final cartVM = context.read<CartViewModel>(); // ⚡ optimized

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              producto.nombre,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '\$${producto.precioFinal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                if (producto.porcentajeDescuento > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      '\$${producto.precio!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
              ],
            ),
            if (producto.porcentajeDescuento > 0)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Chip(
                  label:
                      Text('Descuento', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.redAccent,
                ),
              ),
            const Divider(height: 30, thickness: 1),
            const Text(
              'Especificaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSpecItem('Stock', producto.stock.toString()),
            _buildSpecItem('Categoría', producto.nombreCategoria),
            _buildSpecItem('Dimensiones', producto.dimensiones),
            _buildSpecItem('Peso', '${producto.peso ?? '-'} kg'),
            _buildSpecItem('Código de barras', producto.codigoBarras),
            _buildSpecItem('Envío gratis', producto.tieneEnvio ? 'Sí' : 'No'),
            const Divider(height: 30, thickness: 1),

            // 🛒 BOTÓN AGREGAR AL CARRITO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (producto.stock == 0 || isProcessing)
                    ? null
                    : () async {
                        setState(() => isProcessing = true);
                        await _handleAddToCart(context, cartVM, producto);
                        setState(() => isProcessing = false);
                      },
                icon: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add_shopping_cart_rounded),
                label: Text(
                  isProcessing
                      ? 'Procesando...'
                      : (producto.stock == 0
                          ? 'Producto agotado'
                          : 'Agregar $contadorLocal al carrito'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (producto.stock == 0 || isProcessing)
                      ? Colors.grey
                      : const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              producto.descripcion ?? 'Sin descripción disponible.',
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
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
      BuildContext context, CartViewModel cartVM, Producto producto) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      await showDialog(
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

    final resultado = await cartVM.agregarProductoDirectoOptimizado(
      producto: producto,
      cantidad: 1,
    );

    if (!mounted) return;

    if (resultado == AgregadoResultado.agregadoNuevo ||
        resultado == AgregadoResultado.yaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado == AgregadoResultado.agregadoNuevo
                ? 'Producto agregado al carrito.'
                : 'Este producto ya está en tu carrito.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Algo salió mal'),
          content: Text(
            resultado == AgregadoResultado.sinStock
                ? 'No hay suficiente stock disponible.'
                : 'Error al agregar el producto.',
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
}

// ✅ Extensión para calcular el precio con descuento
extension PrecioCalculado on Producto {
  double get precioFinal {
    if (precio == null) return 0;
    return porcentajeDescuento > 0
        ? precio! * (1 - porcentajeDescuento / 100)
        : precio!;
  }
}
