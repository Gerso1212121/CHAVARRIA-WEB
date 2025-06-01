import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_appBar_home.dart';
import 'package:final_project/views/home/widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:provider/provider.dart';

class UniversalTopBarWrapper extends StatefulWidget {
  final Widget child;
  final List<Producto> allProducts;
  final double expandedHeight;
  final Color appBarColor;
  final Widget flexibleSpace;
  final void Function(String)? onSearchSubmitted;
  final void Function(String)? onSearchChanged;

  const UniversalTopBarWrapper({
    super.key,
    required this.child,
    required this.allProducts,
    required this.expandedHeight,
    required this.appBarColor,
    required this.flexibleSpace,
    this.onSearchSubmitted,
    this.onSearchChanged,
  });

  @override
  State<UniversalTopBarWrapper> createState() => _UniversalTopBarWrapperState();
}

class _UniversalTopBarWrapperState extends State<UniversalTopBarWrapper>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _wrapperSearchKey = GlobalKey();
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
    _searchController.dispose();
    super.dispose();
  }

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
  final query = texto.trim();
  if (query.isEmpty) return;

  Navigator.pushNamed(
    context,
    '/productos',
    arguments: query,
  );
}

  void _buscarLocal(String texto) {
    if (texto.trim().isEmpty) {
      setState(() => _resultados = []);
    } else {
      final query = texto.toLowerCase().trim();
      setState(() {
        _resultados = widget.allProducts
            .where((p) =>
                p.nombre.toLowerCase().contains(query) ||
                (p.nombreCategoria?.toLowerCase() ?? '').contains(query))
            .toList();
      });
      _calcularPosicion();
    }
  }

  void _calcularPosicion() {
    final RenderBox? box =
        _wrapperSearchKey.currentContext?.findRenderObject() as RenderBox?;
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
    final bool showPopup = _resultados.isNotEmpty;

    return Scaffold(
      drawer: UniversalTopBar.buildDrawer(context),
      endDrawer: UniversalTopBar.buildCartDrawer(context),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              UniversalTopBar(
                useSliver: true,
                appBarColor: widget.appBarColor,
                expandedHeight: widget.expandedHeight,
                allProducts: widget.allProducts,
                searchController: _searchController,
                onSearchChanged: _buscarLocal,
                onSearchSubmitted: _buscar,
                searchResults: _resultados,
                searchKey: _wrapperSearchKey,
                flexibleSpace: widget.flexibleSpace,
              ),
              SliverToBoxAdapter(child: widget.child),
            ],
          ),
          if (showPopup)
            Positioned(
              top: _popupTop,
              left: _popupLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _popupWidth,
                  maxHeight: 500,
                ),
                child: PopupResultadosBusqueda(
                  width: _popupWidth,
                  resultados: _resultados,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
