import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF1F1F1),
      child: Column(
        children: [
          const Text(
            'Síguenos en redessuciales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(FontAwesomeIcons.facebook, color: Colors.black),
              SizedBox(width: 16),
              Icon(FontAwesomeIcons.instagram, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }
}
