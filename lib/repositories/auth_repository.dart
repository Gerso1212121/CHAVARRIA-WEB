import 'package:final_project/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/data/models/users.dart';

final SupabaseService _supabaseService = SupabaseService();

Future<AuthResponse?> iniciarSesionUsuario(Usuario usuario) {
  return _supabaseService.signInWithEmail(
    email: usuario.correo,
    password: usuario.password,
  );
}

Future<AuthResponse?> registrarUsuario(Usuario usuario) {
  return _supabaseService.signUpWithEmail(
    email: usuario.correo,
    password: usuario.password,
  );
}

Future<void> cerrarSesionUsuario() {
  return _supabaseService.signOut();
}

Future<bool> verificarSesionActiva() {
  return _supabaseService.isSessionActive();
}

User? obtenerUsuarioActual() {
  return _supabaseService.getCurrentUser();
}




