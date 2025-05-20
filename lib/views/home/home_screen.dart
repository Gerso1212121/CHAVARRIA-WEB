import 'package:final_project/views/home/widgets/custom_appBar.dart';
import 'package:final_project/views/home/widgets/custom_datos.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  Color _appBarColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        _appBarColor = offset > 0
            ? const Color.fromARGB(255, 52, 52, 52)
            : Colors.transparent;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E3E3E),
      drawer: CustomTopBar.buildDrawer(context),
      endDrawer: CustomTopBar.buildCartDrawer(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          CustomTopBar(
            appBarColor: _appBarColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://media.istockphoto.com/id/1442113721/es/foto/sof%C3%A1-de-tela-blanca-planta-de-higo-de-hoja-de-viol%C3%ADn-escritorio-de-trabajo-de-madera-y-silla.jpg?s=612x612&w=0&k=20&c=MQjIkbbNLEqMq9N9DxRQMFnNsSgwd0yO3NxtoQAOsXE=',
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withOpacity(0.6)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Carpintería Chavarria',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/productos');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Ver Productos',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Encuentra los mejores muebles en\nCarpintería Chavarría.\nDescubre nuestra variedad de productos\ndiseñados para tu hogar y oficina.',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const DestacadosYCategorias(),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              height: 200,
              child: const Center(child: Text("Contenido aquí")),
            ),
          ),
          SliverToBoxAdapter(child: _buildProductSection(title: "Ofertas")),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
              child: _buildProductSection(title: "Más Vendidos")),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildProductSection({required String title}) {
    return _PaginatedProductCarousel(title: title);
  }
}

class _PaginatedProductCarousel extends StatefulWidget {
  final String title;
  const _PaginatedProductCarousel({required this.title});

  @override
  State<_PaginatedProductCarousel> createState() =>
      _PaginatedProductCarouselState();
}

class _PaginatedProductCarouselState extends State<_PaginatedProductCarousel> {
  final int _itemsPerPage = 4;
  final int _totalItems = 8;
  int _currentStartIndex = 0;

  void _nextPage() {
    setState(() {
      if (_currentStartIndex + _itemsPerPage < _totalItems) {
        _currentStartIndex += _itemsPerPage;
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_currentStartIndex - _itemsPerPage >= 0) {
        _currentStartIndex -= _itemsPerPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = List.generate(_totalItems, (index) => index)
        .skip(_currentStartIndex)
        .take(_itemsPerPage)
        .toList();

    return Center(
      child: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeOutQuart,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          final slideAnimation = Tween<Offset>(
                            begin: const Offset(0.2, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                              parent: animation, curve: Curves.easeOut));

                          final fadeAnimation = Tween<double>(
                            begin: 0,
                            end: 1,
                          ).animate(CurvedAnimation(
                              parent: animation, curve: Curves.easeOut));

                          return SlideTransition(
                            position: slideAnimation,
                            child: FadeTransition(
                              opacity: fadeAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: Row(
                          key: ValueKey(_currentStartIndex),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            visibleItems.length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: _buildProductCard(visibleItems[index]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _nextPage,
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(int index) {
    return Center(
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.weekend, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Producto ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '\$99.99',
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Disponible',
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
