import 'package:final_project/data/models/productos.dart';
import 'package:final_project/data/services/auth_service.dart';
import 'package:final_project/viewmodels/productos/carrito_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/widgets/custom_appBar_home.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  Map<String, dynamic>? usuario;
  bool sinSesion = false;
  String currentSection = 'Perfil';

  final List<Producto> productosVacios = [];
  final TextEditingController buscadorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }
  

  Future<void> cargarDatosUsuario() async {
    final supabaseService = SupabaseService();
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
    final universalTopBar = UniversalTopBar(
      useSliver: false,
      appBarColor: const Color.fromARGB(255, 50, 50, 50),
      allProducts: productosVacios,
      searchController: buscadorController,
      onSearchChanged: (_) {},
      searchResults: const [],
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: universalTopBar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;

            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSidebar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildMainContent(),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainContent(),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => currentSection = 'Perfil'),
                    icon: const Icon(Icons.person),
                    label: const Text("Perfil"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => currentSection = 'Pedidos'),
                    icon: const Icon(Icons.list_alt),
                    label: const Text("Pedidos"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _cerrarSesion(context),
                    icon: const Icon(Icons.logout),
                    label: const Text("Cerrar sesión"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: const Color(0xFFF4F4F4),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 30),
          const SizedBox(height: 10),
          const Text('Hola!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          _sidebarItem('Perfil', selected: currentSection == 'Perfil'),
          _sidebarItem('Pedidos', selected: currentSection == 'Pedidos'),
          const Divider(),
          _sidebarItem('Salir', isExit: true),
        ],
      ),
    );
  }

  Widget _sidebarItem(String title,
      {bool selected = false, bool isExit = false}) {
    return InkWell(
      onTap: () async {
        if (isExit) {
          await _cerrarSesion(context);
        } else {
          setState(() => currentSection = title);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: selected
            ? const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.red, width: 3)))
            : null,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.black : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final cartVM = context.read<CartViewModel>();
      cartVM.onCerrarSesion = () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      };
      await cartVM.cerrarSesion();
    }
  }

  Widget _buildMainContent() {
    if (currentSection == 'Perfil') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.orange),
                tooltip: 'Volver',
              ),
              const SizedBox(width: 8),
              const Text(
                '👤 Mi Perfil',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
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
              children: [
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
                _buildInfoRow(Icons.phone_android, 'Teléfono 2',
                    usuario!['telefono_secundario'] ?? 'No registrado'),
                _buildInfoRow(Icons.calendar_month, 'Fecha de Registro',
                    _formatearFecha(usuario!['created_at'] ?? '')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Editar Información'),
            ),
          )
        ],
      );
    } else {
      return Center(
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
          child: const Text(
            '📦 Aquí se mostraría el historial de pedidos.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
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
