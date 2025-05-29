import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:final_project/views/home/widgets/custom_showdialog.dart';

/// Verifica si el usuario existe en la base de datos
Future<bool> usuarioExiste(String correo) async {
  final url = Uri.parse('https://chavarria-web.onrender.com/usuario-existe');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'correo': correo}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['existe'] == true;
  } else {
    throw Exception('Error al verificar usuario: ${response.body}');
  }
}

Future<bool> enviarCodigoValido({
  required BuildContext context,
  required String correo,
  required String nombre,
  required String codigo,
}) async {
  try {
    showLoadingDialog(context, mensaje: 'Verificando correo...');

    final existe = await usuarioExiste(correo);
    if (context.mounted) Navigator.of(context).pop();

    if (!existe) {
      showFeedbackDialog(
        context: context,
        title: 'Correo no registrado',
        message: 'El correo ingresado no está vinculado a ninguna cuenta.',
        isSuccess: false,
      );
      return false;
    }

    const serviceId = 'service_2at7ox7';
    const templateId = 'template_y8yy5c1';
    const userId = 'JTg6gY45lthG-Sw2G';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    showLoadingDialog(context, mensaje: 'Enviando código de verificación...');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'nombre': nombre,
          'correo': correo,
          'codigo': codigo,
        },
      }),
    );

    if (context.mounted) Navigator.of(context).pop();

    if (response.statusCode != 200) {
      throw Exception('Error al enviar código: ${response.body}');
    }

    return true;
  } catch (e) {
    if (context.mounted) Navigator.of(context).pop();
    showFeedbackDialog(
      context: context,
      title: 'Error',
      message: e.toString().replaceFirst('Exception: ', ''),
      isSuccess: false,
    );
    return false;
  }
}

/// Generador simple de códigos de 6 dígitos
String generarCodigoVerificacion() {
  final rand = Random();
  return List.generate(6, (_) => rand.nextInt(10)).join();
}

Future<void> enviarCodigoVerificacion({
  required BuildContext context,
  required String correo,
  required String nombre,
  required String codigo,
}) async {
  const serviceId = 'service_2at7ox7';
  const templateId = 'template_y8yy5c1';
  const userId = 'JTg6gY45lthG-Sw2G';

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  showLoadingDialog(context, mensaje: 'Enviando código de verificación...');

  try {
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'nombre': nombre,
          'correo': correo,
          'codigo': codigo,
        },
      }),
    );

    if (context.mounted) Navigator.of(context).pop();

    if (response.statusCode != 200) {
      throw Exception('Error al enviar código: ${response.body}');
    }
  } catch (e) {
    if (context.mounted) Navigator.of(context).pop();
    throw Exception('No se pudo enviar el código: $e');
  }
}

/// 🆕 Enviar código de restablecimiento de contraseña
Future<void> enviarCodigoRestablecimiento({
  required BuildContext context,
  required String correo,
  required String codigo,
}) async {
  const serviceId = 'service_2at7ox7';
  const templateId = 'template_y8yy5c1'; // ⚠️ Crea este nuevo template
  const userId = 'JTg6gY45lthG-Sw2G';

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  showLoadingDialog(context, mensaje: 'Enviando código de restablecimiento...');

  try {
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'correo': correo,
          'codigo': codigo,
        },
      }),
    );

    if (context.mounted) Navigator.of(context).pop();

    if (response.statusCode != 200) {
      throw Exception('Error al enviar código: ${response.body}');
    }
  } catch (e) {
    if (context.mounted) Navigator.of(context).pop();
    throw Exception('No se pudo enviar el código: $e');
  }
}

/// Muestra un diálogo de carga mientras se realiza un proceso
void showLoadingDialog(BuildContext context,
    {String mensaje = 'Procesando...'}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(mensaje)),
          ],
        ),
      );
    },
  );
}

/// Envía un correo con EmailJS al registrar el usuario
Future<void> enviarCorreoRegistro({
  required BuildContext context,
  required String nombre,
  required String correo,
  required String dui,
}) async {
  const serviceId = 'service_2at7ox7';
  const templateId = 'template_u6zxaf8';
  const userId = 'JTg6gY45lthG-Sw2G';

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final String ultimoDigito = dui.length == 10 ? dui.substring(9) : '?';

  showLoadingDialog(context, mensaje: 'Verificando...');

  try {
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'nombre': nombre,
          'correo': correo,
          'ultimo_digito_dui': ultimoDigito,
        },
      }),
    );

    if (context.mounted) Navigator.of(context).pop();

    if (response.statusCode != 200) {
      throw Exception('Error al enviar correo: ${response.body}');
    }
  } catch (e) {
    if (context.mounted) Navigator.of(context).pop();
    throw Exception('No se pudo enviar el correo: $e');
  }
}
