import 'package:url_launcher/url_launcher.dart';

Future<void> redirigirAWompiCheckout({
  required String publicKey,
  required double totalUSD,
  required String referencia,
  required String correoCliente,
}) async {
  // Convertir el monto a centavos
  final int montoCentavos = (totalUSD * 100).round();

  final url = Uri.parse(
    'https://checkout.wompi.sv/p/?public-key=$publicKey'
    '&currency=USD'
    '&amount-in-cents=$montoCentavos'
    '&reference=$referencia'
    '&customer-data.email=$correoCliente',
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'No se pudo abrir el Checkout de Wompi';
  }
}
