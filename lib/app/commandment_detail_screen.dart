import 'package:flutter/material.dart';

import '../model/commandments.dart';

class CommandmentDetailScreen extends StatefulWidget {
  final CommandmentSection section;

  const CommandmentDetailScreen({super.key, required this.section});

  @override
  State<CommandmentDetailScreen> createState() =>
      _CommandmentDetailScreenState();
}

class _CommandmentDetailScreenState extends State<CommandmentDetailScreen> {
  static const _baseFontSize = 16.0;
  static const _baseReadingWidth = 800.0;
  static const _readingPadding = 16.0;

  double _fontSize = _baseFontSize;

  void _openFontSizeSheet() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tamaño de letra',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Slider(
                min: 12,
                max: 28,
                divisions: 16,
                value: _fontSize,
                label: _fontSize.round().toString(),
                onChanged: (value) {
                  setState(() => _fontSize = value);
                  setSheetState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    final effectiveFontSize = MediaQuery.textScalerOf(context).scale(_fontSize);
    // Escalar el espacio de texto, conservando los márgenes interiores.
    final readingWidth =
        (_baseReadingWidth - 2 * _readingPadding) *
            effectiveFontSize /
            _baseFontSize +
        2 * _readingPadding;
    final entries = <Widget>[];
    for (final part in section.parts) {
      if (part.title != null) {
        entries.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              part.title!,
              style: TextStyle(
                fontSize: _fontSize + 4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }
      for (final group in part.groups) {
        entries.add(_buildGroup(group));
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78),
        foregroundColor: Colors.white,
        title: Text(section.title),
        actions: [
          IconButton(
            tooltip: 'Tamaño de letra',
            onPressed: _openFontSizeSheet,
            icon: const Icon(Icons.text_fields),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth <= _baseReadingWidth
                  ? constraints.maxWidth
                  : readingWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(_readingPadding),
              children: entries,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroup(CommandmentGroup group) {
    return Padding(
      key: ValueKey(group.id),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '— ${group.number} —',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600),
          ),
          if (group.title != null) ...[
            const SizedBox(height: 12),
            Text(
              group.title!,
              style: TextStyle(
                fontSize: _fontSize + 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          for (final passage in group.passages) ...[
            const SizedBox(height: 12),
            Text(
              passage.reference.label,
              style: TextStyle(
                fontSize: _fontSize,
                color: const Color(0xFF1E2A78),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              passage.commandmentNumber == null
                  ? passage.text
                  : '${passage.commandmentNumber}. ${passage.text}',
              style: TextStyle(fontSize: _fontSize, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}
