import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Función principal para lanzar el pago, ahora requiere el BuildContext
Future<void> lanzarPagoDesdeFlutter(BuildContext context, double total) async {
  // Validar monto máximo permitido ($1000)
  if (total > 1000.0) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Monto máximo excedido"),
        content: Text(
          "El monto máximo permitido por pago con Wompi es \$1000.00 USD.\n"
          "Por favor, reduce el total del carrito o elige otro método de pago.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
    return;
  }

  // Mostrar loader
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
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

    // Conversión a centavos (IMPORTANTE: debes multiplicar por 100)
    final montoCents = (total).toDouble();

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

    Navigator.of(context).pop(); // Cierra el loader antes de continuar

    if (response.statusCode == 200) {
      final url = jsonDecode(response.body)['urlEnlace'];
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print('❌ Respuesta backend: ${response.body}');
      // Mostrar alerta de error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error al generar el enlace"),
          content: Text("No se pudo generar el link de pago.\n${response.body}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Aceptar"),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    Navigator.of(context).pop(); // Cierra el loader si ocurre un error
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text("Ocurrió un error: $e"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}
