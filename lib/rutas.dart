import 'package:flutter/material.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/home_screen.dart';
import 'package:final_project/views/home/sections/catalogos.dart';
import 'package:final_project/views/home/sections/conditions/terms_conditions.dart';
import 'package:final_project/views/home/sections/pagocompleto.dart';
import 'package:final_project/views/home/sections/info_producto.dart';
import 'package:final_project/views/home/sections/verificacionPago.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomePage(),
  '/home': (context) => const HomePage(),
  '/productos': (context) => const Productos(),
  '/terminos': (context) => const TermsAndConditionsPage(),
  '/pago-completo': (context) => const PagoCompletoPage(),
  '/login': (context) => const LoginPage(),
  '/verificacion-pago': (context) => const VerificacionPagoPage(),
  // 🚫 Eliminamos '/productoDetalle' de aquí porque requiere argumentos dinámicos
};

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  if (settings.name == '/productoDetalle') {
    final producto = settings.arguments as Producto;
    return MaterialPageRoute(
      builder: (context) => ProductDetailPage(producto: producto),
    );
  }

  // Fallback en caso de ruta no reconocida
  return MaterialPageRoute(
    builder: (context) => const HomePage(),
  );
}
