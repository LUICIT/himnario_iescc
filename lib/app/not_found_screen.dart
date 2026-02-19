import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../routes/routes.dart';

class NotFoundScreen extends StatefulWidget {
  final String? requestedRoute;

  const NotFoundScreen({super.key, this.requestedRoute});

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen> {
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();

    // En Web: si la ruta no existe (y no está en el menú), redirigir al inicio.
    if (kIsWeb) {
      _redirecting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.requestedRoute ?? '(desconocida)';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78),
        foregroundColor: Colors.white,
        title: const Text('Pantalla no encontrada'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 12),
              Text(
                _redirecting
                    ? 'Ruta no disponible. Redirigiendo al inicio…'
                    : 'Ruta no disponible.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Ruta solicitada: $route',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              if (!_redirecting)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Volver al inicio'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
