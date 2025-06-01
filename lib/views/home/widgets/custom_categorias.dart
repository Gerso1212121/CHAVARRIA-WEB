import 'package:final_project/views/home/widgets/custom_carrusel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_tomarProductos.dart';
import 'package:final_project/views/home/widgets/animations/carrusel_imagenes.dart';

class DestacadosYCategorias extends StatelessWidget {
  const DestacadosYCategorias({super.key});

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 1024) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Container(
          color: Colors.grey.shade50,
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BeneficiosSection(),
              const SizedBox(height: 32),
              SlideCarousel(imageUrls: carruselImages),
              const SizedBox(height: 32),
              const Divider(thickness: 1.2, height: 50),
              const _TituloSeccion(texto: 'Explora por categoría'),
              const SizedBox(height: 20),
              const _CategoriasSection(),
              const SizedBox(height: 32),
              const Divider(thickness: 1.2, height: 50),
              const _TituloSeccion(texto: 'Productos destacados'),
              const SizedBox(height: 20),
              _ProductosGrid(filtrarOferta: true),
              const SizedBox(height: 40),
              const _TituloSeccion(texto: 'Productos Nuevos'),
              const SizedBox(height: 10),
              _ProductosGrid(filtrarOferta: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final String texto;
  const _TituloSeccion({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _BeneficiosSection extends StatelessWidget {
  const _BeneficiosSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 40,
        runSpacing: 24,
        children: const [
          BeneficioItem(icon: Icons.local_shipping, title: 'Envío rápido'),
          BeneficioItem(icon: Icons.handyman, title: 'Hecho a mano'),
          BeneficioItem(icon: Icons.design_services, title: 'Diseños únicos'),
          BeneficioItem(icon: Icons.verified_user, title: 'Garantía 1 año'),
        ],
      ),
    );
  }
}

class _CategoriasSection extends StatelessWidget {
  const _CategoriasSection();

  static final List<Map<String, dynamic>> categorias = [
    {'nombre': 'Sala de estar', 'icono': Icons.weekend},
    {'nombre': 'Comedor', 'icono': Icons.restaurant},
    {'nombre': 'Dormitorio', 'icono': Icons.bed},
    {'nombre': 'Oficina', 'icono': Icons.chair},
    {'nombre': 'Almacenamiento', 'icono': Icons.inventory_2},
    {'nombre': 'Exterior', 'icono': Icons.park},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categorias.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final c = categorias[index];
          return CategoriaItem(icon: c['icono'], label: c['nombre']);
        },
      ),
    );
  }
}

class _ProductosGrid extends StatelessWidget {
  final bool filtrarOferta;
  const _ProductosGrid({required this.filtrarOferta});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = DestacadosYCategorias()._getCrossAxisCount(context);

    return Consumer<ProductViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final productos = filtrarOferta
            ? viewModel.productos
                .where((p) => p.porcentajeDescuento > 0 && p.stock > 0)
                .take(6)
                .toList()
            : viewModel.productosSinOferta
                .where((p) => p.stock > 0)
                .take(6)
                .toList();

        if (productos.isEmpty) {
          return const Center(child: Text('No hay productos disponibles'));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productos.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) =>
                ProductCard(producto: productos[index]),
          ),
        );
      },
    );
  }
}

class BeneficioItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const BeneficioItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 600 ? 24.0 : 32.0;
    final fontSize = screenWidth < 600 ? 13.0 : 16.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: iconSize, color: Colors.orange),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

class CategoriaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoriaItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final iconSize = isMobile ? 36.0 : 52.0;
    final fontSize = isMobile ? 12.0 : 16.0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/productos',
          arguments: {'categoria': label},
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: Colors.orange),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
