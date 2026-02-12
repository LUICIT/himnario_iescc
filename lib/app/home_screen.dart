import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../model/hym.dart';
import 'hymn_detail_screen.dart';

/// Home screen (list of content)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Hymn>> _hymnsFuture;

  @override
  void initState() {
    super.initState();
    _hymnsFuture = _loadHymns();
  }

  Future<List<Hymn>> _loadHymns() async {
    final jsonString = await rootBundle.loadString('assets/data/hymns.json');
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) => Hymn.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78), // Azul profundo (similar al logo)
        foregroundColor: Colors.white,
        // Logo a la izquierda (en Home no hay flecha de regreso)
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset(
            'assets/images/logo.png',
            height: 28,
            fit: BoxFit.contain,
          ),
        ),
        title: const Text(
          'Himnario IESCC',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Hymn>>(
        future: _hymnsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar himnos: ${snapshot.error}'),
            );
          }

          final hymns = snapshot.data ?? [];

          if (hymns.isEmpty) {
            return const Center(child: Text('No hay himnos disponibles'));
          }

          return ListView.separated(
            itemCount: hymns.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final hymn = hymns[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF3A4CB3), // Azul más claro que el AppBar
                  child: Text(
                    hymn.number.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(hymn.title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HymnDetailScreen(hymn: hymn),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
