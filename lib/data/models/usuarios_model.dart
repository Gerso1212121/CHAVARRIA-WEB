class Usuario {
  final String nombre;
  final String dui;
  final String correo;
  final String telefono1;
  final String telefono2;
  final String direccion;
  final String password;

  Usuario({
    required this.nombre,
    required this.dui,
    required this.correo,
    required this.telefono1,
    required this.telefono2,
    required this.direccion,
    required this.password,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'] ?? '',
      dui: json['dui'] ?? '',
      correo: json['correo'] ?? '',
      telefono1: json['telefono1'] ?? '',
      telefono2: json['telefono2'] ?? '',
      direccion: json['direccion'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dui': dui,
      'correo': correo,
      'telefono1': telefono1,
      'telefono2': telefono2,
      'direccion': direccion,
      'password': password,
    };
  }
}
