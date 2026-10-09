class CommandmentsCatalog {
  final List<CommandmentSection> sections;

  const CommandmentsCatalog({required this.sections});

  factory CommandmentsCatalog.fromJson(Map<String, dynamic> json) {
    if (json['schema_version'] != 1) {
      throw const FormatException(
        'Versión del catálogo de mandamientos no compatible.',
      );
    }
    return CommandmentsCatalog(
      sections: (json['sections'] as List<dynamic>)
          .map(
            (item) => CommandmentSection.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class CommandmentSection {
  final String id;
  final String title;
  final List<CommandmentPart> parts;

  const CommandmentSection({
    required this.id,
    required this.title,
    required this.parts,
  });

  factory CommandmentSection.fromJson(Map<String, dynamic> json) {
    return CommandmentSection(
      id: json['id'] as String,
      title: json['title'] as String,
      parts: (json['parts'] as List<dynamic>)
          .map((item) => CommandmentPart.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CommandmentPart {
  final String id;
  final int? number;
  final String? title;
  final List<CommandmentGroup> groups;

  const CommandmentPart({
    required this.id,
    this.number,
    this.title,
    required this.groups,
  });

  factory CommandmentPart.fromJson(Map<String, dynamic> json) {
    return CommandmentPart(
      id: json['id'] as String,
      number: json['number'] as int?,
      title: json['title'] as String?,
      groups: (json['groups'] as List<dynamic>)
          .map(
            (item) => CommandmentGroup.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class CommandmentGroup {
  final String id;
  final int number;
  final String? title;
  final List<CommandmentPassage> passages;

  const CommandmentGroup({
    required this.id,
    required this.number,
    this.title,
    required this.passages,
  });

  factory CommandmentGroup.fromJson(Map<String, dynamic> json) {
    return CommandmentGroup(
      id: json['id'] as String,
      number: json['number'] as int,
      title: json['title'] as String?,
      passages: (json['passages'] as List<dynamic>)
          .map(
            (item) => CommandmentPassage.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class CommandmentPassage {
  final BibleReference reference;
  final String text;
  final int? commandmentNumber;

  const CommandmentPassage({
    required this.reference,
    required this.text,
    this.commandmentNumber,
  });

  factory CommandmentPassage.fromJson(Map<String, dynamic> json) {
    return CommandmentPassage(
      reference: BibleReference.fromJson(
        json['reference'] as Map<String, dynamic>,
      ),
      text: json['text'] as String,
      commandmentNumber: json['commandment_number'] as int?,
    );
  }
}

class BibleReference {
  final String book;
  final int chapter;
  final List<int> verses;

  const BibleReference({
    required this.book,
    required this.chapter,
    required this.verses,
  });

  factory BibleReference.fromJson(Map<String, dynamic> json) {
    return BibleReference(
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verses: (json['verses'] as List<dynamic>).cast<int>(),
    );
  }

  String get label {
    final ranges = <String>[];
    for (var index = 0; index < verses.length; index++) {
      final first = verses[index];
      var last = first;
      while (index + 1 < verses.length && verses[index + 1] == last + 1) {
        last = verses[++index];
      }
      ranges.add(first == last ? '$first' : '$first-$last');
    }
    return '$book $chapter:${ranges.join(', ')}';
  }
}
