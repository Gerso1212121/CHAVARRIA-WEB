import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SoporteClientePage extends StatelessWidget {
  const SoporteClientePage({super.key});

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'carpinteriachavarria@gmail.com',
      query:
          'subject=Soporte%20al%20cliente&body=Hola,%20necesito%20ayuda%20con...',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchWhatsApp() async {
    const phoneNumber = '+50322304976';
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte al Cliente'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              '¿Tienes problemas o preguntas?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Estamos aquí para ayudarte. Puedes contactarnos por los siguientes medios:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.deepOrange),
              title: const Text('Enviar correo electrónico'),
              subtitle: const Text('carpinteriachavarria@gmail.com'),
              onTap: _launchEmail,
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
              title: const Text('Hablar por WhatsApp'),
              subtitle: const Text('+503 2230-4976'),
              onTap: _launchWhatsApp,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('Llamar al soporte'),
              subtitle: const Text('+503 2230-4976'),
              onTap: () => launchUrl(Uri.parse('tel:+50322304976')),
            ),
          ],
        ),
      ),
    );
  }
}
