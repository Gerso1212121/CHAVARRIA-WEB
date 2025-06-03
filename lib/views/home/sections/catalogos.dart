import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_appBar_home.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Productos extends StatefulWidget {
  const Productos({super.key});

  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  String? categoriaSeleccionada;
  String? ordenPrecio;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _searchKey = GlobalKey();
  String? _queryInicial;

  final List<String> categorias = [
    'Todos',
    'Sala de estar',
    'Comedor',
    'Dormitorio',
    'Oficina',
    'Almacenamiento',
    'Exterior',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String && _queryInicial == null) {
      _queryInicial = args;
      _searchController.text = _queryInicial!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProductViewModel>().buscar(_queryInicial!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    List<Producto> productos = vm.productos;

    if (categoriaSeleccionada != null && categoriaSeleccionada != 'Todos') {
      productos = productos
          .where((p) =>
              p.nombreCategoria?.toLowerCase().trim() ==
              categoriaSeleccionada!.toLowerCase().trim())
          .toList();
    }

    if (ordenPrecio != null) {
      productos.sort((a, b) => ordenPrecio == 'asc'
          ? (a.precio ?? 0).compareTo(b.precio ?? 0)
          : (b.precio ?? 0).compareTo(a.precio ?? 0));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: UniversalTopBar.buildDrawer(context),
      endDrawer: UniversalTopBar.buildCartDrawer(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: UniversalTopBar(
          useSliver: false,
          appBarColor: const Color(0xFF333333),
          allProducts: vm.todosLosProductos,
          searchController: _searchController,
          onSearchSubmitted: (text) {
            final query = text.trim();
            if (query.isEmpty) {
              vm.limpiarBusqueda();
            } else {
              vm.buscar(query);
            }
          },
          searchResults: vm.productos,
          searchKey: _searchKey,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Espacio arriba
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Filtros
          SliverToBoxAdapter(child: _buildFiltros()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Grid de productos o mensaje vacío
          productos.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No hay productos disponibles.')),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final producto = productos[index];
                        return _buildProductoCard(context, producto);
                      },
                      childCount: productos.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : 4,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30,
                      childAspectRatio: 0.9,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          // Footer (ahora también scrollea)
          const SliverToBoxAdapter(child: AppFooter()),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DropdownButton<String>(
            value: categoriaSeleccionada ?? 'Todos',
            onChanged: (value) {
              setState(() {
                categoriaSeleccionada = value == 'Todos' ? null : value;
              });
            },
            items: categorias.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c),
              );
            }).toList(),
          ),
          DropdownButton<String>(
            hint: const Text("Ordenar por"),
            value: ordenPrecio,
            onChanged: (value) {
              setState(() => ordenPrecio = value);
            },
            items: const [
              DropdownMenuItem(
                  value: 'asc', child: Text('Precio: Menor a mayor')),
              DropdownMenuItem(
                  value: 'desc', child: Text('Precio: Mayor a menor')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductoCard(BuildContext context, Producto producto) {
    final tieneDescuento = producto.porcentajeDescuento > 0;
    final precioActual = producto.precio ?? 0.0;
    final precioOriginal = producto.precio ?? 0.0;
    final precioConDescuento = tieneDescuento
        ? precioOriginal * (1 - producto.porcentajeDescuento / 100)
        : precioOriginal;

    final isAgotado = producto.stock == 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 180;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tieneDescuento)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        '-${producto.porcentajeDescuento.toInt()}% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 10 : 12,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/productoDetalle',
                        arguments: producto,
                      );
                    },
                    child: Hero(
                      tag: 'producto_${producto.idProducto}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          producto.urlImagen ?? '',
                          height: isCompact ? 110 : 140,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (producto.nombreCategoria != null)
                          Text(
                            producto.nombreCategoria!,
                            style: TextStyle(
                              fontSize: isCompact ? 11 : 13,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          producto.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isCompact ? 13 : 14,
                            color: isAgotado ? Colors.grey : Colors.black,
                            decoration: isAgotado
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '\$${precioConDescuento.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: isCompact ? 13 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: isAgotado
                                        ? Colors.grey
                                        : Colors.green[700],
                                  ),
                                ),
                                if (tieneDescuento)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Text(
                                      '\$${precioOriginal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: isCompact ? 11 : 13,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (producto.tieneEnvio)
                              const Icon(Icons.local_shipping,
                                  size: 18, color: Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isAgotado
                            ? null
                            : () async {
                                final supabase = Supabase.instance.client;
                                final user = supabase.auth.currentUser;

                                if (user == null) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: const Text('¡Ups!'),
                                      content: const Text(
                                          'Debes iniciar sesión para agregar productos al carrito.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                                          icon: const Icon(Icons.login),
                                          label: const Text('Iniciar sesión'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.pushNamed(
                                                context, '/login');
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => Dialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          CircularProgressIndicator(
                                              color: Colors.orange),
                                          SizedBox(height: 16),
                                          Text('Agregando al carrito...'),
                                        ],
                                      ),
                                    ),
                                  ),
                                );

                                final cartVM = Provider.of<CartViewModel>(
                                    context,
                                    listen: false);
                                final resultado =
                                    await cartVM.agregarProductoDirecto(
                                  productoId: producto.idProducto,
                                  cantidad: 1,
                                );

                                Navigator.of(context).pop();

                                String titulo;
                                String mensaje;
                                Icon icono;

                                switch (resultado) {
                                  case AgregadoResultado.agregadoNuevo:
                                    titulo = '¡Agregado!';
                                    mensaje =
                                        '${producto.nombre} fue agregado al carrito.';
                                    icono = const Icon(Icons.check_circle,
                                        color: Colors.green, size: 48);
                                    break;
                                  case AgregadoResultado.yaExiste:
                                    titulo = 'Ya en el carrito';
                                    mensaje =
                                        'Este producto ya está en tu carrito.';
                                    icono = const Icon(Icons.info_outline,
                                        color: Colors.blue, size: 48);
                                    break;
                                  case AgregadoResultado.sinStock:
                                    titulo = 'Sin stock';
                                    mensaje =
                                        'No hay suficiente stock disponible.';
                                    icono = const Icon(Icons.warning_amber,
                                        color: Colors.orange, size: 48);
                                    break;
                                  default:
                                    titulo = 'Error';
                                    mensaje =
                                        'Ocurrió un error al agregar el producto.';
                                    icono = const Icon(Icons.error_outline,
                                        color: Colors.red, size: 48);
                                }

                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    title: Row(children: [
                                      icono,
                                      const SizedBox(width: 12),
                                      Text(titulo)
                                    ]),
                                    content: Text(mensaje),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Aceptar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: Text(isAgotado ? 'Agotado' : 'Agregar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: TextStyle(fontSize: isCompact ? 13 : 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (producto.stock == 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'AGOTADO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
