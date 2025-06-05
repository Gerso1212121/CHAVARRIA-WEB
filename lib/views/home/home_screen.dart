import 'dart:ui';
import 'package:final_project/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_carrusel.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:final_project/views/home/widgets/custom_enviarCategorias.dart';
import 'package:final_project/views/home/widgets/custom_APPBARUNIVERSAL.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  bool _ready = false;
  final TextEditingController _searchController =
      TextEditingController(); // ✅ Declarado aquí

  @override
  void initState() {
    super.initState();

    // Limpiar búsqueda al iniciar Home
    Future.microtask(() {
      context.read<ProductViewModel>().limpiarBusqueda();
    });

    // Esperar un frame antes de mostrar contenido pesado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _ready = true);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchController.dispose(); // ✅ Siempre libera recursos
    super.dispose();
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductViewModel>().limpiarBusqueda();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductViewModel>().productos;
    final isSmall = MediaQuery.of(context).size.width < 600;

    return UniversalTopBarWrapper(
      allProducts: productos,
      expandedHeight: 600,
      appBarColor: const Color(0xFF3E3E3E),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            FadingImageCarousel(
              imagePaths: [
                'assets/images/home1.png',
                'assets/images/home2.png',
                'assets/images/home3.png',
                'assets/images/home4.png',
              ],
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 24 : 140),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: isSmall
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carpintería Chavarría',
                    style: TextStyle(
                      fontSize: isSmall ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isSmall ? TextAlign.center : TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment:
                        isSmall ? Alignment.center : Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        final textoBuscado = _searchController.text.trim();
                        Navigator.pushNamed(
                          context,
                          '/productos',
                          arguments: textoBuscado,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text('Ver Productos'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Encuentra los mejores muebles en\nCarpintería Chavarría.\nDescubre nuestra variedad de productos\ndiseñados para tu hogar y oficina.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 13 : 14,
                    ),
                    textAlign: isSmall ? TextAlign.center : TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      searchController: _searchController, // ✅ Aquí lo pasás al wrapper
      onSearchChanged: null,
      child: Column(
        children: [
          if (_ready) const DestacadosYCategorias(),
          if (_ready) const AppFooter(),
        ],
      ),
    );
  }
}
