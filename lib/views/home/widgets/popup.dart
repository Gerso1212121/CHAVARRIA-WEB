import 'package:flutter/material.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/views/home/sections/info_producto.dart';

class PopupResultadosBusqueda extends StatelessWidget {
  final double width;
  final List<Producto> resultados;

  const PopupResultadosBusqueda({
    super.key,
    required this.width,
    required this.resultados,
  });

  @override
  Widget build(BuildContext context) {
    final bool noResultados = resultados.isEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double popupWidth = maxWidth > 600 ? 600 : maxWidth * 3;

        return Material(
          elevation: 8, // << Elevación visible
          shadowColor: Colors.black45,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: Container(
            width: popupWidth,
            constraints: BoxConstraints(
              maxHeight: noResultados ? 80 : 300,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              // Shadow ya está en Material, así que podrías omitir esto
            ),
            child: noResultados
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'RESULTADOS NO ENCONTRADOS',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: resultados.length.clamp(0, 5),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = resultados[i];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            p.urlImagen ?? '',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
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
                              builder: (_) =>
                                  ProductDetailPage(producto: p),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
