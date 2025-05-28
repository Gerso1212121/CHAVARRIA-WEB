import 'dart:ui';
import 'package:final_project/views/home/sections/detalle_producto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_carrusel.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:final_project/views/home/widgets/custom_datos.dart';
import 'package:final_project/views/home/widgets/popup.dart';
import 'package:final_project/views/home/widgets/custom_APPBARUNIVERSAL.dart';



/// Example HomePage using the UniversalTopBarWrapper:
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductViewModel>().todosLosProductos;
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
                'assets/images/home5.png',
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
                    textAlign:
                        isSmall ? TextAlign.center : TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: isSmall
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/productos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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
                    textAlign:
                        isSmall ? TextAlign.center : TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      child: Column(
        children: const [
          DestacadosYCategorias(),
          AppFooter(),
        ],
      ),
    );
  }
}
