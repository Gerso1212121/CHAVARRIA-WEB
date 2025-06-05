import 'dart:ui';
import 'package:final_project/data/models/productos.dart';
import 'package:final_project/views/home/sections/info_producto.dart';
import 'package:flutter/material.dart';
import 'package:final_project/data/services/auth_service.dart';
import 'package:final_project/viewmodels/servicios/favoritos.dart';
import 'package:final_project/views/home/widgets/custom_APPBARUNIVERSAL.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  Future<List<Map<String, dynamic>>>? _favoritosFuture;
  final TextEditingController _searchController = TextEditingController();

  bool _chequeoAuthHecho = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = SupabaseService().getCurrentUser();

      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        setState(() {
          _favoritosFuture = _obtenerFavoritos();
          _chequeoAuthHecho = true;
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> _obtenerFavoritos() async {
    try {
      final supabase = Supabase.instance.client;
      final user = SupabaseService().getCurrentUser();

      if (user == null) throw Exception('Usuario no autenticado.');

      final response = await supabase
          .from('favoritos')
          .select(
              'id_cliente, id_producto, created_at, producto!fk_producto(*)')
          .eq('id_cliente', user.id);

      return (response as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e, stackTrace) {
      debugPrint('🧨 Error al obtener favoritos: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      throw Exception('Error al obtener los favoritos. Detalles: $e');
    }
  }

  @override
    Widget build(BuildContext context) {
      if (!_chequeoAuthHecho) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final isSmall = MediaQuery.of(context).size.width < 600;

      return Scaffold(
        body: UniversalTopBarWrapper(
          allProducts: const [],
          expandedHeight: 320,
          appBarColor: const Color(0xFF3E3E3E),
          searchController: _searchController,
          onSearchChanged: null,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/home2.png', fit: BoxFit.cover),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Text(
                      'Mis Favoritos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 28 : 36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _favoritosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error,
                                color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            const Text('Hubo un error al cargar tus favoritos.',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _favoritosFuture = _obtenerFavoritos();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text("Reintentar"),
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  final favoritos = snapshot.data!;
                  if (favoritos.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No tienes productos favoritos.'),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      double aspectRatio = 0.85;

                      if (constraints.maxWidth >= 1200) {
                        crossAxisCount = 5;
                        aspectRatio = 0.85;
                      } else if (constraints.maxWidth >= 900) {
                        crossAxisCount = 4;
                        aspectRatio = 0.85;
                      } else if (constraints.maxWidth >= 600) {
                        crossAxisCount = 3;
                        aspectRatio = 0.85;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: aspectRatio,
                          children: favoritos.map((favorito) {
                            final producto = favorito['producto'];

                            if (producto == null) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('❗ Producto no encontrado.'),
                              );
                            }

                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(Icons.favorite,
                                            color: Colors.red, size: 18),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.grey, size: 18),
                                          onPressed: () async {
                                            final user = SupabaseService()
                                                .getCurrentUser();
                                            if (user == null) return;

                                            await toggleFavorito(user.id,
                                                favorito['id_producto']);
                                            setState(() {
                                              _favoritosFuture =
                                                  _obtenerFavoritos();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () {
                                        final productoObj = Producto.fromMap(
                                            producto); // 🔁 convierte el mapa
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailPage(
                                                producto: productoObj),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.amber[100],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: producto['url_imagen'] != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      producto['url_imagen']),
                                                  fit: BoxFit.contain,
                                                )
                                              : null,
                                        ),
                                        child: producto['url_imagen'] == null
                                            ? const Center(
                                                child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 28))
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: Text(
                                        producto['nombre'] ?? 'Sin nombre',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }

