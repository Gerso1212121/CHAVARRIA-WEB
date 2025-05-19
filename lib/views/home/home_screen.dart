import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:final_project/views/home/sections/productos.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/auth/vista_login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openCartDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E3E3E),
      drawer: _buildDrawer(context),
      endDrawer: _buildCartDrawer(),
      //appbar por cualquier cosa
      body: CustomScrollView(
        slivers: [
          _buildHeroSection(context),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildProductSection(title: "Ofertas")),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
              child: _buildProductSection(title: "Más Vendidos")),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(child: _buildSocialMediaSection()),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 480,
      pinned: true,
      backgroundColor: const Color(0xFF2B2B2B),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color(0xFF2B2B2B),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: const TextField(
                  decoration: InputDecoration(
                      hintText: "Carpinteria Chavarria",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Busca aquí",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.orange),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://media.istockphoto.com/id/1442113721/es/foto/sof%C3%A1-de-tela-blanca-planta-de-higo-de-hoja-de-viol%C3%ADn-escritorio-de-trabajo-de-madera-y-silla.jpg?s=612x612&w=0&k=20&c=MQjIkbbNLEqMq9N9DxRQMFnNsSgwd0yO3NxtoQAOsXE=',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.5)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Carpintería Chavarria',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Haz clic para ver productos',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
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
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Encuentra los mejores muebles en\nCarpintería Chavarría.\nDescubre nuestra variedad de productos\ndiseñados para tu hogar y oficina.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
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

  Widget _buildProductSection({required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Text('Producto ${index + 1}'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF1F1F1),
      child: Column(
        children: [
          const Text(
            'Síguenos en redes sociales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(FontAwesomeIcons.facebook, color: Colors.black),
              SizedBox(width: 16),
              Icon(FontAwesomeIcons.instagram, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
            decoration: BoxDecoration(
              color: Color(0xFF003366),
            ),
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
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => Productos()));
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
              final response = Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartDrawer() {
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
            decoration: BoxDecoration(
              color: Color(0xFF003366),
            ),
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
