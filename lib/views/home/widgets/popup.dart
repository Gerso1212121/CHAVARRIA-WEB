import 'package:final_project/views/home/sections/productos.dart';
import 'package:flutter/material.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/views/home/sections/detalle_producto.dart';

class PopupResultadosBusqueda extends StatelessWidget {
  final double top;
  final double left;
  final double width;
  final List<Producto> resultados;

  const PopupResultadosBusqueda({
    super.key,
    required this.top,
    required this.left,
    required this.width,
    required this.resultados,
  });

  @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final horizontalPosition = (screenWidth - width) / 8;

  return Positioned(
    top: top,
    left: horizontalPosition,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        maxHeight: 500,
      ),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            itemCount: resultados.length.clamp(0, 5),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = resultados[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    p.urlImagen ?? '',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),
                title: Text(
                  p.nombre,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '\$${(p.precio ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13),
                ),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(producto: p),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    ),
  );
}

}
