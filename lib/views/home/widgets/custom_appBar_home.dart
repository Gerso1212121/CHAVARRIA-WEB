import 'dart:io';

import 'package:final_project/data/models/carrito.dart';
import 'package:final_project/data/services/carrito_service.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:final_project/views/home/home_screen.dart';
import 'package:final_project/views/home/sections/carrito.dart';
import 'package:final_project/views/home/sections/perfil.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/sections/productos.dart';
import 'package:provider/provider.dart';

class CustomTopBar extends StatelessWidget {
  final Color appBarColor;
  final Widget? flexibleSpace;

  const CustomTopBar({
    Key? key,
    required this.appBarColor,
    this.flexibleSpace,
  }) : super(key: key);

  static const Color naranja = Color(0xFFF57C00);
  static const Color marronClaro = Color(0xFF8D6E63);
  static const Color marronOscuro = Color(0xFF6D4C41);
  static const Color beige = Color(0xFFFDFCE5);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SliverAppBar(
      pinned: true,
      expandedHeight: isSmallScreen ? 250 : 500,
      backgroundColor: appBarColor,
      flexibleSpace: flexibleSpace,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              const Text(
                "Carpintería Chavarría",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (!isSmallScreen)
                Container(
                  width: constraints.maxWidth * 0.4,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Busca aquí",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            isDense: true,
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search, color: naranja),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      actions: isSmallScreen
          ? [
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      Scaffold.of(context).openEndDrawer();
                      break;
                    case 1:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserProfilePage()),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 0, child: Text('Carrito')),
                  PopupMenuItem(value: 1, child: Text('Perfil')),
                ],
              ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserProfilePage()),
                  );
                },
              ),
            ],
    );
  }

  static Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Carpintería Chavarría'),
              accountEmail: Text('contacto@chavarria.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: beige,
                child: Icon(Icons.business, color: marronOscuro, size: 50),
              ),
              decoration: BoxDecoration(color: marronClaro),
            ),
            ListTile(
              title: const Text('Inicio'),
              leading: const Icon(Icons.home, color: marronOscuro),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              title: const Text('Productos'),
              leading: const Icon(Icons.view_list, color: marronOscuro),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Productos()),
                );
              },
            ),
            ListTile(
              title: const Text('Ofertas'),
              leading: const Icon(Icons.local_offer, color: naranja),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Cerrar sesión'),
              leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
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
        final cartItems = cartViewModel.items;

        if (cartItems.isEmpty) {
          return const Center(child: Text('No tienes nada agregado al carrito.'));
        }

        return Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Tu Carrito'),
              accountEmail: Text('Carrito de compras'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.shopping_cart, color: Colors.orange, size: 50),
              ),
              decoration: BoxDecoration(color: Colors.orange),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    leading: item.imagenUrl.isNotEmpty
                        ? Image.network(item.imagenUrl, width: 50, height: 50)
                        : const Icon(Icons.image),
                    title: Text(item.nombre),
                    subtitle: Text('Cantidad: ${item.cantidad}'),
                    trailing: Text('\$${(item.precio * item.cantidad).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                'Total: \$${cartViewModel.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.attach_money, color: Colors.green),
            ),
            ListTile(
              title: const Text('Ir a comprar'),
              leading: const Icon(Icons.payment, color: Colors.orange),
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ],
        );
      },
    ),
  );

}



  static Widget buildUserDrawer(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Tu Perfil'),
              accountEmail: Text('Perfil de usuario'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: beige,
                child: Icon(Icons.person, color: naranja, size: 50),
              ),
              decoration: BoxDecoration(color: naranja),
            ),
            const Divider(),
            ListTile(
              title: const Text('Mi Perfil'),
              leading: const Icon(Icons.person, color: naranja),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfilePage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Pedidos'),
              leading: const Icon(Icons.history, color: naranja),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfilePage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings, color: naranja),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
