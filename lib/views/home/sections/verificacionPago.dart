import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificacionPagoPage extends StatefulWidget {
  const VerificacionPagoPage({super.key});

  @override
  State<VerificacionPagoPage> createState() => _VerificacionPagoPageState();
}

class _VerificacionPagoPageState extends State<VerificacionPagoPage> {
  bool cargando = true;
  String? mensaje;

  @override
  void initState() {
    super.initState();
    verificarPago();
  }

  Future<void> verificarPago() async {
    final referencia = Uri.base.queryParameters['referencia'];
    if (referencia == null) {
      setState(() {
        mensaje = 'Referencia no proporcionada.';
        cargando = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://tu-backend.com/api/pagos/$referencia'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pagado = data['pagado'] == true;

        if (pagado) {
          Navigator.pushReplacementNamed(context, '/pago-completo');
        } else {
          setState(() {
            mensaje = 'El pago aún no ha sido confirmado. Intenta más tarde.';
            cargando = false;
          });
        }
      } else {
        setState(() {
          mensaje = 'Error al verificar el pago.';
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error de conexión: $e';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificando pago...'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: cargando
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 20),
                  Text(
                    mensaje ?? 'Error desconocido',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    child: const Text('Volver al inicio'),
                  )
                ],
              ),
      ),
    );
  }
}
