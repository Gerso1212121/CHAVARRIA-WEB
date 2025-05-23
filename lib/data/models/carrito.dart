class CartItem {
  final int id;
  final String nombre;
  final String imagenUrl;
  final double precio;
  int cantidad;

  CartItem({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.precio,
    required this.cantidad,
  });

  double get total => precio * cantidad;
}
