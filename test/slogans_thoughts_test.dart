import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:himnario_iescc/app/thought_detail_screen.dart';
import 'package:himnario_iescc/model/slogans_thoughts.dart';
import 'package:himnario_iescc/routes/routes.dart';

import 'widget_test.dart' show appAtRoute;

const asset = 'assets/data/slogans_thoughts.json';

Future<SlogansThoughtsCatalog> loadCatalog() async =>
    SlogansThoughtsCatalog.fromJson(
      jsonDecode(await rootBundle.loadString(asset)) as Map<String, dynamic>,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Los IDs empiezan en 1 y son consecutivos en cada lista', () async {
    final catalog = await loadCatalog();
    expect(catalog.introductoryTexts.map((e) => e.id), [1, 2, 3]);
    expect(
      catalog.authorGroups.map((g) => g.id),
      List.generate(9, (i) => i + 1),
    );
    for (final group in catalog.authorGroups) {
      expect(
        group.entries.map((e) => e.id),
        List.generate(group.entries.length, (i) => i + 1),
      );
    }
  });

  test(
    'Los 86 años están completos y pertenecen a los grupos confirmados',
    () async {
      final catalog = await loadCatalog();
      const expected = [
        ('Ap. Daddy John', 1938, 1953),
        ('Ap. Miguel Ángel Hernández', 1954, 1961),
        ('Ap. Arturo Rangel', 1962, 1966),
        ('Junta de Arzobispos', 1967, 1988),
        ('Ap. Florentino Almeida', 1989, 2000),
        ('Ap. Luis Cruz', 2001, 2002),
        ('Ap. Joel Mondejar', 2003, 2004),
        ('Ap. Cecilio García', 2005, 2009),
        ('Ap. Miguel Rodríguez', 2010, 2023),
      ];
      expect(catalog.authorGroups, hasLength(expected.length));
      for (var index = 0; index < expected.length; index++) {
        final group = catalog.authorGroups[index];
        final (title, start, end) = expected[index];
        expect(group.title, title);
        expect(group.startYear, start);
        expect(group.endYear, end);
        expect(group.type, index == 3 ? 'council' : 'apostle');
        expect(
          group.entries.map((e) => e.year),
          List.generate(end - start + 1, (i) => start + i),
        );
      }
      final entries = catalog.authorGroups.expand((g) => g.entries).toList();
      expect(entries, hasLength(86));
      expect(entries.map((e) => e.year), List.generate(86, (i) => 1938 + i));
      expect(entries.where((e) => e.year == 1848 || e.year == 1871), isEmpty);
      expect(catalog.authorGroups.last.entries.last.year, 2023);
    },
  );

  test(
    'Los títulos anuales tienen el año primero y los textos no están vacíos',
    () async {
      final catalog = await loadCatalog();
      const subtitles = {
        1943: '¡Fíjese en la luz roja!',
        1947: 'Lema doble',
        1956: 'Triple lema',
        1998: 'Lema doble',
      };
      for (final entry in [
        ...catalog.introductoryTexts,
        ...catalog.authorGroups.expand((g) => g.entries),
      ]) {
        expect(entry.text.trim(), isNotEmpty);
        if (entry.year != null) {
          final subtitle = subtitles[entry.year];
          expect(
            entry.title,
            '${entry.year}${subtitle == null ? '' : ' - $subtitle'}',
          );
        }
      }
    },
  );

  test(
    'Los textos iniciales van en el orden acordado y se unen los párrafos',
    () async {
      final catalog = await loadCatalog();
      expect(catalog.introductoryTexts.map((e) => e.title), [
        'Nuestro esfuerzo',
        'Grito de batalla',
        'Lema adicional',
      ]);
      expect(
        catalog.introductoryTexts.first.text,
        endsWith('Cristo Jesús: nuestro todo en todo.'),
      );
      final entries = catalog.authorGroups.expand((g) => g.entries);
      expect(
        entries.singleWhere((e) => e.year == 1947).text.split('\n\n'),
        hasLength(2),
      );
      expect(
        entries.singleWhere((e) => e.year == 1956).text.split('\n\n'),
        hasLength(3),
      );
      final double1998 = entries.singleWhere((e) => e.year == 1998).text;
      expect(double1998.split('\n\n'), hasLength(2));
      expect(
        double1998,
        contains('Recuerda: Hay tanto mal en los mejores de nosotros'),
      );
    },
  );

  test('El JSON no contiene partes ni páginas de referencia', () async {
    final source = jsonDecode(await rootBundle.loadString(asset));
    void check(dynamic node) {
      if (node is Map) {
        expect(node.containsKey('parts'), isFalse);
        expect(node.containsKey('source_page'), isFalse);
        if (node.containsKey('id')) expect(node['id'], isA<int>());
        node.values.forEach(check);
      } else if (node is List) {
        node.forEach(check);
      }
    }

    check(source);
  });

  test('Se rechazan versiones de formato desconocidas', () {
    expect(
      () => SlogansThoughtsCatalog.fromJson({'schema_version': 2}),
      throwsFormatException,
    );
  });

  testWidgets('El menú abre el índice y Nuestro esfuerzo se puede leer', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(appAtRoute(AppRoutes.hymns));
      await rootBundle.loadString('assets/data/hymns.json');
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pump();
      await rootBundle.loadString('assets/data/menu.json');
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text('Lemas y Pensamientos'));
      await tester.pump();
      await rootBundle.loadString(asset);
    });
    await tester.pumpAndSettle();
    final visible = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect((visible[0].title as Text).data, 'Nuestro esfuerzo');
    expect((visible[1].title as Text).data, 'Grito de batalla');
    expect((visible[2].title as Text).data, 'Lema adicional');
    expect(find.text('Lemas anuales'), findsOneWidget);
    await tester.tap(find.text('Nuestro esfuerzo'));
    await tester.pumpAndSettle();
    expect(find.byType(ThoughtDetailScreen), findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      contains('Cristo Jesús: nuestro todo en todo.'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cada apóstol abre sus años y el lema doble se lee completo', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(appAtRoute(AppRoutes.slogansThoughts));
      await rootBundle.loadString(asset);
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ap. Daddy John'));
    await tester.pumpAndSettle();
    final list = find.byType(ListView);
    expect(tester.widget<ListView>(list).semanticChildCount, 16);
    await tester.scrollUntilVisible(
      find.text('1947 - Lema doble'),
      300,
      scrollable: find
          .descendant(of: list, matching: find.byType(Scrollable))
          .first,
    );
    await tester.tap(find.text('1947 - Lema doble'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '1947 - Lema doble'), findsOneWidget);
    expect(find.text('Ap. Daddy John'), findsOneWidget);
    final text = tester
        .widget<SelectableText>(find.byType(SelectableText))
        .data!;
    expect(text, contains('¡Ganar discípulos para Cristo!'));
    expect(text, contains('Recibir el Espíritu Santo'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'En móvil la lectura conserva márgenes y permite cambiar la letra',
    (tester) async {
      final catalog = await tester.runAsync(loadCatalog);
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: ThoughtDetailScreen(entry: catalog!.introductoryTexts.first),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Tamaño de letra'));
      await tester.pumpAndSettle();
      tester.widget<Slider>(find.byType(Slider)).onChanged!(28);
      await tester.pump();
      Navigator.of(tester.element(find.byType(Slider))).pop();
      await tester.pumpAndSettle();
      final reader = find.byType(ListView);
      expect(tester.getSize(reader).width, 320);
      expect(tester.widget<ListView>(reader).padding, const EdgeInsets.all(16));
      expect(
        tester
            .widget<SelectableText>(find.byType(SelectableText))
            .style!
            .fontSize,
        28,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
