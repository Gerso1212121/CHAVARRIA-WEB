import 'package:flutter/material.dart';

class LoginTopBar extends StatelessWidget implements PreferredSizeWidget {
  const LoginTopBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 53, 53, 53),
      elevation: 2,
      toolbarHeight: 60,
      leadingWidth: 36,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 20),
          splashRadius: 18,
          padding: EdgeInsets.zero,
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          const Text(
            "Carpintería Chavarría",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.width * 0.42,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Busca aquí",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                    ),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  onPressed: () => print("Botón de búsqueda presionado"),
                  icon: const Icon(Icons.search, color: Colors.orange, size: 20),
                  padding: EdgeInsets.zero,
                  splashRadius: 16,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
          onPressed: () {},
          splashRadius: 18,
          padding: EdgeInsets.zero,
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            splashRadius: 18,
            padding: EdgeInsets.zero,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white, size: 20),
          onPressed: () {},
          splashRadius: 18,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
