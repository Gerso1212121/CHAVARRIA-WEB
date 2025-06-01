import 'package:flutter/material.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/views/home/widgets/popup.dart';

class SearchPopupController {
  final BuildContext context;
  final List<Producto> allProducts;

  final TextEditingController controller = TextEditingController();
  final GlobalKey searchKey = GlobalKey();

  List<Producto> results = [];

  double _popupTop = 0;
  double _popupLeft = 0;
  double _popupWidth = 0;

  SearchPopupController({
    required this.context,
    required this.allProducts,
  });

  void onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      results = [];
    } else {
      final query = value.toLowerCase().trim();
      results = allProducts.where((p) {
        final nombre = p.nombre.toLowerCase();
        final categoria = p.nombreCategoria?.toLowerCase() ?? '';
        return nombre.contains(query) || categoria.contains(query);
      }).toList();
    }
    _calculatePopupPosition();
    _refresh();
  }

  void onSearchSubmitted(String text) {
    final query = text.trim();
    if (query.isEmpty) return;

    Navigator.pushNamed(
      context,
      '/productos',
      arguments: query,
    );
  }

  void _calculatePopupPosition() {
    final RenderBox? box =
        searchKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final offset = box.localToGlobal(Offset.zero);
      _popupTop = offset.dy + box.size.height * 1.3;
      _popupLeft = offset.dx - 8;
      _popupWidth = box.size.width + 56;
    }
  }

  Widget buildPopup() {
    if (results.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: _popupTop,
      left: _popupLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _popupWidth,
          maxHeight: 500,
        ),
        child: PopupResultadosBusqueda(
          width: _popupWidth,
          resultados: results,
        ),
      ),
    );
  }

  void dispose() {
    controller.dispose();
  }

  void _refresh() {
    // fuerza redibujo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      (context as Element).markNeedsBuild();
    });
  }
}
