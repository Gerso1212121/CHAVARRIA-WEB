import 'package:flutter/material.dart';

class DestacadosYCategorias extends StatelessWidget {
  const DestacadosYCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Beneficios rápidos
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 40,
            runSpacing: 24,
            children: const [
              BeneficioItem(icon: Icons.local_shipping, title: 'Envío rápido'),
              BeneficioItem(icon: Icons.handyman, title: 'Hecho a mano'),
              BeneficioItem(
                  icon: Icons.design_services, title: 'Diseños únicos'),
              BeneficioItem(icon: Icons.verified_user, title: 'Garantía 1 año'),
            ],
          ),
        ),

        const Divider(thickness: 1.2, height: 50),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Explora por categoría',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CategoriaItem(icon: Icons.chair, label: 'Sofás'),
                CategoriaItem(icon: Icons.bed, label: 'Camas'),
                CategoriaItem(icon: Icons.table_bar, label: 'Escritorios'),
                CategoriaItem(icon: Icons.chair_alt, label: 'Sillas'),
                CategoriaItem(icon: Icons.kitchen, label: 'Cocinas'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BeneficioItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const BeneficioItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 28, color: Colors.orange),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class CategoriaItem extends StatefulWidget {
  final IconData icon;
  final String label;

  const CategoriaItem({super.key, required this.icon, required this.label});

  @override
  State<CategoriaItem> createState() => _CategoriaItemState();
}

class _CategoriaItemState extends State<CategoriaItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovering ? Colors.orange.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (_hovering)
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 30, color: Colors.orange),
            const SizedBox(height: 8),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
