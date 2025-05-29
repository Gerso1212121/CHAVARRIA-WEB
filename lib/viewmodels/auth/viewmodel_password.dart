import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> resetearPasswordDesdeBackend({
  required String correo,
  required String nuevaPassword,
}) async {
  final url = Uri.parse('https://chavarria-web.onrender.com/reset-password');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': correo,
      'nuevaContrasena': nuevaPassword,
    }),
  );

  // Manejo de respuestas
  if (response.statusCode == 200) {
    print('✅ Contraseña actualizada: ${response.body}');
  } else {
    // Intentar extraer el mensaje de error del backend
    final body = jsonDecode(response.body);

    if (response.statusCode == 404) {
      // Usuario no encontrado
      throw Exception(body['error'] ?? 'El correo no está registrado.');
    } else {
      // Otros errores
      throw Exception(body['error'] ?? 'Error al actualizar la contraseña.');
    }
  }
}
