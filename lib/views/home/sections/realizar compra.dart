import 'package:final_project/viewmodels/servicios/redireccionWoompi.dart';
import 'package:flutter/material.dart';

class MetodoPagoPage extends StatelessWidget {
  final double total;

  const MetodoPagoPage({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu método de pago'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del pago',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Total a pagar: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            const Text(
              'Selecciona un método de pago:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final continuar = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("¿Deseas continuar?"),
                    content: Text(
                      "Serás redirigido a otra página para completar tu pago con Wompi.\n\n"
                      "El enlace y tu sesión de pago serán válidos durante los próximos 15 minutos. "
                      "Asegúrate de completar el pago en ese tiempo para evitar inconvenientes.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text("Continuar"),
                      ),
                    ],
                  ),
                );

                if (continuar == true) {
                  await lanzarPagoDesdeFlutter(context, total);
                }
              },
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Pagar con Wompi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PayPalPage()),
                );
              },
              icon: const Icon(Icons.paypal),
              label: const Text('Pagar con PayPal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Página de simulación de Wompi
class WompiPage extends StatelessWidget {
  const WompiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago con Wompi')),
      body: const Center(
        child: Text('Aquí se integraría el formulario embebido de Wompi'),
      ),
    );
  }
}

// Página de simulación de PayPal
class PayPalPage extends StatelessWidget {
  const PayPalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago con PayPal')),
      body: const Center(
        child: Text('Aquí se integraría el WebView o SDK de PayPal'),
      ),
    );
  }
}
