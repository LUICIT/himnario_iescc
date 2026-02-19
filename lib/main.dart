import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:himnario_iescc/routes/routes.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app/about_screen.dart';
import 'app/donate_screen.dart';
import 'app/home_screen.dart';
import 'app/hymns_screen.dart';
import 'app/not_found_screen.dart';
import 'app/splash_screen.dart';
import 'app/under_development_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.iescc.himnario.channel.audio',
    androidNotificationChannelName: 'Reproducción de himnos',
    androidNotificationOngoing: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Himnario',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.hymns: (_) => const HymnScreen(),
        AppRoutes.hymnsSpecials: (_) => const UnderDevelopmentScreen(
          title: 'Himnos Especiales',
          message:
              'Esta sección está en desarrollo. Próximamente estará disponible.',
        ),
        AppRoutes.choruses: (_) => const UnderDevelopmentScreen(
          title: 'Coros',
          message:
              'Esta sección está en desarrollo. Próximamente estará disponible.',
        ),
        AppRoutes.commandments: (_) => const UnderDevelopmentScreen(
          title: 'Mandamientos',
          message:
              'Esta sección está en desarrollo. Próximamente estará disponible.',
        ),
        AppRoutes.slogansThoughts: (_) => const UnderDevelopmentScreen(
          title: 'Lemas y Pensamientos',
          message:
              'Esta sección está en desarrollo. Próximamente estará disponible.',
        ),
        AppRoutes.donation: (_) => const DonateScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
      },
      onUnknownRoute: (settings) {
        final name = settings.name;

        // Si la ruta existe en el menú (menu.json) pero aún no está implementada,
        // mostramos "En desarrollo" en lugar de un 404.
        if (AppRoutes.menuRoutes.contains(name)) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const UnderDevelopmentScreen(
              title: 'En desarrollo',
              message:
                  'Esta sección está en desarrollo. Próximamente estará disponible.',
            ),
          );
        }

        // Si la ruta NO está en el menú, entonces es una ruta inválida.
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NotFoundScreen(requestedRoute: name),
        );
      },
    );
  }
}
