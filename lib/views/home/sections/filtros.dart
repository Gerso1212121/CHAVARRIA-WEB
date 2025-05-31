import 'package:final_project/views/home/widgets/custom_tomarProductos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/widgets/animations/custom_chargin.dart';

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

    // Debug para confirmar que todos tienen stock
    for (final p in productosParaMostrar) {
      debugPrint('✅ MOSTRADO: ${p.nombre} - stock: ${p.stock}');
    }

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
