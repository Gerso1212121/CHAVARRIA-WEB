import 'package:final_project/main.dart';
import 'package:final_project/views/home/widgets/custom_appBarLogin.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:final_project/data/services/supabase_services.dart';
import 'package:final_project/views/home/home_screen.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/viewmodels/auth/viewmodel_register.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart'; // ✅ el correcto

class ReguisterPage extends StatefulWidget {
  const ReguisterPage({Key? key}) : super(key: key);

  @override
  ReguisterPageState createState() => ReguisterPageState();
}

class ReguisterPageState extends State<ReguisterPage> {
  void _homepage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.2), // Desliza desde abajo
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _loginPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.2), // Desde abajo hacia el centro
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3D0),
      appBar: const LoginTopBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 20),
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: _homepage,
                                      )
                                    ]),
                                    Row(children: const [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "Regístrate",
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: 50),
                                    TextField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Correo',
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: 250,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Lógica de registro
                                        },
                                        icon: const Icon(Icons.account_circle),
                                        label: const Text("Regístrate"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFEC7521),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text("¿Ya tienes cuenta? "),
                                        TextButton(
                                          onPressed: _loginPage,
                                          child: const Text('Inicia aquí',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 30),
                                    const Text("O inicia con:"),
                                    const SizedBox(height: 10),
                                    OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(FontAwesomeIcons.google,
                                          size: 18),
                                      label:
                                          const Text("Regístrate con Google"),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const AppFooter(), // ✅ Siempre abajo, nunca fuera de vista
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
