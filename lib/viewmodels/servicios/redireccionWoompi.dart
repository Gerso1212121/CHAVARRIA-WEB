import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> lanzarPagoDesdeFlutter(double total) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception('Usuario no autenticado');
  }

  final responseCliente = await supabase
      .from('cliente')
      .select('correo')
      .eq('id_cliente', user.id)
      .single();

  final correo = responseCliente['correo'];

  final response = await http.post(
    Uri.parse('https://chavarria-web-1.onrender.com/generar-link'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'total': total, 'correo': correo}),
  );
  print('📧 Correo obtenido de Supabase: $correo');
  print('💵 Total enviado: $total');

  if (response.statusCode == 200) {
    final url = jsonDecode(response.body)['url'];
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Error generando link de pago');
  }
}
