import 'package:flutter/material.dart';

import '../classes/paypal_donate.dart';
import '../routes/routes.dart';
import '../widgets/app_drawer.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  static const String _routeName = '/donate';

  Future<void> _donate() async {
    try {
      await PaypalDonate.openDonateLink();

      // Después de abrir PayPal, regresa al Home para que el usuario continúe navegando.
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo abrir PayPal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: AppRoutes.donation),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78),
        // Azul profundo (similar al logo)
        foregroundColor: Colors.white,
        title: const Text(
          'Donativo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu donativo es totalmente voluntario y representa un impulso directo para continuar mejorando este proyecto.\n\n'
              'Cada contribución ayuda directamente a que el proyecto pueda seguir creciendo, mejorando su estabilidad, seguridad y experiencia de usuario.\n\n'
              'Gracias por apoyar el trabajo independiente y ayudar a que esta herramienta siga creciendo.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _donate,
                child: const Text('Ir a PayPal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
