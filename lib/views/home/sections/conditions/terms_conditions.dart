import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TÉRMINOS Y CONDICIONES DE CARPINTERÍA CHAVARRÍA',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Última actualización: 24 de mayo de 2025\n',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              Text(
                '''
1. INTRODUCCIÓN
Bienvenido/a a Carpintería Chavarría. Estos Términos y Condiciones regulan el acceso y uso de nuestros servicios, productos y plataforma. Al realizar un pedido o usar nuestros servicios, aceptas estos términos.

2. SOBRE NOSOTROS
Carpintería Chavarría fabrica muebles personalizados, realiza restauración de madera y ofrece servicios de carpintería con más de 15 años de experiencia.

3. SERVICIOS OFRECIDOS
- Muebles personalizados
- Restauración
- Venta de productos terminados
- Instalación y entregas

4. PEDIDOS Y CONTRATACIÓN
Todo pedido requiere el 50% de adelanto. Se entrega el saldo restante al finalizar. Los pedidos personalizados no pueden cancelarse una vez iniciada la producción.

5. PLAZOS DE ENTREGA
Los plazos se informan al confirmar el pedido. Puede haber demoras externas como materiales o clima.

6. POLÍTICA DE CANCELACIÓN Y DEVOLUCIÓN
- No se cancelan pedidos personalizados.
- Devoluciones: solo productos estándar, dentro de los 5 días.
- Productos dañados: se reparan o reemplazan sin costo.

7. GARANTÍA
6 meses por defectos de fabricación, no incluye mal uso o daños por clima.

8. PROPIEDAD INTELECTUAL
Todos los diseños, logotipos y textos pertenecen a Carpintería Chavarría.

9. PROTECCIÓN DE DATOS
Tus datos se usan solo para gestionar pedidos, cumpliendo las leyes vigentes.

10. LIMITACIÓN DE RESPONSABILIDAD
No nos responsabilizamos por daños indirectos. La responsabilidad máxima es el valor del producto.

11. JURISDICCIÓN
Este acuerdo se rige por las leyes locales. Toda controversia se resolverá en tribunales del domicilio de Carpintería Chavarría.

CONTACTO:
Email: contacto@carpinteriachavarria.com
WhatsApp: +503 70707070
Dirección: San Miguel Centro.
''',
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
