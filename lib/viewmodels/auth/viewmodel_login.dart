import 'package:flutter/material.dart';
import 'package:final_project/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/data/models/users.dart';
import 'package:final_project/views/home/widgets/custom_showdialog.dart';

class LoginViewModel {
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  Future<void> iniciarSesion({
    required BuildContext context,
    required Usuario usuario,
    required VoidCallback onSuccess,
  }) async {
    try {
      if (!emailRegExp.hasMatch(usuario.correo)) {
        showFeedbackDialog(
          context: context,
          title: "Correo inválido",
          message: "Ingresa un correo electrónico válido.",
          isSuccess: false,
        );
        return;
      }

      final response = await iniciarSesionUsuario(usuario);
      print('🔐 Login response: ${response?.user?.id}');

      if (response != null && response.user != null) {
        final userId = response.user!.id;

        // Verificar si el usuario es administrador
        final adminCheck = await Supabase.instance.client
            .from('administrador')
            .select('rol')
            .eq('id', userId)
            .maybeSingle();

        print('🛡️ adminCheck: $adminCheck');

        if (adminCheck != null &&
            (adminCheck['rol'] == 'administrador' ||
                adminCheck['rol'] == 'empleado')) {
          print('⛔ Usuario bloqueado por ser $adminCheck');
          await cerrarSesionUsuario();
          showFeedbackDialog(
            context: context,
            title: "Acceso restringido",
            message: "Este usuario es inválido.",
            isSuccess: false,
          );
          return;
        }

        // Usuario válido como cliente
        print('✅ Usuario cliente: sesión iniciada');
        showFeedbackDialog(
          context: context,
          title: "Bienvenido",
          message: "Sesión iniciada correctamente con ${usuario.correo}.",
          isSuccess: true,
        );

        Future.delayed(const Duration(seconds: 1), onSuccess);
      } else {
        showFeedbackDialog(
          context: context,
          title: "Credenciales incorrectas",
          message: "Correo o contraseña incorrectos.",
          isSuccess: false,
        );
      }
    } catch (e) {
      showFeedbackDialog(
        context: context,
        title: "Error De Datos",
        message: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> cerrarSesion(BuildContext context) async {
    try {
      await cerrarSesionUsuario();
      showFeedbackDialog(
        context: context,
        title: "Sesión cerrada",
        message: "Has cerrado sesión correctamente.",
        isSuccess: true,
      );
    } catch (e) {
      showFeedbackDialog(
        context: context,
        title: "Error al cerrar sesión",
        message: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<bool> sesionActiva() async {
    return await verificarSesionActiva();
  }

  User? obtenerUsuario() {
    return obtenerUsuarioActual();
  }
}
