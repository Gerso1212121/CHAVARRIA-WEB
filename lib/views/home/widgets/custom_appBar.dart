import 'package:flutter/material.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/sections/productos.dart';

class CustomTopBar extends StatelessWidget {
  final Color appBarColor;
  final Widget? flexibleSpace;

  const CustomTopBar({
    Key? key,
    required this.appBarColor,
    this.flexibleSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 500,
      backgroundColor: appBarColor,
      flexibleSpace: flexibleSpace,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          const Text(
            "Carpintería Chavarría",
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Busca aquí",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.orange),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {},
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  static Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text('Carpintería Chavarría'),
            accountEmail: Text('contacto@chavarria.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.business, color: Colors.blue, size: 50),
            ),
            decoration: BoxDecoration(color: Color(0xFF003366)),
          ),
          ListTile(
            title: const Text('Inicio'),
            leading: const Icon(Icons.home),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Productos'),
            leading: const Icon(Icons.view_list),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Productos()));
            },
          ),
          ListTile(
            title: const Text('Ofertas'),
            leading: const Icon(Icons.local_offer),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Cerrar sesión'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }

  static Widget buildCartDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text('Tu Carrito'),
            accountEmail: Text('Carrito de compras'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.shopping_cart, color: Colors.blue, size: 50),
            ),
            decoration: BoxDecoration(color: Color(0xFF003366)),
          ),
          const Divider(),
          ListTile(
            title: const Text('Ir a comprar'),
            leading: const Icon(Icons.payment),
            onTap: () {
              print("Ir a comprar");
            },
          ),
        ],
      ),
    );
  }
}
