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
        const SnackBar(content: Text('Por favor selecciona un método de pago.')),
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
      } 
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: isMobile
                ? Column(
                    children: [
                      _buildDatosOperacion(),
                      const SizedBox(height: 20),
                      _buildSeccionWompi(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDatosOperacion()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildSeccionWompi()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatosOperacion() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Datos de la operación", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _datoItem("Importe", "\$${widget.total.toStringAsFixed(2)}"),
            _datoItem("Cantidad", widget.cantidad.toString()),
            _datoItem("Comercio", "CARPINTERIA CHAVARRIA"),
            _datoItem("Fecha", DateTime.now().toString().substring(0, 16)),
          ],
        ),
      ),
    );
  }

  Widget _datoItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(valor, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSeccionWompi() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Selecciona un método de pago", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildMetodoTile("Wompi", Icons.account_balance_wallet_outlined),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock, color: Colors.black54),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Este comercio ofrece el servicio de Wompi para procesar el pago de manera segura.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _procesarPago,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Pagar", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodoTile(String metodo, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.orange[800]),
        title: Text(metodo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Radio<String>(
          value: metodo,
          groupValue: _metodoSeleccionado,
          onChanged: (value) => setState(() => _metodoSeleccionado = value),
        ),
        onTap: () => setState(() => _metodoSeleccionado = metodo),
      ),
    );
  }
}