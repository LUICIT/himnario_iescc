import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../classes/menu_item.dart';
import '../classes/paypal_donate.dart';
import '../routes/routes.dart';

class AppDrawer extends StatefulWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late Future<List<MenuItem>> _menuFuture;

  @override
  void initState() {
    super.initState();
    _menuFuture = _loadMenu();
  }

  Future<List<MenuItem>> _loadMenu() async {
    try {
      const path = 'assets/data/menu.json';
      final jsonString = await rootBundle.loadString(path);

      final dynamic decoded = json.decode(jsonString);

      final List<dynamic> items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map && decoded['items'] is List) {
        items = decoded['items'] as List<dynamic>;
      } else {
        throw FormatException(
          'Formato de menú inválido. Se esperaba una lista o {"items": [...]}.',
        );
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(MenuItem.fromJson)
          .toList();
    } on FlutterError catch (e, st) {
      // FlutterError suele indicar que el asset NO está en el bundle (pubspec.yaml / ruta / clean build).
      if (kDebugMode) {
        debugPrint('No se pudo cargar el asset del menú (FlutterError).');
        debugPrint(e.toString());
        debugPrint(st.toString());
      }
      return const [];
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('Error al cargar/parsear menú: $e');
        debugPrint(st.toString());
      }
      return const [];
    }
  }

  void _go(MenuItem item) {
    Navigator.pop(context); // close drawer

    if (item.route == widget.currentRoute) return;

    Navigator.pushNamedAndRemoveUntil(context, item.route, (route) => false);
  }

  Future<void> _donate() async {
    try {
      await PaypalDonate.openDonateLink();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo abrir PayPal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Image.asset(
                'assets/images/logo.png',
                height: 32,
                fit: BoxFit.contain,
              ),
              title: const Text(
                'Menú Principal',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onTap: () {
                Navigator.pop(context); // close drawer
                if (widget.currentRoute != AppRoutes.home) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                }
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<MenuItem>>(
                future: _menuFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data ?? const <MenuItem>[];
                  if (items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No hay opciones de menú configuradas.'),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final selected = item.route == widget.currentRoute;

                      return ListTile(
                        leading: Icon(item.iconData),
                        title: Text(item.title),
                        selected: selected,
                        onTap: () => _go(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
