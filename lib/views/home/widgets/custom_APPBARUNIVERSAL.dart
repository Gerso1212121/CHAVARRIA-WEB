import 'package:final_project/views/home/widgets/custom_appBar_home.dart';
import 'package:flutter/material.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/views/home/sections/detalle_producto.dart';

class UniversalTopBarWrapper extends StatefulWidget {
  final Widget child;
  final List<Producto> allProducts;
  final double expandedHeight;
  final Color appBarColor;
  final Widget flexibleSpace;

  const UniversalTopBarWrapper({
    super.key,
    required this.child,
    required this.allProducts,
    required this.expandedHeight,
    required this.appBarColor,
    required this.flexibleSpace,
  });

  @override
  State<UniversalTopBarWrapper> createState() => _UniversalTopBarWrapperState();
}

class _UniversalTopBarWrapperState extends State<UniversalTopBarWrapper>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _searchKey = GlobalKey();
  List<Producto> _resultados = [];

  double _popupTop = 0;
  double _popupLeft = 0;
  double _popupWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Se ejecuta cuando cambian dimensiones de la ventana
  @override
  void didChangeMetrics() {
    if (_resultados.isNotEmpty && _searchController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calcularPosicion();
      });
    }
    super.didChangeMetrics();
  }

  void _buscar(String texto) {
    if (texto.trim().isEmpty) {
      setState(() => _resultados = []);
    } else {
      setState(() {
        _resultados = widget.allProducts
            .where((p) =>
                p.nombre.toLowerCase().contains(texto.toLowerCase().trim()))
            .toList();
      });
      _calcularPosicion();
    }
  }

  void _calcularPosicion() {
    final RenderBox? box =
        _searchKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final offset = box.localToGlobal(Offset.zero);
      setState(() {
        _popupTop = offset.dy + box.size.height + 7;
        _popupLeft = offset.dx - 8;
        _popupWidth = box.size.width + 56;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showPopup =
        _searchController.text.trim().isNotEmpty && _resultados.isNotEmpty;

    return Stack(
      children: [
        Scaffold(
          drawer: UniversalTopBar.buildDrawer(context),
          endDrawer: UniversalTopBar.buildCartDrawer(context),
          body: CustomScrollView(
            slivers: [
              UniversalTopBar(
                useSliver: true,
                appBarColor: widget.appBarColor,
                expandedHeight: widget.expandedHeight,
                allProducts: widget.allProducts,
                searchController: _searchController,
                onSearchChanged: _buscar,
                searchResults: _resultados,
                searchKey: _searchKey,
                flexibleSpace: widget.flexibleSpace,
              ),
              SliverToBoxAdapter(child: widget.child),
            ],
          ),
        ),

        // Resultado de búsqueda flotante
        if (showPopup)
          Positioned(
            top: _popupTop,
            left: _popupLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _popupWidth,
                maxHeight: 500,
              ),
              child: Material(
                elevation: 6,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                  // Las de arriba cuadradas (default)
                ),
                child: ListView.builder(
                  itemCount: _resultados.length.clamp(0, 5),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final producto = _resultados[index];
                    return ListTile(
                      leading: (producto.urlImagen != null &&
                              producto.urlImagen!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                producto.urlImagen!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image, size: 40),
                      title: Text(producto.nombre),
                      subtitle: Text(
                        '\$${(producto.precio ?? 0).toStringAsFixed(2)}',
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(producto: producto),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
