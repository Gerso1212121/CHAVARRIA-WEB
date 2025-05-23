class Producto {
  final int id;
  final String nombre;
  final double precio;
  final double? precioAnterior;
  final bool tieneEnvio;
  final String categoria;
  final int porcentajeDescuento;
  final String urlImagen;
  final String? codigoBarras;
  final int stock;
  final String? descripcion;
  final String? dimensiones;
  final double? peso;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.precioAnterior,
    required this.tieneEnvio,
    required this.categoria,
    required this.porcentajeDescuento,
    required this.urlImagen,
    this.codigoBarras,
    required this.stock,
    this.descripcion,
    this.dimensiones,
    this.peso,
  });

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      precio: (map['precio'] as num).toDouble(),
      precioAnterior: map['precio_anterior'] != null ? (map['precio_anterior'] as num).toDouble() : null,
      tieneEnvio: map['tiene_envio'] ?? false,
      categoria: map['categoria'] ?? '',
      porcentajeDescuento: map['porcentaje_descuento'] ?? 0,
      urlImagen: map['url_imagen'] ?? '',
      codigoBarras: map['codigo_barras'],
      stock: map['stock'] ?? 0,
      descripcion: map['descripcion'],
      dimensiones: map['dimensiones'],
      peso: map['peso'] != null ? (map['peso'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'precio_anterior': precioAnterior,
      'tiene_envio': tieneEnvio,
      'categoria': categoria,
      'porcentaje_descuento': porcentajeDescuento,
      'url_imagen': urlImagen,
      'codigo_barras': codigoBarras,
      'stock': stock,
      'descripcion': descripcion,
      'dimensiones': dimensiones,
      'peso': peso,
    };
  }
}
