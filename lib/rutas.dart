import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/sections/verificacionPago.dart';
import 'package:flutter/material.dart';
import 'package:final_project/views/home/home_screen.dart';
import 'package:final_project/views/home/sections/catalogos.dart';
import 'package:final_project/views/home/sections/conditions/terms_conditions.dart';
import 'package:final_project/views/home/sections/pagocompleto.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomePage(),
  '/home': (context) => const HomePage(),
  '/productos': (context) => const Productos(),
  '/terminos': (context) => const TermsAndConditionsPage(),
  '/pago-completo': (context) => const PagoCompletoPage(),
  '/login': (context) => const LoginPage(), 
  '/verificacion-pago': (context) => const VerificacionPagoPage(),
// ✅ Aquí agregás la ruta del login
};
