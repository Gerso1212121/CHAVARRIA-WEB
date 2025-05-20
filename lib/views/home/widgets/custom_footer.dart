import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // Lema y redes sociales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "DISFRUTA AL MÁXIMO",
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Row(
                children: const [
                  Icon(FontAwesomeIcons.facebook, color: Colors.orange, size: 18),
                  SizedBox(width: 12),
                  Icon(FontAwesomeIcons.instagram, color: Colors.orange, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Divider(color: Colors.white24),

          const SizedBox(height: 10),

          // Información de contacto
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 10,
            children: const [
              Icon(Icons.copyright, size: 14, color: Colors.white70),
              Text(
                "2008 - 2025 Carpintería Chavarría S.A. de C.V.",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Icon(Icons.location_on_outlined, size: 14, color: Colors.white70),
              Text(
                "Ruta Militar, Col. San Francisco, San Miguel",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Icon(Icons.mail_outline, size: 14, color: Colors.white70),
              Text(
                "carpinteriachavarria@gmail.com",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Icon(Icons.phone_outlined, size: 14, color: Colors.white70),
              Text(
                "503 2230-4976",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
