import 'package:final_project/data/models/productos.dart';
import 'package:final_project/data/services/auth_service.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:final_project/views/home/widgets/custom_historialEnvios.dart';
import 'package:final_project/views/home/widgets/historialpedidos.dart';
import 'package:final_project/views/home/widgets/popup2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/widgets/custom_appBar_home.dart';
import 'package:final_project/viewmodels/productos/productos_viewmodel.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  Map<String, dynamic>? usuario;
  bool sinSesion = false;
  String currentSection = 'Perfil';
  bool mostrarEnvios = false;

  late SearchPopupController searchPopup;
  final supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productos = context.watch<ProductViewModel>().todosLosProductos;
    searchPopup =
        SearchPopupController(context: context, allProducts: productos);
  }

  @override
  void dispose() {
    searchPopup.dispose();
    super.dispose();
  }

  Future<void> cargarDatosUsuario() async {
    final user = supabaseService.getCurrentUser();

    if (user == null) {
      setState(() => sinSesion = true);
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('cliente')
          .select()
          .eq('id_cliente', user.id)
          .single();

      setState(() => usuario = data);
    } catch (e) {
      setState(() => sinSesion = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductViewModel>().todosLosProductos;

    final universalTopBar = UniversalTopBar(
      useSliver: false,
      appBarColor: const Color.fromARGB(255, 50, 50, 50),
      allProducts: productos,
      searchController: searchPopup.controller,
      onSearchChanged: searchPopup.onSearchChanged,
      onSearchSubmitted: searchPopup.onSearchSubmitted,
      searchResults: searchPopup.results,
      searchKey: searchPopup.searchKey,
    );

    if (sinSesion) {
      return Scaffold(
        drawer: UniversalTopBar.buildDrawer(context),
        endDrawer: UniversalTopBar.buildCartDrawer(context),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: universalTopBar,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 60, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('No has iniciado sesión',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                  'Debes iniciar sesión o registrarte para ver tu perfil.'),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Ir a Iniciar Sesión'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      );
    }

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: UniversalTopBar.buildDrawer(context),
      endDrawer: UniversalTopBar.buildCartDrawer(context),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 72,
                child: universalTopBar,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWideScreen = constraints.maxWidth >= 800;

                      final perfilCard = Container(
                        width: isWideScreen
                            ? constraints.maxWidth * 0.3
                            : double.infinity,
                        margin: const EdgeInsets.only(right: 16, bottom: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 👇 BOTÓN NUEVO PARA VOLVER AL INICIO
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/', (route) => false);
                                },
                                icon: const Icon(Icons.home,
                                    color: Colors.orange),
                                label: const Text(
                                  'Volver al inicio',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            const Text('👤 Perfil del Cliente',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333))),
                            const SizedBox(height: 20),
                            _buildInfoRow(Icons.person, 'Nombre',
                                usuario!['nombre'] ?? 'No disponible'),
                            _buildInfoRow(Icons.email, 'Correo',
                                usuario!['correo'] ?? 'No disponible'),
                            _buildInfoRow(Icons.credit_card, 'DUI',
                                _ocultarDui(usuario!['dui'] ?? '')),
                            _buildInfoRow(Icons.location_on, 'Dirección',
                                usuario!['direccion'] ?? 'No registrada'),
                            _buildInfoRow(Icons.phone, 'Teléfono 1',
                                usuario!['telefono'] ?? 'No disponible'),
                            _buildInfoRow(
                                Icons.phone_android,
                                'Teléfono 2',
                                usuario!['telefono_secundario'] ??
                                    'No registrado'),
                            _buildInfoRow(
                                Icons.calendar_month,
                                'Fecha de Registro',
                                _formatearFecha(usuario!['created_at'] ?? '')),
                          ],
                        ),
                      );

                      final pedidosEnviosCard = Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    mostrarEnvios
                                        ? '🚚 Historial de Envíos'
                                        : '📦 Historial de Pedidos',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        mostrarEnvios = !mostrarEnvios;
                                      });
                                    },
                                    icon: Icon(
                                      mostrarEnvios
                                          ? Icons.list
                                          : Icons.local_shipping,
                                      color: Colors.orange,
                                    ),
                                    label: Text(
                                      mostrarEnvios
                                          ? 'Ver pedidos'
                                          : 'Ver envíos',
                                      style:
                                          const TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              mostrarEnvios
                                  ? HistorialEnvios(usuario!['id_cliente'])
                                  : HistorialPedidos(usuario!['id_cliente']),
                            ],
                          ),
                        ),
                      );

                      if (isWideScreen) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            perfilCard,
                            pedidosEnviosCard,
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            perfilCard,
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              child: pedidosEnviosCard.child,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          searchPopup.buildPopup(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                      fontSize: 14,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF222222),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _ocultarDui(String dui) =>
      dui.length == 10 ? '*****${dui.substring(5)}' : '**********';

  String _formatearFecha(String fecha) {
    final parsed = DateTime.tryParse(fecha);
    if (parsed == null) return 'Fecha inválida';
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }
}
