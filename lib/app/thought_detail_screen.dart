import 'package:flutter/material.dart';

import '../model/slogans_thoughts.dart';

class ThoughtDetailScreen extends StatefulWidget {
  final ThoughtEntry entry;
  final String? author;

  const ThoughtDetailScreen({super.key, required this.entry, this.author});

  @override
  State<ThoughtDetailScreen> createState() => _ThoughtDetailScreenState();
}

class _ThoughtDetailScreenState extends State<ThoughtDetailScreen> {
  double _fontSize = 16;

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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF1E2A78),
      foregroundColor: Colors.white,
      title: Text(widget.entry.title),
      actions: [
        IconButton(
          tooltip: 'Tamaño de letra',
          onPressed: _openFontSizeSheet,
          icon: const Icon(Icons.text_fields),
        ),
      ],
    ),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.author != null) ...[
              Text(
                widget.author!,
                style: const TextStyle(
                  color: Color(0xFF1E2A78),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
            ],
            SelectableText(
              widget.entry.text,
              style: TextStyle(fontSize: _fontSize, height: 1.5),
            ),
          ],
        ),
      ),
    ),
  );
}
