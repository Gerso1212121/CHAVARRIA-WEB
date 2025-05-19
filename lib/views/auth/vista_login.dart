import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:final_project/data/models/users.dart';
import 'package:final_project/views/auth/vista_register.dart';
import 'package:final_project/views/home/home_screen.dart';
import 'package:final_project/viewmodels/auth/viewmodel_login.dart';
import 'package:final_project/views/home/widgets/custom_showdialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginViewModel loginViewModel = LoginViewModel();

  void _registerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReguisterPage()),
    );
  }

  void _homepage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3D0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 271,
        toolbarHeight: 60,
        leading: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 209, 106, 3),
            borderRadius:
                const BorderRadius.only(bottomRight: Radius.circular(10)),
          ),
          child: Row(
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  iconSize: 30,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(left: 5),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 51, 51, 51),
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Chavarria',
                            style: TextStyle(color: Colors.white)),
                        Text('Disfruta al máximo',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                    SizedBox(width: 10),
                    Text('LOGO', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: SizedBox(
          width: 600,
          child: TextField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: "Buscar...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => print("Botón de búsqueda presionado"),
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            ),
          ),
        ),
        actions: const [SizedBox(width: 0)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
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
                                ),
                              ]),
                              const SizedBox(height: 10),
                              const Center(
                                child: Text("Inicia Sesión",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 50),
                              SizedBox(
                                width: 350,
                                child: TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Correo',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 350,
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text('Restablecer contraseña',
                                      style: TextStyle(color: Colors.green)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 250,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final correo = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();

                                    final usuario = Usuario(
                                      nombre: '',
                                      dui: '',
                                      correo: correo,
                                      telefono1: '',
                                      telefono2: '',
                                      direccion: '',
                                      password: password,
                                    );

                                    loginViewModel.iniciarSesion(
                                      context: context,
                                      usuario: usuario,
                                      onSuccess: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomePage()),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.login),
                                  label: const Text("Iniciar Sesión"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEC7521),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("¿No tienes cuenta? "),
                                  TextButton(
                                    onPressed: _registerPage,
                                    child: const Text('Regístrate aquí',
                                        style: TextStyle(color: Colors.green)),
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
                                label: const Text("Iniciar con Google"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("DISFRUTA AL MÁXIMO",
                  style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              SizedBox(width: 20),
              Icon(FontAwesomeIcons.facebook, color: Colors.orange, size: 20),
              SizedBox(width: 10),
              Icon(FontAwesomeIcons.instagram, color: Colors.orange, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                Text("2008 - 2025 ©. Carpintería Chavarría S.A. De C.V    ",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text("Ruta Militar, Col. San Francisco, San Miguel    ",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text("carpinteriachavarria@gmail.com | 503 2230-4976",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
