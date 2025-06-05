import 'package:final_project/data/services/ubicacion_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

import 'package:final_project/viewmodels/auth/viewmodel_register.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/widgets/custom_appBar_home.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';
import 'package:final_project/views/home/widgets/custom_showdialog.dart';

class ReguisterPage extends StatefulWidget {
  const ReguisterPage({Key? key}) : super(key: key);

  @override
  ReguisterPageState createState() => ReguisterPageState();
}

class ReguisterPageState extends State<ReguisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _duiController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _telefono2Controller = TextEditingController(); // NUEVO
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _aceptaTerminos = false;
  bool _isRegistrando = false;

  void _loginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _submitForm() async {
    if (_isRegistrando) return;

    if (!_aceptaTerminos) {
      showFeedbackDialog(
        context: context,
        title: 'Acepta los términos',
        message: 'Debes aceptar los Términos y Condiciones antes de continuar.',
        isSuccess: false,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (kIsWeb) {
        final ubicacionOk =
            await UbicacionWebService.solicitarUbicacionDesdeNavegador(context);
        if (!ubicacionOk) return;
      }

      final registerVM = RegisterViewModel();

      setState(() {
        _isRegistrando = true;
      });

      try {
        await registerVM.registrarUsuario(
          context: context,
          nombre: _nombreController.text.trim(),
          dui: _duiController.text.trim(),
          direccion: _direccionController.text.trim(),
          telefono1: _telefonoController.text.trim(),
          telefono2: _telefono2Controller.text.trim(),
          correo: _correoController.text.trim(),
          contrasena: _contrasenaController.text.trim(),
        );

        showFeedbackDialog(
          context: context,
          title: 'Registro exitoso',
          message:
              'Tu cuenta fue creada correctamente. Ahora puedes iniciar sesión.',
          isSuccess: true,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loginPage();
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        );
      } catch (e) {
        showFeedbackDialog(
          context: context,
          title: 'Error en el registro',
          message: e.toString().replaceAll('Exception: ', ''),
          isSuccess: false,
        );
      } finally {
        setState(() {
          _isRegistrando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _duiController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _telefono2Controller.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "Regístrate",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          runSpacing: 16,
                          spacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildTextField(
                              controller: _nombreController,
                              label: 'Nombre Completo',
                            ),
                            _buildTextField(
                              controller: _duiController,
                              label: 'DUI',
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (value.length == 8 && !value.contains('-')) {
                                  _duiController.text = '$value-';
                                  _duiController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: _duiController.text.length),
                                  );
                                }
                              },
                            ),
                            _buildTextField(
                              controller: _direccionController,
                              label: 'Dirección',
                            ),
                            _buildTextField(
                              controller: _telefonoController,
                              label: 'Teléfono',
                              keyboardType: TextInputType.phone,
                            ),
                            _buildTextField(
                              controller: _telefono2Controller,
                              label: 'Teléfono 2',
                              keyboardType: TextInputType.phone,
                            ),
                            _buildTextField(
                              controller: _correoController,
                              label: 'Correo',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _buildTextField(
                              controller: _contrasenaController,
                              label: 'Contraseña',
                              obscureText: true,
                            ),
                            _buildTextField(
                              controller: _confirmarController,
                              label: 'Confirmar Contraseña',
                              obscureText: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _aceptaTerminos,
                          onChanged: (value) {
                            setState(() => _aceptaTerminos = value ?? false);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Wrap(
                            children: [
                              const Text('Acepto los '),
                              GestureDetector(
                                onTap: () {
                                  if (kIsWeb) {
                                    html.window.open('/#/terminos', '_blank');
                                  } else {
                                    Navigator.pushNamed(context, '/terminos');
                                  }
                                },
                                child: const Text(
                                  'Términos y Condiciones',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 250,
                          child: ElevatedButton.icon(
                            onPressed: _isRegistrando ? null : _submitForm,
                            icon: _isRegistrando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(_isRegistrando
                                ? "Registrando..."
                                : "Regístrate"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEC7521),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("¿Ya tienes cuenta? "),
                            TextButton(
                              onPressed: _loginPage,
                              child: const Text(
                                'Ingresa aquí',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Este campo es obligatorio';
          }
          if (label == 'Confirmar Contraseña' &&
              controller.text != _contrasenaController.text) {
            return 'Las contraseñas no coinciden';
          }
          return null;
        },
      ),
    );
  }
}
