import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/commandments.dart';
import '../routes/routes.dart';
import '../widgets/app_drawer.dart';
import 'commandment_detail_screen.dart';

class CommandmentsScreen extends StatefulWidget {
  const CommandmentsScreen({super.key});

  @override
  State<CommandmentsScreen> createState() => _CommandmentsScreenState();
}

class _CommandmentsScreenState extends State<CommandmentsScreen> {
  late final Future<CommandmentsCatalog> _catalog = _loadCatalog();

  Future<CommandmentsCatalog> _loadCatalog() async {
    final source = await rootBundle.loadString('assets/data/commandments.json');
    return CommandmentsCatalog.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: AppRoutes.commandments),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78),
        foregroundColor: Colors.white,
        title: const Text(
          'Mandamientos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<CommandmentsCatalog>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se pudieron cargar los mandamientos.'),
            );
          }
          final sections = snapshot.data?.sections ?? [];
          if (sections.isEmpty) {
            return const Center(
              child: Text('No hay mandamientos disponibles.'),
            );
          }
          return ListView.separated(
            itemCount: sections.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final section = sections[index];
              return ListTile(
                leading: const Icon(Icons.menu_book, color: Color(0xFF3A4CB3)),
                title: Text(section.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommandmentDetailScreen(section: section),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
