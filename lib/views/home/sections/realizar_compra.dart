import 'package:flutter/material.dart';
import 'package:final_project/viewmodels/servicios/redireccionWoompi.dart';

class MetodoPagoPage extends StatefulWidget {
  final double total;
  final int cantidad;

  const MetodoPagoPage({super.key, required this.total, required this.cantidad});

  @override
  State<MetodoPagoPage> createState() => _MetodoPagoPageState();
}

class _MetodoPagoPageState extends State<MetodoPagoPage> {
  String? _metodoSeleccionado;

  void _procesarPago() async {
    if (_metodoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un método de pago.')),
      );
      return;
    }

    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar pago"),
        content: Text(
          "Vas a pagar \$${widget.total.toStringAsFixed(2)} con $_metodoSeleccionado.\n\n"
          "¿Deseas continuar con la transacción?"
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirmar")),
        ],
      ),
    );

    if (confirmar == true) {
      if (_metodoSeleccionado == 'Wompi') {
        await lanzarPagoDesdeFlutter(context, widget.total);
      } else if (_metodoSeleccionado == 'PayPal') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirigiendo a PayPal... (funcionalidad pendiente)')),
        );
        // Aquí implementarías redirección real a PayPal.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago'),
        backgroundColor: const Color.fromRGBO(255, 152, 0, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen del pedido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildResumenItem("Cantidad", widget.cantidad.toString()),
            _buildResumenItem("Total a pagar", "\$${widget.total.toStringAsFixed(2)}"),
            const SizedBox(height: 30),
            const Text('Selecciona un método de pago:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            _buildMetodoTile("Wompi", Icons.account_balance_wallet_outlined),
            _buildMetodoTile("PayPal", Icons.paypal),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _procesarPago,
                child: const Text('Pagar ahora'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMetodoTile(String metodo, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(metodo, style: const TextStyle(fontSize: 16)),
        trailing: Radio<String>(
          value: metodo,
          groupValue: _metodoSeleccionado,
          onChanged: (value) {
            setState(() {
              _metodoSeleccionado = value;
            });
          },
        ),
        onTap: () {
          setState(() {
            _metodoSeleccionado = metodo;
          });
        },
      ),
    );
  }
}
