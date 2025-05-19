import 'package:flutter/material.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCartTap;

  const CustomNavbar({super.key, required this.onCartTap});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF003366),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            padding: EdgeInsets.zero,
            iconSize: 24,
          );
        },
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/logo.png',
            height: 35,
            fit: BoxFit.contain,
          ),
          Expanded(
            child: Center(
              child: Container(
                height: 35,
                width: 1000,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Busca aquí',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    suffixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite, size: 22, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart, size: 22, color: Colors.white),
          onPressed: onCartTap,
        ),
        IconButton(
          icon: const Icon(Icons.person, size: 22, color: Colors.white),
          onPressed: () {},
        ),
      ],
      toolbarHeight: 60,
    );
  }
}
