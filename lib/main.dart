import 'dart:ui_web';

import 'package:final_project/rutas.dart';
import 'package:final_project/supabase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/data/services/products_service.dart';
import 'package:final_project/repositories/productos_usuario.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // 👈 Asegura esto arriba

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(const HashUrlStrategy()); // 👈 Agrega esto ANTES de runApp
  await initializeSupabase();
  runApp(const MyAppProviders());
}

class MyAppProviders extends StatelessWidget {
  const MyAppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();
    final repository = ProductRepository(productService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final vm = ProductViewModel(repository);
            Future.microtask(() => vm.loadProducts());
            return vm;
          },
        ),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carpinteria Chavarria',
      routes: appRoutes,
      navigatorObservers: [routeObserver],
      onGenerateRoute: onGenerateRoute,
    );
  }
}
