class Producto {
  final int idProducto;
  final String nombre;
  final String? tipo;
  final String? material;
  final double? precio;
  final DateTime? fechaRegistro;
  final int? idCategoria;
  final String? nombreCategoria;
  final int porcentajeDescuento;
  final String? urlImagen;
  final String? codigoBarras;
  final int stock;
  final String? descripcion;
  final String? dimensiones;
  final double? peso;
  final bool tieneEnvio;
  final String? creadoPor;
  final DateTime? createdAt;

  Producto({
    required this.idProducto,
    required this.nombre,
    this.tipo,
    this.material,
    this.precio,
    this.fechaRegistro,
    this.idCategoria,
    this.nombreCategoria,
    this.porcentajeDescuento = 0,
    this.urlImagen,
    this.codigoBarras,
    this.stock = 0,
    this.descripcion,
    this.dimensiones,
    this.peso,
    this.tieneEnvio = true,
    this.creadoPor,
    this.createdAt,
  });

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      idProducto: map['id_producto'],
      nombre: map['nombre'],
      tipo: map['tipo'],
      material: map['material'],
      precio: map['precio'] != null ? (map['precio'] as num).toDouble() : null,
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.parse(map['fecha_registro'])
          : null,
      idCategoria: map['id_categoria'],
      nombreCategoria: map['categoria'] != null ? map['categoria']['nombre'] : null,
      porcentajeDescuento: map['porcentaje_descuento'] ?? 0,
      urlImagen: map['url_imagen'],
      codigoBarras: map['codigo_barras'],
      stock: map['stock'] ?? 0,
      descripcion: map['descripcion'],
      dimensiones: map['dimensiones'],
      peso: map['peso'] != null ? (map['peso'] as num).toDouble() : null,
      tieneEnvio: map['tiene_envio'] ?? true,
      creadoPor: map['creado_por'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_producto': idProducto,
      'nombre': nombre,
      'tipo': tipo,
      'material': material,
      'precio': precio,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'id_categoria': idCategoria,
      'porcentaje_descuento': porcentajeDescuento,
      'url_imagen': urlImagen,
      'codigo_barras': codigoBarras,
      'stock': stock,
      'descripcion': descripcion,
      'dimensiones': dimensiones,
      'peso': peso,
      'tiene_envio': tieneEnvio,
      'creado_por': creadoPor,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
