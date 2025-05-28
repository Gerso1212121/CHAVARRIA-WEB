class CartItem {
  final int id;
  final int productoId;
  final String nombre;
  final int cantidad;
  final double precio;
  final String imagenUrl;
  final int stock;

  CartItem({
    required this.id,
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.imagenUrl,
    required this.stock,
  });

  double get total => cantidad * precio;
}

// Agrega este método a tu modelo CartItem para copyWith
extension CartItemCopyWith on CartItem {
  CartItem copyWith({
    int? id,
    int? productoId,
    String? nombre,
    int? cantidad,
    double? precio,
    String? imagenUrl,
    int? stock,
  }) {
    return CartItem(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      stock: stock ?? this.stock,
    );
  }
}