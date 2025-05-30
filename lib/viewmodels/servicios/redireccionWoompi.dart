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

  // Conversión a centavos
  final montoCents = (total).toInt();

  // Puedes personalizar esta referencia como quieras
  final referencia = "orden_${DateTime.now().millisecondsSinceEpoch}";

  final response = await http.post(
    Uri.parse('https://chavarria-web-1.onrender.com/api/wompi/enlace'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'referencia': referencia,
      'montoCents': montoCents,
      'nombreProducto': "Compra desde Flutter"
    }),
  );
  print('📧 Correo obtenido de Supabase: $correo');
  print('💵 Total enviado (centavos): $montoCents');

  if (response.statusCode == 200) {
    final url = jsonDecode(response.body)['urlEnlace'];
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    print('❌ Respuesta backend: ${response.body}');
    throw Exception('Error generando link de pago');
  }
}
