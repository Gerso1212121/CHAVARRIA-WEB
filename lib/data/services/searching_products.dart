import 'package:flutter/material.dart';
import 'package:final_project/data/models/productos.dart';

class SearchHelper {
  final TextEditingController searchController = TextEditingController();
  final GlobalKey searchKey = GlobalKey();
  List<Producto> resultados = [];

  /// Actualiza la lista de resultados basándose en el texto de búsqueda
  void buscar({
    required String texto,
    required List<Producto> allProducts,
    required VoidCallback onUpdate,
  }) {
    final query = texto.trim().toLowerCase();
    resultados = query.isEmpty
        ? []
        : allProducts
            .where((p) => p.nombre.toLowerCase().contains(query))
            .toList();
    onUpdate();
  }

  /// Limpia el campo de búsqueda y la lista de resultados
  void limpiar(VoidCallback onUpdate) {
    searchController.clear();
    resultados = [];
    onUpdate();
  }

  void dispose() {
    searchController.dispose();
  }
}
