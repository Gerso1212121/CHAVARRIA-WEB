import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UbicacionWebService {
  static const List<String> _departamentosZonaOriental = [
    'San Miguel',
    'Morazán',
    'Usulután',
    'La Unión',
  ];

  static Future<bool> solicitarUbicacionDesdeNavegador(BuildContext context) async {
    try {
      if (html.window.navigator.geolocation != null) {
        final completer = Completer<bool>();

        html.window.navigator.geolocation!
            .getCurrentPosition()
            .then((position) async {
          final latitude = position.coords?.latitude;
          final longitude = position.coords?.longitude;

          if (latitude != null && longitude != null) {
            final esZonaOriental = await _verificarZonaOriental(
              latitude.toDouble(),
              longitude.toDouble(),
            );

            if (esZonaOriental) {
              debugPrint('✅ Usuario está en la Zona Oriental');
              completer.complete(true);
            } else {
              await _mostrarDialogo(
                context,
                titulo: 'Ubicación fuera de servicio',
                mensaje:
                    'Actualmente solo ofrecemos servicio en la Zona Oriental de El Salvador. Próximamente estaremos disponibles en otras zonas.',
              );
              completer.complete(false);
            }
          } else {
            await _mostrarDialogo(
              context,
              titulo: 'Ubicación no detectada',
              mensaje: 'No se pudieron obtener las coordenadas exactas.',
            );
            completer.complete(false);
          }
        }).catchError((error) async {
          await _mostrarDialogo(
            context,
            titulo: 'Error de ubicación',
            mensaje: 'No se pudo obtener tu ubicación: $error',
          );
          completer.complete(false);
        });

        return completer.future;
      } else {
        await _mostrarDialogo(
          context,
          titulo: 'Geolocalización no soportada',
          mensaje: 'Tu navegador no permite obtener tu ubicación.',
        );
        return false;
      }
    } catch (e) {
      await _mostrarDialogo(
        context,
        titulo: 'Excepción',
        mensaje: 'Ocurrió un error inesperado: $e',
      );
      return false;
    }
  }

  static Future<bool> _verificarZonaOriental(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterApp',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final address = data['address'];
      final state = address['state'] ?? '';
      final region = address['region'] ?? '';
      final county = address['county'] ?? '';

      final departamento = state.isNotEmpty
          ? state
          : (county.isNotEmpty ? county : region);

      debugPrint('🌍 Departamento detectado: $departamento');

      return _departamentosZonaOriental.contains(departamento);
    }

    return false;
  }

  static Future<void> _mostrarDialogo(
    BuildContext context, {
    required String titulo,
    required String mensaje,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
