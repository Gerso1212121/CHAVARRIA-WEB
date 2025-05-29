import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_carrusel.dart';
import 'package:final_project/views/home/widgets/custom_producto.dart';

class DestacadosYCategorias extends StatelessWidget {
  const DestacadosYCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
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
              'Explora por categoría (Scrolea horizontal)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // 🔥 Centro horizontal
                children: const [
                  CategoriaItem(
                    imageUrl:
                        'https://images.pexels.com/photos/3356416/pexels-photo-3356416.jpeg',
                    label: 'Rebajas',
                  ),
                  CategoriaItem(
                    imageUrl:
                        'https://images.pexels.com/photos/3356416/pexels-photo-3356416.jpeg',
                    label: 'Fragancias',
                  ),
                  CategoriaItem(
                    imageUrl:
                        'https://images.pexels.com/photos/3356416/pexels-photo-3356416.jpeg',
                    label: 'Fragancias',
                  ),
                  CategoriaItem(
                    imageUrl:
                        'https://images.pexels.com/photos/3356416/pexels-photo-3356416.jpeg',
                    label: 'Fragancias',
                  ),
                  CategoriaItem(
                    imageUrl:
                        'https://images.pexels.com/photos/3356416/pexels-photo-3356416.jpeg',
                    label: 'Fragancias',
                  ),
                ],
              ),
            ),
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
                  .where((p) => p.porcentajeDescuento > 0)
                  .take(6)
                  .toList();

              if (filteredOffers.isEmpty) {
                return const Center(child: Text('No hay productos en oferta'));
              }

              return SizedBox(
                height: 400,
                child: isMobile
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredOffers.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ProductCard(producto: filteredOffers[index]),
                          );
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredOffers.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                            return ProductCard(producto: filteredOffers[index]);
                          },
                        ),
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

              final filteredNoOffers =
                  viewModel.productosSinOferta.take(6).toList();

              if (filteredNoOffers.isEmpty) {
                return const Center(child: Text('No hay productos sin oferta'));
              }

              return SizedBox(
                height: 400,
                child: isMobile
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredNoOffers.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child:
                                ProductCard(producto: filteredNoOffers[index]),
                          );
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredNoOffers.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                            return ProductCard(
                                producto: filteredNoOffers[index]);
                          },
                        ),
                      ),
              );
            },
          ),
        ],
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
          child: Icon(icon, size: 28, color: Colors.orange),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class CategoriaItem extends StatefulWidget {
  final String imageUrl;
  final String label;

  const CategoriaItem({
    super.key,
    required this.imageUrl,
    required this.label,
  });

  @override
  State<CategoriaItem> createState() => _CategoriaItemState();
}

class _CategoriaItemState extends State<CategoriaItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                if (_hovering)
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: ClipOval(
              child: Image.network(
                widget.imageUrl,
                width: 170,
                height: 170,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 300,
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          )
        ],
      ),
    );
  }
}
