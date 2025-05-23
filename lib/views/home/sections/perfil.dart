import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _duiController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefono1Controller = TextEditingController();
  final TextEditingController _telefono2Controller = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Aquí puedes cargar los datos del usuario desde tu modelo o base de datos
    _nombreController.text = 'Juan Pérez';
    _duiController.text = '12345678-9';
    _direccionController.text = 'San Salvador, El Salvador';
    _telefono1Controller.text = '+503 7000 0000';
    _telefono2Controller.text = '+503 7000 0001';
    _correoController.text = 'juan.perez@example.com';
  }

  void _guardarPerfil() {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes guardar los datos actualizados del usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: const Color(0xFFEC7521),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.85,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre Completo',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _duiController,
                    label: 'DUI',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _direccionController,
                    label: 'Dirección',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _telefono1Controller,
                    label: 'Teléfono 1',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _telefono2Controller,
                    label: 'Teléfono 2',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _correoController,
                    label: 'Correo Electrónico',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _guardarPerfil,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC7521),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
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
        if (label == 'Correo Electrónico' &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch(value.trim())) {
          return 'Ingrese un correo válido';
        }
        return null;
      },
    );
  }
}
