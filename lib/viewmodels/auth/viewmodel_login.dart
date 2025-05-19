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

      if (response != null && response.user != null) {
        showFeedbackDialog(
          context: context,
          title: "Bienvenido",
          message:
              "Sesión iniciada correctamente con ${usuario.correo}.", // Aquí puedes agregar fecha
          isSuccess: true,
        );

        // TODO: aquí puedes llamar tu función para enviar email de notificación

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

  Future<void> registrarNuevoUsuario({
    required BuildContext context,
    required Usuario usuario,
  }) async {
    if (!emailRegExp.hasMatch(usuario.correo)) {
      showFeedbackDialog(
        context: context,
        title: "Correo inválido",
        message: "Por favor, ingresa un correo electrónico válido.",
        isSuccess: false,
      );
      return;
    }

    try {
      final response = await registrarUsuario(usuario);

      if (response != null && response.user != null) {
        showFeedbackDialog(
          context: context,
          title: "Registro exitoso",
          message:
              "Tu cuenta ha sido registrada. Inicia sesión para continuar.",
          isSuccess: true,
        );
      } else {
        showFeedbackDialog(
          context: context,
          title: "Error en el registro",
          message: "No se pudo completar el registro.",
          isSuccess: false,
        );
      }
    } catch (e) {
      showFeedbackDialog(
        context: context,
        title: "Error",
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
