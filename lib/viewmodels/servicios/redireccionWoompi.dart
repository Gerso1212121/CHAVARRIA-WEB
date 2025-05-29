import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> lanzarPagoDesdeFlutter(double total, String correo) async {
  final response = await http.post(
    Uri.parse('https://tu-backend-render.com/generar-link'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'total': total, 'correo': correo}),
  );

  if (response.statusCode == 200) {
    final url = jsonDecode(response.body)['url'];
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Error generando link de pago');
  }
}

