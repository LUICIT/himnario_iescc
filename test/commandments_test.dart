import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:himnario_iescc/app/commandment_detail_screen.dart';
import 'package:himnario_iescc/model/commandments.dart';
import 'package:himnario_iescc/routes/routes.dart';

import 'widget_test.dart' show appAtRoute;

const asset = 'assets/data/commandments.json';

Future<CommandmentsCatalog> loadCatalog() async => CommandmentsCatalog.fromJson(
  jsonDecode(await rootBundle.loadString(asset)) as Map<String, dynamic>,
);

void expectNoSourcePage(dynamic value) {
  if (value is Map) {
    expect(value.containsKey('source_page'), isFalse);
    value.values.forEach(expectNoSourcePage);
  } else if (value is List) {
    value.forEach(expectNoSourcePage);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Los mandamientos conservan su estructura y no tienen source_page',
    () async {
      final json =
          jsonDecode(await rootBundle.loadString(asset))
              as Map<String, dynamic>;
      expectNoSourcePage(json);
      final catalog = CommandmentsCatalog.fromJson(json);
      expect(catalog.sections.map((s) => s.id), ['father', 'jesus', 'spirit']);
      expect(catalog.sections.map((s) => s.parts.length), [1, 4, 1]);
      final father = catalog.sections[0];
      final jesus = catalog.sections[1];
      final spirit = catalog.sections[2];
      expect(father.parts.single.title, isNull);
      expect(father.parts.single.number, isNull);
      expect(spirit.parts.single.title, isNull);
      expect(spirit.parts.single.number, isNull);
      expect(jesus.parts.map((part) => part.number), [1, 2, 3, 4]);
      expect(jesus.parts.map((part) => part.groups.length), [5, 4, 2, 4]);
      expect(father.parts.single.groups, hasLength(5));
      expect(spirit.parts.single.groups, hasLength(3));

      final ids = <String>{};
      var passages = 0;
      for (final section in catalog.sections) {
        expect(ids.add(section.id), isTrue);
        for (final part in section.parts) {
          expect(ids.add(part.id), isTrue);
          expect(
            part.groups.map((g) => g.number),
            List.generate(part.groups.length, (i) => i + 1),
          );
          for (final group in part.groups) {
            expect(ids.add(group.id), isTrue);
            expect(group.passages, isNotEmpty);
            for (final passage in group.passages) {
              passages++;
              expect(passage.text.trim(), isNotEmpty);
              expect(passage.reference.book.trim(), isNotEmpty);
              expect(passage.reference.chapter, greaterThan(0));
              expect(passage.reference.verses, isNotEmpty);
              expect(passage.reference.verses.every((v) => v > 0), isTrue);
            }
          }
        }
      }
      expect(passages, 66);
    },
  );

  test('Los diez mandamientos tienen su numeración propia', () async {
    final catalog = await loadCatalog();
    final passages = catalog.sections.first.parts.single.groups.expand(
      (g) => g.passages,
    );
    expect(
      passages
          .where((p) => p.commandmentNumber != null)
          .map((p) => p.commandmentNumber),
      List.generate(10, (i) => i + 1),
    );
  });

  test('Las continuaciones quedan en el grupo al que pertenecen', () async {
    final catalog = await loadCatalog();
    final father = catalog.sections[0].parts.single.groups;
    expect(father.last.passages.last.reference.label, 'Malaquías 3:8-10');
    expect(
      father.last.passages.last.text,
      contains('Traed todos los diezmos al alfolí'),
    );
    expect(father.last.passages.last.text, endsWith('hasta que sobreabunde.'));
    final jesus = catalog.sections[1].parts;
    expect(jesus.first.groups.last.passages.last.reference.label, 'Mateo 5:48');
    expect(jesus[2].groups.last.passages.map((p) => p.reference.label), [
      'Mateo 7:6',
      'Mateo 7:7',
      'Mateo 7:12',
      'Mateo 7:13',
      'Mateo 7:15',
      'Mateo 7:21',
      'Mateo 7:24',
      'Marcos 10:9',
      'Marcos 12:17',
    ]);
  });

  test('Una versión de JSON desconocida produce un error de formato', () {
    expect(
      () => CommandmentsCatalog.fromJson({'schema_version': 2, 'sections': []}),
      throwsFormatException,
    );
  });

  test(
    'La referencia corregida del Espíritu Santo es 2 Corintios 6:17',
    () async {
      final catalog = await loadCatalog();
      expect(
        catalog
            .sections[2]
            .parts
            .single
            .groups[1]
            .passages
            .first
            .reference
            .label,
        '2 Corintios 6:17',
      );
    },
  );

  test('Las referencias agrupan versículos consecutivos', () {
    expect(
      const BibleReference(book: 'Éxodo', chapter: 20, verses: [4, 5, 6]).label,
      'Éxodo 20:4-6',
    );
    expect(
      const BibleReference(
        book: 'Mateo',
        chapter: 5,
        verses: [23, 24, 25, 28, 29, 32],
      ).label,
      'Mateo 5:23-25, 28-29, 32',
    );
  });

  testWidgets('El menú abre Mandamientos y permite leer la sección del Padre', (
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
      await tester.tap(find.text('Mandamientos'));
      await tester.pump();
      await rootBundle.loadString(asset);
    });
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Mandamientos'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
    await tester.tap(find.text('Mandamientos de Dios el Padre'));
    await tester.pumpAndSettle();
    expect(find.text('Marcos 12:30'), findsOneWidget);
    expect(find.text('Primera parte'), findsNothing);
    expect(find.byType(CommandmentDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'La lectura de Jesús muestra las partes y permite aumentar la letra',
    (tester) async {
      final catalog = await tester.runAsync(loadCatalog);
      // Comprobar también una pantalla estrecha con letra grande.
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: CommandmentDetailScreen(section: catalog!.sections[1]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Primera parte'), findsOneWidget);
      final reader = find.byType(ListView);
      expect(tester.getSize(reader).width, 320);
      await tester.scrollUntilVisible(
        find.text('Segunda parte'),
        500,
        scrollable: find
            .descendant(of: reader, matching: find.byType(Scrollable))
            .first,
      );
      expect(find.text('Segunda parte'), findsOneWidget);
      await tester.tap(find.byTooltip('Tamaño de letra'));
      await tester.pumpAndSettle();
      tester.widget<Slider>(find.byType(Slider)).onChanged!(28);
      await tester.pump();
      Navigator.of(tester.element(find.byType(Slider))).pop();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Segunda parte'),
        500,
        scrollable: find
            .descendant(of: reader, matching: find.byType(Scrollable))
            .first,
      );
      expect(
        tester.widget<Text>(find.text('Segunda parte')).style!.fontSize,
        32,
      );
      expect(tester.getSize(reader).width, 320);
      expect(tester.widget<ListView>(reader).padding, const EdgeInsets.all(16));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'En monitores el ancho acompaña a la letra y cabe en la ventana',
    (tester) async {
      final catalog = await tester.runAsync(loadCatalog);
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: CommandmentDetailScreen(section: catalog!.sections.first),
        ),
      );
      await tester.pumpAndSettle();
      final reader = find.byType(ListView);
      expect(tester.getSize(reader).width, 800);
      expect(tester.getTopLeft(reader).dx, 400);

      await tester.tap(find.byTooltip('Tamaño de letra'));
      await tester.pumpAndSettle();
      for (final setting in [(20.0, 992.0), (24.0, 1184.0), (28.0, 1376.0)]) {
        tester.widget<Slider>(find.byType(Slider)).onChanged!(setting.$1);
        await tester.pump();
        expect(tester.getSize(reader).width, setting.$2);
        expect(tester.getTopLeft(reader).dx, (1600 - setting.$2) / 2);
      }

      tester.view.physicalSize = const Size(1200, 900);
      await tester.pump();
      expect(tester.getSize(reader).width, 1200);
      expect(tester.getTopLeft(reader).dx, 0);
      tester.widget<Slider>(find.byType(Slider)).onChanged!(16);
      await tester.pump();
      expect(tester.getSize(reader).width, 800);
      expect(tester.getTopLeft(reader).dx, 200);
      Navigator.of(tester.element(find.byType(Slider))).pop();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
