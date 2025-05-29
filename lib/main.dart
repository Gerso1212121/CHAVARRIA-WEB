import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/views/home/sections/pagocompleto.dart';
import 'package:final_project/views/home/sections/productos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:final_project/views/home/home_screen.dart';
import 'package:final_project/data/services/products_service.dart';
import 'package:final_project/repositories/productos_usuario.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/sections/conditions/terms_conditions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xuzvixzgudjycuywwppu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1enZpeHpndWRqeWN1eXd3cHB1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ5NzYxMCwiZXhwIjoyMDYyMDczNjEwfQ.vfsDcpR9KvFaZhA1zdUnXCS-8ozc_YHJcNIaT_FI9V4',
  );

  final productService = ProductService();
  final repository = ProductRepository(productService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final vm = ProductViewModel(repository);
            Future.microtask(() => vm.loadProducts()); // ✅ Carga diferida
            return vm;
          },
        ),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/home': (context) => const HomePage(),
        '/productos': (context) => const Productos(),
        '/terminos': (context) => const TermsAndConditionsPage(),
        '/pago-completo': (context) =>
            const PagoCompletoPage(), // <-- ✅ NUEVA RUTA
      },
    );
  }
}
