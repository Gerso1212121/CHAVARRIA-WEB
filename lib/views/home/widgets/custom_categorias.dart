import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_carrusel.dart';
import 'package:final_project/views/home/widgets/custom_tomarProductos.dart';

class DestacadosYCategorias extends StatelessWidget {
  const DestacadosYCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    int getCrossAxisCount() {
      if (isMobile) return 2;
      if (isTablet) return 3;
      return 4;
    }

    final categorias = [
      {'nombre': 'Sala de estar', 'icono': Icons.weekend},
      {'nombre': 'Comedor', 'icono': Icons.restaurant},
      {'nombre': 'Dormitorio', 'icono': Icons.bed},
      {'nombre': 'Oficina', 'icono': Icons.chair},
      {'nombre': 'Almacenamiento', 'icono': Icons.inventory_2},
      {'nombre': 'Exterior', 'icono': Icons.park},
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Container(
          color: Colors.grey.shade50,
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 40,
                  runSpacing: 24,
                  children: const [
                    BeneficioItem(
                        icon: Icons.local_shipping, title: 'Envío rápido'),
                    BeneficioItem(icon: Icons.handyman, title: 'Hecho a mano'),
                    BeneficioItem(
                        icon: Icons.design_services, title: 'Diseños únicos'),
                    BeneficioItem(
                        icon: Icons.verified_user, title: 'Garantía 1 año'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const SlideCarrusell(),
              const SizedBox(height: 32),
              const Divider(thickness: 1.2, height: 50),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Explora por categoría',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: isMobile
                        ? GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: categorias
                                .map((categoria) => CategoriaItem(
                                      icon: categoria['icono'] as IconData,
                                      label: categoria['nombre'] as String,
                                    ))
                                .toList(),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: categorias
                                .map((categoria) => Expanded(
                                      child: CategoriaItem(
                                        icon: categoria['icono'] as IconData,
                                        label: categoria['nombre'] as String,
                                      ),
                                    ))
                                .toList(),
                          ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Divider(thickness: 1.2, height: 50),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Productos destacados',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Consumer<ProductViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredOffers = viewModel.productos
                      .where((p) => p.porcentajeDescuento > 0 && p.stock > 0)
                      .take(6)
                      .toList();

                  if (filteredOffers.isEmpty) {
                    return const Center(child: Text('No hay productos en oferta'));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredOffers.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(producto: filteredOffers[index]);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Productos Nuevos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Consumer<ProductViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredNoOffers = viewModel.productosSinOferta
                      .where((p) => p.stock > 0)
                      .take(6)
                      .toList();

                  if (filteredNoOffers.isEmpty) {
                    return const Center(
                        child: Text('No hay productos sin oferta'));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredNoOffers.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getCrossAxisCount(),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(producto: filteredNoOffers[index]);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
    final iconSize = isMobile ? 40.0 : 60.0;
    final fontSize = isMobile ? 12.0 : 16.0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/productos',
          arguments: {'categoria': label},
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
