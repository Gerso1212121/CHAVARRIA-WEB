import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/data/services/auth_service.dart';
import 'package:final_project/viewmodels/auth/viewmodel_emailsend.dart';

class RegisterViewModel {
  final SupabaseService _service = SupabaseService();

  Future<bool> usuarioYaExiste(String correo) async {
    final res = await Supabase.instance.client
        .from('cliente')
        .select('id_cliente')
        .eq('correo', correo)
        .limit(1);

    return res.isNotEmpty;
  }

  Future<bool> duiYaRegistrado(String dui) async {
    final res = await Supabase.instance.client
        .from('cliente')
        .select('id_cliente')
        .eq('dui', dui)
        .limit(1);

    return res.isNotEmpty;
  }

  String? validarNombre(String nombre) {
    return RegExp(r"^[a-zA-Z\s]+$").hasMatch(nombre)
        ? null
        : 'El nombre no debe contener números ni símbolos.';
  }

  String? validarDui(String dui) {
    return RegExp(r'^\d{8}-\d$').hasMatch(dui)
        ? null
        : 'Formato de DUI inválido. Ej: 12345678-9';
  }

  String? validarCorreo(String correo) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(correo)
        ? null
        : 'Correo electrónico inválido.';
  }

  String? validarTelefono(String tel) {
    return RegExp(r'^[67]\d{7}$').hasMatch(tel)
        ? null
        : 'El teléfono debe tener 8 dígitos y comenzar con 6 o 7.';
  }

  String? validarContrasena(String pass) {
    return pass.length >= 6
        ? null
        : 'La contraseña debe tener mínimo 6 caracteres.';
  }

  String generarCodigo() {
    final rand = Random();
    return List.generate(6, (_) => rand.nextInt(10).toString()).join();
  }

  Future<void> registrarUsuario({
    required BuildContext context,
    required String nombre,
    required String dui,
    required String direccion,
    required String telefono1,
    String telefono2 = '',
    required String correo,
    required String contrasena,
  }) async {
    final errores = [
      validarNombre(nombre),
      validarDui(dui),
      validarTelefono(telefono1),
      validarCorreo(correo),
      validarContrasena(contrasena),
    ].whereType<String>().toList();

    if (errores.isNotEmpty) {
      throw Exception(errores.join('\n'));
    }

    if (await usuarioYaExiste(correo)) {
      throw Exception('Ya existe un usuario con ese correo.');
    }

    if (await duiYaRegistrado(dui)) {
      throw Exception('Ya existe un usuario con ese DUI.');
    }

    final codigo = generarCodigo();
    await enviarCodigoVerificacion(
      context: context,
      correo: correo,
      nombre: nombre,
      codigo: codigo,
    );

    final ingresado = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        String input = '';
        return AlertDialog(
          title: const Text('Verificación requerida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa el código enviado a tu correo.'),
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) => input = v,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Código de verificación',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => Navigator.of(c).pop(input.trim()),
              child: const Text('Verificar'),
            ),
          ],
        );
      },
    );

    if (ingresado == null) {
      throw Exception('Verificación cancelada.');
    }

    if (ingresado != codigo) {
      throw Exception('Código incorrecto.');
    }

    late final User user;
    try {
      final authRes = await _service.signUpWithEmail(
        email: correo,
        password: contrasena,
      );
      if (authRes?.user == null) {
        throw Exception('No se pudo crear la cuenta en Auth.');
      }

      user = authRes!.user!;
    } on AuthException catch (e) {
      throw Exception('Error de Supabase Auth: ${e.message}');
    }

    final clienteMap = {
      'id_cliente': user.id,
      'nombre': nombre,
      'dui': dui,
      'direccion': direccion,
      'telefono': telefono1,
      'telefono_secundario': telefono2,
      'correo': correo,
      'origen': 'web',
    };

    try {
      await Supabase.instance.client.from('cliente').insert(clienteMap);
    } catch (e) {
      throw Exception('Error creando cliente: $e');
    }

    await enviarCorreoRegistro(
      context: context,
      nombre: nombre,
      correo: correo,
      dui: dui,
    );
  }
}
