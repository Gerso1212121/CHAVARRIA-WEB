import 'dart:math';
import 'package:final_project/repositories/auth_repository.dart';
import 'package:final_project/viewmodels/auth/viewmodel_password.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:flutter/material.dart';
import 'package:final_project/viewmodels/auth/viewmodel_emailsend.dart';
import 'package:final_project/views/home/widgets/custom_appBar_home.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:final_project/views/home/widgets/custom_showdialog.dart';

class VistaOlvidePassword extends StatefulWidget {
  const VistaOlvidePassword({Key? key}) : super(key: key);

  @override
  State<VistaOlvidePassword> createState() => _VistaOlvidePasswordState();
}

class _VistaOlvidePasswordState extends State<VistaOlvidePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nuevaPassController = TextEditingController();
  final TextEditingController _confirmarPassController =
      TextEditingController();

  String? _codigoEnviado;
  bool _codigoEnviadoCorrectamente = false;
  bool _codigoVerificado = false;

  String _generarCodigo() {
    final rand = Random();
    return List.generate(6, (_) => rand.nextInt(10)).join();
  }

  Future<void> _enviarCodigo() async {
    if (_formKey.currentState!.validate()) {
      final correo = _correoController.text.trim();
      final codigo = _generarCodigo();

      final bool enviado = await enviarCodigoValido(
        context: context,
        correo: correo,
        nombre: 'Usuario',
        codigo: codigo,
      );

      if (enviado && mounted) {
        setState(() {
          _codigoEnviado = codigo;
          _codigoEnviadoCorrectamente = true;
        });

        showFeedbackDialog(
          context: context,
          title: 'Código enviado',
          message: 'Revisa tu correo y escribe el código para continuar.',
          isSuccess: true,
        );
      }
    }
  }

  void _verificarCodigo() {
    if (_codigoController.text.trim() == _codigoEnviado) {
      setState(() {
        _codigoVerificado = true;
      });
      showFeedbackDialog(
        context: context,
        title: 'Código verificado',
        message: 'Ahora puedes ingresar tu nueva contraseña.',
        isSuccess: true,
      );
    } else {
      showFeedbackDialog(
        context: context,
        title: 'Código incorrecto',
        message: 'El código ingresado no coincide.',
        isSuccess: false,
      );
    }
  }

  Future<void> _cambiarPassword() async {
    final nueva = _nuevaPassController.text.trim();
    final confirmar = _confirmarPassController.text.trim();

    if (nueva.isEmpty || confirmar.isEmpty) {
      showFeedbackDialog(
        context: context,
        title: 'Error',
        message: 'Completa ambos campos.',
        isSuccess: false,
      );
      return;
    }

    if (nueva.length < 6) {
      showFeedbackDialog(
        context: context,
        title: 'Error',
        message: 'La contraseña debe tener al menos 6 caracteres.',
        isSuccess: false,
      );
      return;
    }

    if (nueva != confirmar) {
      showFeedbackDialog(
        context: context,
        title: 'Error',
        message: 'Las contraseñas no coinciden.',
        isSuccess: false,
      );
      return;
    }

    final correo = _correoController.text.trim();

    try {
      await resetearPasswordDesdeBackend(
        correo: correo,
        nuevaPassword: nueva,
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Éxito',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content:
              const Text('Tu contraseña ha sido actualizada correctamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      showFeedbackDialog(
        context: context,
        title: 'Error',
        message: errorMsg,
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3D0),
      drawer: UniversalTopBar.buildDrawer(context),
      endDrawer: UniversalTopBar.buildCartDrawer(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: UniversalTopBar(
          useSliver: false,
          appBarColor: const Color.fromARGB(255, 51, 51, 51),
          allProducts: const [],
          searchController: TextEditingController(),
          onSearchChanged: (_) {},
          searchResults: const [],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF4E3D0), // fondo durazno
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // 💥 Centramos verticalmente
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 40),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(height: 10),
                              const Center(
                                child: Text(
                                  "Recuperar contraseña",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                controller: _correoController,
                                enabled: !_codigoEnviadoCorrectamente,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Correo',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El correo es obligatorio';
                                  }
                                  final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Ingrese un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              if (!_codigoEnviadoCorrectamente)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _enviarCodigo,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEC7521),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    child: const Text("Enviar código"),
                                  ),
                                ),
                              if (_codigoEnviadoCorrectamente &&
                                  !_codigoVerificado) ...[
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _codigoController,
                                  decoration: InputDecoration(
                                    labelText: 'Código recibido',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _verificarCodigo,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    child: const Text("Verificar código"),
                                  ),
                                ),
                              ],
                              if (_codigoVerificado) ...[
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _nuevaPassController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Nueva contraseña',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _confirmarPassController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar contraseña',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _cambiarPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                    child: const Text("Cambiar contraseña"),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // espacio visual extra
                    const AppFooter(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
