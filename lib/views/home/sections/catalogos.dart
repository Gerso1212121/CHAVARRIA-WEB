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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildFiltros(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: productos.isEmpty
                  ? const Center(child: Text('No hay productos disponibles.'))
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: productos.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 4,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        return _buildProductoCard(context, producto);
                      },
                    ),
            ),
            const SizedBox(height: 32),
            const AppFooter(),
          ],
        ),
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
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: (producto.urlImagen ?? '').isNotEmpty
                    ? Image.network(
                        producto.urlImagen!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 80),
                      )
                    : const Icon(Icons.image, size: 120),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('\$${(producto.precio ?? 0.0).toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    producto.stock > 0
                        ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final supabase = Supabase.instance.client;
                                final user = supabase.auth.currentUser;

                                if (user == null) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      title: const Text('¡Ups!'),
                                      content: const Text(
                                          'Debes iniciar sesión para agregar productos al carrito.'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancelar'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.login),
                                          label: const Text('Iniciar sesión'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
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
                                  builder: (context) => AlertDialog(
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Agregar al carrito'),
                            ),
                          )
                        : const Text(
                            'AGOTADO',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
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
  }
}
