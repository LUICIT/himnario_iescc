import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routes/routes.dart';
import '../widgets/app_drawer.dart';
import '../main.dart'; // para AppRoutes

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (kIsWeb) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: AppRoutes.home),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Image.asset(
                'assets/images/logo.png',
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        title: const Text(
          'Himnario IESCC',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Bienvenido(a)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Que este himnario te acompañe en tu tiempo de oración y adoración.\n'
              'Permite que cada himno fortalezca tu fe, consuele tu corazón y eleve tu voz en alabanza al Señor en todo momento.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            // Versículo de edificación (RVR1960)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.black.withOpacity(0.08)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 10),
                    Text(
                      '"La palabra de Cristo habite en vosotros en abundancia en toda sabiduría, enseñándoos y exhortándoos los unos á los otros con salmos é himnos y canciones espirituales, con gracia cantando en vuestros corazones al Señor."',
                      style: TextStyle(fontSize: 15, height: 1.45),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Colosenses 3:16 (RVR09)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.donation),
              icon: const Icon(Icons.volunteer_activism),
              label: const Text('Apoyar con un donativo'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Nota: Para abrir el menú lateral puedes darle clic al logo de la iglesia '
              'o deslizar desde fuera de la pantalla de izquierda a derecha.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openUrl('https://forms.office.com/r/aNcUz4ijKS'),
                icon: const Icon(Icons.feedback),
                label: const Text('Enviar comentario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
