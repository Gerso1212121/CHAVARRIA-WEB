import 'package:final_project/views/home/widgets/custom_appBar_home.dart';
import 'package:final_project/views/home/widgets/custom_datos.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // 👈 necesario para ImageFilter

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  Color _appBarColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        _appBarColor = offset > 0
            ? const Color.fromARGB(255, 52, 52, 52)
            : Colors.transparent;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E3E3E),
      drawer: CustomTopBar.buildDrawer(context),
      endDrawer: CustomTopBar.buildCartDrawer(context),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          CustomTopBar(
            appBarColor: _appBarColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/home.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Stack(
                    children: [
                      // Capa con blur + color
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                          child: Container(
                            color: Colors.black
                                .withOpacity(0.3), // 👈 transparencia y tono
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Carpintería Chavarria',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
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
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 16)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Encuentra los mejores muebles en\nCarpintería Chavarría.\nDescubre nuestra variedad de productos\ndiseñados para tu hogar y oficina.',
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const DestacadosYCategorias(),
          ),
          SliverToBoxAdapter(
            child: AppFooter(),
          ),
        ],
      ),
    );
  }
}
