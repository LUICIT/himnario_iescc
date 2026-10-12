import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/slogans_thoughts.dart';
import '../routes/routes.dart';
import '../widgets/app_drawer.dart';
import 'thought_detail_screen.dart';

class SlogansThoughtsScreen extends StatefulWidget {
  const SlogansThoughtsScreen({super.key});

  @override
  State<SlogansThoughtsScreen> createState() => _SlogansThoughtsScreenState();
}

class _SlogansThoughtsScreenState extends State<SlogansThoughtsScreen> {
  late final Future<SlogansThoughtsCatalog> _catalog = _loadCatalog();

  Future<SlogansThoughtsCatalog> _loadCatalog() async {
    final source = await rootBundle.loadString(
      'assets/data/slogans_thoughts.json',
    );
    return SlogansThoughtsCatalog.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: AppRoutes.slogansThoughts),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78),
        foregroundColor: Colors.white,
        title: const Text(
          'Lemas y Pensamientos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<SlogansThoughtsCatalog>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se pudieron cargar los lemas y pensamientos.'),
            );
          }
          final catalog = snapshot.data;
          if (catalog == null ||
              (catalog.introductoryTexts.isEmpty &&
                  catalog.authorGroups.isEmpty)) {
            return const Center(
              child: Text('No hay lemas ni pensamientos disponibles.'),
            );
          }
          return ListView(
            children: [
              for (final entry in catalog.introductoryTexts) ...[
                ListTile(
                  key: ValueKey('intro:${entry.id}'),
                  leading: const Icon(
                    Icons.menu_book,
                    color: Color(0xFF3A4CB3),
                  ),
                  title: Text(entry.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ThoughtDetailScreen(entry: entry),
                    ),
                  ),
                ),
                const Divider(height: 1),
              ],
              if (catalog.authorGroups.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Lemas anuales',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              for (final group in catalog.authorGroups) ...[
                ListTile(
                  key: ValueKey('author:${group.id}'),
                  leading: Icon(
                    group.type == 'council' ? Icons.groups : Icons.person,
                    color: const Color(0xFF3A4CB3),
                  ),
                  title: Text(group.title),
                  subtitle: Text('${group.startYear}–${group.endYear}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _AnnualMottosScreen(group: group),
                    ),
                  ),
                ),
                const Divider(height: 1),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AnnualMottosScreen extends StatelessWidget {
  final ThoughtAuthorGroup group;

  const _AnnualMottosScreen({required this.group});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF1E2A78),
      foregroundColor: Colors.white,
      title: Text(group.title),
    ),
    body: ListView.separated(
      itemCount: group.entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = group.entries[index];
        return ListTile(
          key: ValueKey(entry.id),
          title: Text(entry.title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ThoughtDetailScreen(entry: entry, author: group.title),
            ),
          ),
        );
      },
    ),
  );
}
