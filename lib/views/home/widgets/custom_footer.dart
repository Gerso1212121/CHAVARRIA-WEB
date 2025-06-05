import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : 280,
                    child: _buildLogoAndSocial(),
                  ),
                  const SizedBox(width: 40),
                  if (!isMobile)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildColumn(context, "Información para clientes", [
                            {
                              "label": "Términos y condiciones",
                              "route": "/terminos"
                            },
                            {
                              "label": "Soporte al cliente",
                              "route": "/soporte"
                            },
                            {"label": "Promociones", "route": "/promociones"},
                          ]),
                          _buildColumn(context, "Gestión de la cuenta", [
                            {"label": "Mi perfil", "route": "/perfil"},
                            {
                              "label": "Historial de pedidos",
                              "route": "/historial"
                            },
                            {"label": "Cerrar sesión", "route": "/logout"},
                          ]),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 48,
                      runSpacing: 24,
                      alignment: WrapAlignment.end,
                      children: [
                        _buildColumn(context, "Información para clientes", [
                          {
                            "label": "Términos y condiciones",
                            "route": "/terminos"
                          },
                          {"label": "Soporte al cliente", "route": "/soporte"},
                          {"label": "Promociones", "route": "/promociones"},
                        ]),
                        _buildColumn(context, "Gestión de la cuenta", [
                          {"label": "Mi perfil", "route": "/perfil"},
                          {
                            "label": "Historial de pedidos",
                            "route": "/historial"
                          },
                          {"label": "Cerrar sesión", "route": "/logout"},
                        ]),
                      ],
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              return Center(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _footerItem(
                      "2008 - 2025 ©. Todos los derechos reservados\nCarpintería Chavarría\nConfort y Personalidad",
                      isMobile,
                    ),
                    _dividerOrSpacer(isMobile),
                    _footerItem(
                      "Ruta Militar. Colonia San Francisco, San Miguel.\ncarpinteriachavarria@gmail.com | 503 2230-4976",
                      isMobile,
                    ),
                    _dividerOrSpacer(isMobile),
                    _footerItem("Carpintería Chavarría S.A. De C.V", isMobile),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoAndSocial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.play_arrow, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text(
              "CHAVARRIA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "DISFRUTA AL MÁXIMO",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text("Síguenos", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.facebook,
                  color: Colors.orange, size: 18),
              onPressed: () => _launchURL('https://facebook.com'),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.instagram,
                  color: Colors.orange, size: 18),
              onPressed: () => _launchURL('https://instagram.com'),
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.whatsapp,
                  color: Colors.orange, size: 18),
              onPressed: () => _launchURL('https://wa.me/50322304976'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColumn(
      BuildContext context, String title, List<Map<String, String>> items) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...items.map(
            (item) {
              final label = item["label"]!;
              final route = item["route"]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  onTap: () async {
                    if (route == "/logout") {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          title: const Text("¿Cerrar sesión?"),
                          content: const Text(
                              "¿Estás seguro de que quieres cerrar sesión?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancelar"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange),
                              child: const Text("Cerrar sesión"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await Supabase.instance.client.auth.signOut();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      }
                    } else {
                      Navigator.pushNamed(context, route);
                    }
                  },
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _footerItem(String text, bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 300,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _dividerOrSpacer(bool isMobile) {
    return isMobile
        ? const SizedBox(height: 12)
        : const SizedBox(
            height: 40,
            child: VerticalDivider(
                color: Color.fromARGB(155, 255, 255, 255), thickness: 1),
          );
  }

  static Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
