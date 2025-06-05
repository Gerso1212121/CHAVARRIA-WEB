import 'package:final_project/views/home/sections/info_producto.dart';
import 'package:flutter/material.dart';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/home_screen.dart';
import 'package:final_project/views/home/sections/carrito_detalle.dart';
import 'package:final_project/views/home/sections/catalogos.dart';
import 'package:final_project/views/home/sections/perfil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ COLORES GLOBALES
const Color naranja = Color(0xFFF57C00);
const Color marronOscuro = Color(0xFF6D4C41);

class UniversalTopBar extends StatefulWidget {
  final bool useSliver;
  final Color appBarColor;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final List<Producto> allProducts;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final Function(String)? onSearchSubmitted;
  final List<Producto>? searchResults;
  final GlobalKey? searchKey;

  const UniversalTopBar({
    Key? key,
    this.useSliver = false,
    this.appBarColor = const Color(0xFF333333),
    this.expandedHeight = 0,
    this.flexibleSpace,
    required this.allProducts,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.searchResults,
    this.searchKey,
  }) : super(key: key);

  // ✅ Drawer y carrito estáticos
  static Widget buildDrawer(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'invitado@chavarria.com';
    final nombre = user?.userMetadata?['nombre'] ?? 'Cliente';
    final isAutenticado = user != null;

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(isAutenticado ? nombre : 'Invitado'),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: marronOscuro,
                child: Icon(Icons.business, color: Colors.white, size: 50),
              ),
              decoration: const BoxDecoration(color: marronOscuro),
            ),
            ListTile(
              title: const Text('Inicio'),
              leading: const Icon(Icons.home, color: marronOscuro),
              onTap: () => Navigator.pushNamed(context, '/'),
            ),
            ListTile(
              title: const Text('Productos'),
              leading: const Icon(Icons.view_list, color: marronOscuro),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const Productos())),
            ),
            ListTile(
              title: Text(isAutenticado ? 'Cerrar sesión' : 'Iniciar sesión'),
              leading: Icon(isAutenticado ? Icons.exit_to_app : Icons.login,
                  color: isAutenticado ? Colors.redAccent : Colors.green),
              onTap: () {
                if (!isAutenticado) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginPage()));
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('¿Cerrar sesión?'),
                      content:
                          const Text('¿Estás seguro que deseas cerrar sesión?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          onPressed: () async {
                            final cartVM = context.read<CartViewModel>();
                            cartVM.onCerrarSesion = () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                                (route) => false,
                              );
                            };
                            await cartVM.cerrarSesion();
                          },
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildCartDrawer(BuildContext context) {
    return Drawer(
      child: Consumer<CartViewModel>(
        builder: (context, cartViewModel, _) {
          if (cartViewModel.items.isEmpty && !cartViewModel.isLoading) {
            cartViewModel.loadItemsFromSupabase();
          }

          final cartItems =
              cartViewModel.items.where((item) => item.stock > 0).toList();

          return Column(
            children: [
              const UserAccountsDrawerHeader(
                accountName: Text('Tu Carrito'),
                accountEmail: Text('Carrito de compras'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.shopping_cart, color: Colors.orange, size: 50),
                ),
                decoration: BoxDecoration(color: Colors.orange),
              ),
              Expanded(
                child: cartViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : cartItems.isEmpty
                        ? const Center(
                            child: Text('No tienes nada agregado aún.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: item.imagenUrl.isNotEmpty
                                            ? Image.network(
                                                item.imagenUrl,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(Icons
                                                        .image_not_supported),
                                              )
                                            : const Icon(Icons.image, size: 60),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.nombre,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Stock: ${item.stock}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => cartViewModel
                                            .eliminarItemDeCarrito(item.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Total: \$${cartViewModel.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (cartItems.isNotEmpty)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Finalizar compra'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        icon: const Icon(Icons.store),
                        label: const Text('Ir a comprar'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const Productos()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  State<UniversalTopBar> createState() => _UniversalTopBarState();
}

class _UniversalTopBarState extends State<UniversalTopBar> {
  bool showSearchField = false;

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    final titleRow = isSmallScreen
        ? showSearchField
            ? _buildMobileSearch()
            : const SizedBox()
        : _buildDesktopSearch();

    final actions = isSmallScreen
        ? [
            IconButton(
              icon: Icon(showSearchField ? Icons.close : Icons.search,
                  color: Colors.white),
              onPressed: () =>
                  setState(() => showSearchField = !showSearchField),
            ),
            Builder(
              builder: (context) => PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 0) Scaffold.of(context).openEndDrawer();
                  if (value == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PerfilUsuarioPage()),
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 0, child: Text('Carrito')),
                  PopupMenuItem(value: 1, child: Text('Perfil')),
                ],
              ),
            ),
          ]
        : [
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              tooltip: 'Ver favoritos',
              onPressed: () {
                Navigator.pushNamed(context, '/favoritos');
              },
            ),
            Consumer<CartViewModel>(
              builder: (context, cartVM, _) {
                // ✅ Cargar al iniciar si aún no se ha hecho
                if (!cartVM.isLoading && cartVM.items.isEmpty) {
                  cartVM.loadItemsFromSupabase();
                }

                final count = cartVM.items.length;
                final showBadge = count > 0;

                return Stack(
                  clipBehavior: Clip.none, // para que el badge no se recorte
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.white),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                    if (showBadge)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              count > 6 ? '6+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilUsuarioPage()),
              ),
            ),
          ];

    return widget.useSliver
        ? SliverAppBar(
            pinned: true,
            expandedHeight: widget.expandedHeight,
            backgroundColor: widget.appBarColor,
            flexibleSpace: widget.flexibleSpace,
            toolbarHeight: isSmallScreen ? 56 : 72,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: titleRow,
            actions: actions,
          )
        : AppBar(
            backgroundColor: widget.appBarColor,
            elevation: 2,
            toolbarHeight: isSmallScreen ? 56 : 72,
            title: titleRow,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: actions,
          );
  }

  Widget _buildMobileSearch() {
    final bool showResults = (widget.searchResults?.isNotEmpty ?? false) &&
        (widget.searchController?.text.trim().isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: TextField(
            key: widget.searchKey,
            controller: widget.searchController,
            onChanged: widget.onSearchChanged,
            onSubmitted: widget.onSearchSubmitted,
            decoration: InputDecoration(
              hintText: "Buscar...",
              border: InputBorder.none,
              suffixIcon: widget.searchController!.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController!.clear();
                        widget.onSearchChanged?.call('');
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        if (showResults && MediaQuery.of(context).size.width >= 600)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: widget.searchResults!.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final producto = widget.searchResults![index];
                  return ListTile(
                    leading: (producto.urlImagen ?? '').isNotEmpty
                        ? Image.network(
                            producto.urlImagen!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.image),
                    title: Text(
                      producto.nombre,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '\$${(producto.precio ?? 0.0).toStringAsFixed(2)}',
                    ),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(producto: producto),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          )
      ],
    );
  }

  Widget _buildDesktopSearch() {
    return Row(
      children: [
        const Text(
          "Carpintería Chavarría",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: widget.searchKey,
                  controller: widget.searchController,
                  onChanged: widget.onSearchChanged,
                  onSubmitted: widget.onSearchSubmitted,
                  decoration: const InputDecoration(
                    hintText: "Busca aquí...",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, size: 20, color: Colors.black54),
                onPressed: () {
                  final text = widget.searchController?.text.trim() ?? '';
                  if (text.isNotEmpty) {
                    widget.onSearchChanged?.call(text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Productos()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
