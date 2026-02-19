import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routes/routes.dart';
import '../widgets/app_drawer.dart';
import '../main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (kIsWeb) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: AppRoutes.about),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78),
        // Azul profundo (similar al logo)
        foregroundColor: Colors.white,
        title: const Text(
          'Acerca de',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Acerca de mi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'ISC Luis Rodrigo Aguilar Uribe',
              // ← puedes modificar tu nombre completo aquí
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Soy desarrollador Fullstack con experiencia en el desarrollo de aplicaciones web. '
              'Esta aplicación fue creada con el propósito de aportar una herramienta digital útil para la iglesia, '
              'permitiendo acceder a los himnos de manera práctica, organizada y accesible incluso sin conexión a internet.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              '¿Por qué nació esta aplicación?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'El objetivo principal fue facilitar el acceso a los himnos de la iglesia en cualquier momento, '
              'integrando letras y audios en una sola plataforma. Esta herramienta busca apoyar la adoración, '
              'la enseñanza y el crecimiento espiritual de la congregación.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Conecta conmigo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, size: 28),
                  onPressed: () =>
                      _openUrl('https://www.facebook.com/Luis.R.Aguilar.Uribe'),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, size: 28),
                  onPressed: () => _openUrl('https://wa.me/5219331226527'),
                ),
                IconButton(
                  icon: const Icon(Icons.work, size: 28),
                  onPressed: () => _openUrl(
                    'https://www.linkedin.com/in/isc-luis-rodrigo-aguilar-uribe/',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.public, size: 28),
                  onPressed: () =>
                      _openUrl('https://luicit.github.io/CV-Luis-R-Aguilar/'),
                ),
                IconButton(
                  icon: const Icon(Icons.email, size: 28),
                  onPressed: () => _openEmail('falcon_nike3@hotmail.com'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            /*const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Comentarios y sugerencias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Si deseas enviar comentarios, sugerencias o reportar algún detalle, puedes hacerlo a través del siguiente formulario:',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openUrl('https://luicit.github.io/CV-Luis-R-Aguilar/'),
                icon: const Icon(Icons.feedback),
                label: const Text('Enviar comentario'),
              ),
            ),
            const SizedBox(height: 24),*/
          ],
        ),
      ),
    );
  }
}
