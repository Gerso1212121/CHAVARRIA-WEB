import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';
import 'package:final_project/viewmodels/servicios/favoritos.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:final_project/views/home/widgets/custom_appBar_home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Productos extends StatefulWidget {
  const Productos({super.key});

  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _searchKey = GlobalKey();

  String? _queryInicial;
  String? categoriaSeleccionada;
  String? ordenPrecio;
  bool soloOfertas = false;
  bool _argsAplicados = false;

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
    if (!_argsAplicados) {
      _argsAplicados = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final vm = context.read<ProductViewModel>();
          if (args is String) {
            _queryInicial = args;
            _searchController.text = args;
            vm.buscar(args);
          } else if (args is Map && args.containsKey('categoria')) {
            setState(() {
              categoriaSeleccionada = args['categoria'];
            });
          }
        });
      }
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

    // ✅ Aplicar filtros solo una vez al inicio del build
    List<Producto> productos = List.from(vm.productos);

    if (categoriaSeleccionada != null && categoriaSeleccionada != 'Todos') {
      final filtro = categoriaSeleccionada!.toLowerCase().trim();
      productos = productos
          .where(
              (p) => (p.nombreCategoria?.toLowerCase().trim() ?? '') == filtro)
          .toList();
    }

    if (soloOfertas) {
      productos = productos.where((p) => p.porcentajeDescuento > 0).toList();
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
          searchResults: vm.productos,
          searchKey: _searchKey,
          onSearchSubmitted: (text) {
            final query = text.trim();
            if (query.isEmpty) {
              vm.limpiarBusqueda();
              setState(() {
                _queryInicial = null;
                categoriaSeleccionada = null;
              });
            } else {
              setState(() {
                categoriaSeleccionada = null;
                _queryInicial = query;
              });
              vm.buscar(query);
            }
          },
        ),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildFiltros()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
                      childAspectRatio: isMobile ? 0.68 : 0.9,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: const Icon(Icons.home, size: 20),
            label: const Text('Volver a inicio'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DropdownButton<String>(
            value: categoriaSeleccionada ?? 'Todos',
            onChanged: (value) {
              setState(() {
                categoriaSeleccionada = value == 'Todos' ? null : value;
                _searchController.clear();
                _queryInicial = null;
              });
              context.read<ProductViewModel>().loadProducts();
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
}

final ValueNotifier<bool> isLoading =
    ValueNotifier(false); // Agrega esto justo arriba

Widget _buildProductoCard(BuildContext context, Producto producto) {
  final tieneDescuento = producto.porcentajeDescuento > 0;
  final precioOriginal = producto.precio ?? 0.0;
  final precioConDescuento = tieneDescuento
      ? precioOriginal * (1 - producto.porcentajeDescuento / 100)
      : precioOriginal;
  final isAgotado = producto.stock == 0;

  final ValueNotifier<bool> isFavorite = ValueNotifier(false);

  // 🔄 Carga inicial de favorito
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final result = await Supabase.instance.client
          .from('favoritos')
          .select()
          .eq('id_cliente', user.id)
          .eq('id_producto', producto.idProducto)
          .maybeSingle();

      isFavorite.value = result != null;
    }
  });

  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final aspectRatio = 0.75;
      final height = width / aspectRatio;

      return Container(
        height: height,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (tieneDescuento)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${producto.porcentajeDescuento.toInt()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

// Reemplaza el botón completo:
                  ValueListenableBuilder<bool>(
                    valueListenable: isLoading,
                    builder: (context, loading, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isAgotado || loading
                              ? null
                              : () async {
                                  final user =
                                      Supabase.instance.client.auth.currentUser;
                                  if (user == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Inicia sesión para agregar productos')),
                                    );
                                    return;
                                  }

                                  isLoading.value = true; // 🟡 Inicia carga
                                  final cartVM = context.read<CartViewModel>();
                                  final resultado = await cartVM
                                      .agregarProductoDirectoOptimizado(
                                    producto: producto,
                                    cantidad: 1,
                                  );
                                  isLoading.value = false; // ✅ Fin de carga

                                  final mensaje = switch (resultado) {
                                    AgregadoResultado.agregadoNuevo =>
                                      'Producto agregado al carrito.',
                                    AgregadoResultado.yaExiste =>
                                      'Este producto ya está en el carrito.',
                                    AgregadoResultado.sinStock =>
                                      'No hay suficiente stock.',
                                    _ => 'Ocurrió un error.',
                                  };

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(mensaje)),
                                  );
                                },
                          icon: loading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.add_shopping_cart),
                          label: Text(isAgotado
                              ? 'Agotado'
                              : loading
                                  ? 'Agregando...'
                                  : 'Agregar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Imagen del producto
            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/productoDetalle',
                    arguments: producto,
                  );
                },
                child: Hero(
                  tag: 'producto_${producto.idProducto}',
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.network(
                      producto.urlImagen ?? '',
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ),
              ),
            ),

            // Información del producto
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (producto.nombreCategoria != null)
                      Text(
                        producto.nombreCategoria!,
                        style: const TextStyle(
                          fontSize: 12,
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
                        fontSize: 13,
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
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color:
                                    isAgotado ? Colors.grey : Colors.green[700],
                              ),
                            ),
                            if (tieneDescuento)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  '\$${precioOriginal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 11,
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
            ),

            // Botón "Agregar al carrito"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isAgotado
                      ? null
                      : () async {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Inicia sesión para agregar productos')),
                            );
                            return;
                          }

                          final cartVM = context.read<CartViewModel>();
                          final resultado =
                              await cartVM.agregarProductoDirectoOptimizado(
                            producto: producto,
                            cantidad: 1,
                          );

                          final mensaje = switch (resultado) {
                            AgregadoResultado.agregadoNuevo =>
                              'Producto agregado al carrito.',
                            AgregadoResultado.yaExiste =>
                              'Este producto ya está en el carrito.',
                            AgregadoResultado.sinStock =>
                              'No hay suficiente stock.',
                            _ => 'Ocurrió un error.',
                          };

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(mensaje)),
                          );
                        },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(isAgotado ? 'Agotado' : 'Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
