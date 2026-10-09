import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:himnario_iescc/app/hymns_screen.dart';
import 'package:himnario_iescc/main.dart';
import 'package:himnario_iescc/model/hym.dart';
import 'package:himnario_iescc/routes/routes.dart';

const catalogs = {
  'assets/data/hymns.json': 295,
  'assets/data/hymns_special.json': 154,
  'assets/data/choruses.json': 86,
  'assets/data/hymns_worship.json': 103,
};

Widget appAtRoute(String route) => Builder(
  builder: (context) {
    final app = const MyApp().build(context) as MaterialApp;
    return MaterialApp(
      routes: app.routes!,
      initialRoute: route,
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute(builder: app.routes![route]!),
      ],
    );
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final asset in [...catalogs.keys, 'assets/data/menu.json']) {
      await rootBundle.loadString(asset);
    }
  });
  for (final catalog in catalogs.entries) {
    test('${catalog.key}: formato, numeración y contenido completos', () async {
      final entries =
          (jsonDecode(await rootBundle.loadString(catalog.key)) as List)
              .cast<Map<String, dynamic>>();
      expect(entries, hasLength(catalog.value));
      final hymns = entries.map(Hymn.fromJson).toList();
      expect(hymns.map((h) => h.id).toSet(), hasLength(catalog.value));
      final start = catalog.key.endsWith('/hymns.json') ? 0 : 1;
      expect(
        hymns.map((h) => h.number),
        List.generate(catalog.value, (i) => i + start),
      );
      for (final entry in entries) {
        expect(entry.keys.toSet(), {'id', 'number', 'title', 'content'});
        final content = entry['content'] as Map<String, dynamic>;
        expect(content.keys.toSet(), {
          'lyrics',
          'audio_1',
          'audio_2',
          'audio_3',
        });
        expect((entry['title'] as String).trim(), isNotEmpty);
        expect((content['lyrics'] as String).trim(), isNotEmpty);
        for (final key in ['audio_1', 'audio_2', 'audio_3']) {
          expect(content[key], anyOf(isNull, isA<String>()));
        }
      }
    });
  }

  test(
    'La ampliación conserva los audios congregacionales existentes',
    () async {
      final entries =
          jsonDecode(await rootBundle.loadString('assets/data/hymns.json'))
              as List;
      final doxology = Hymn.fromJson(entries.first as Map<String, dynamic>);
      expect(doxology.number, 0);
      expect(doxology.content.audio2, 'assets/audio/new/000C.m4a');
      expect(entries.last['title'], 'SALIDA DEL SOL');
    },
  );

  const sections = {
    AppRoutes.hymns: ('Himnos Congregacionales', 'DOXOLOGÍA', 295),
    AppRoutes.hymnsSpecials: ('Himnos Especiales', 'A LA CASA DE JAIRO', 154),
    AppRoutes.choruses: ('Coros', 'ADORACIÓN', 86),
    AppRoutes.hymnsWorship: ('Himnos de Adoración', 'A CRISTO CORONAD', 103),
  };

  for (final section in sections.entries) {
    testWidgets('La ruta ${section.key} carga su catálogo', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(appAtRoute(section.key));
        final screen = tester.widget<HymnScreen>(find.byType(HymnScreen));
        await rootBundle.loadString(screen.assetPath);
        await rootBundle.loadString('assets/data/menu.json');
      });
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, section.value.$1), findsOneWidget);
      expect(find.widgetWithText(ListTile, section.value.$2), findsOneWidget);
      final list = tester.widget<ListView>(find.byType(ListView).first);
      expect(list.semanticChildCount, section.value.$3);
      final screen = tester.widget<HymnScreen>(find.byType(HymnScreen));
      expect(screen.currentRoute, section.key);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('El menú abre la nueva sección de adoración', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(appAtRoute(AppRoutes.hymns));
      await rootBundle.loadString('assets/data/hymns.json');
      await rootBundle.loadString('assets/data/menu.json');
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pump();
      await rootBundle.loadString('assets/data/menu.json');
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Himnos de Adoración'));
      await tester.pump();
      await rootBundle.loadString('assets/data/hymns_worship.json');
    });
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Himnos de Adoración'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'A CRISTO CORONAD'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
