import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:final_project/views/auth/vista_login.dart';
import 'package:final_project/views/home/widgets/custom_appBarLogin.dart';
import 'package:final_project/views/home/widgets/custom_footer.dart';

class ReguisterPage extends StatefulWidget {
  const ReguisterPage({Key? key}) : super(key: key);

  @override
  ReguisterPageState createState() => ReguisterPageState();
}

class ReguisterPageState extends State<ReguisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _duiController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();

  void _loginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3D0),
      appBar: const LoginTopBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
              const SizedBox(height: 40),

            Center(
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                          children: [
                            _buildTextField(
                              controller: _nombreController,
                              label: 'Nombre Completo',
                            ),
                            _buildTextField(
                              controller: _duiController,
                              label: 'DUI',
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
                        SizedBox(
                          width: 250,
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: const Icon(Icons.login),
                            label: const Text("Regístrate"),
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
                        const Divider(),
                        const Text("O inicia con:"),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.google, size: 18),
                          label: const Text("Regístrate con"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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
