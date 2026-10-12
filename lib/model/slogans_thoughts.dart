class SlogansThoughtsCatalog {
  final List<ThoughtEntry> introductoryTexts;
  final List<ThoughtAuthorGroup> authorGroups;

  const SlogansThoughtsCatalog({
    required this.introductoryTexts,
    required this.authorGroups,
  });

  factory SlogansThoughtsCatalog.fromJson(Map<String, dynamic> json) {
    if (json['schema_version'] != 1) {
      throw const FormatException(
        'Versión del catálogo de lemas y pensamientos no compatible.',
      );
    }
    return SlogansThoughtsCatalog(
      introductoryTexts: (json['introductory_texts'] as List<dynamic>)
          .map((entry) => ThoughtEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
      authorGroups: (json['author_groups'] as List<dynamic>)
          .map(
            (group) =>
                ThoughtAuthorGroup.fromJson(group as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ThoughtEntry {
  final int id;
  final int? year;
  final String title;
  final String text;

  const ThoughtEntry({
    required this.id,
    this.year,
    required this.title,
    required this.text,
  });

  factory ThoughtEntry.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as Map<String, dynamic>;
    return ThoughtEntry(
      id: json['id'] as int,
      year: json['year'] as int?,
      title: json['title'] as String,
      text: content['text'] as String,
    );
  }
}

class ThoughtAuthorGroup {
  final int id;
  final String type;
  final String title;
  final int startYear;
  final int endYear;
  final List<ThoughtEntry> entries;

  const ThoughtAuthorGroup({
    required this.id,
    required this.type,
    required this.title,
    required this.startYear,
    required this.endYear,
    required this.entries,
  });

  factory ThoughtAuthorGroup.fromJson(Map<String, dynamic> json) {
    return ThoughtAuthorGroup(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      startYear: json['start_year'] as int,
      endYear: json['end_year'] as int,
      entries: (json['entries'] as List<dynamic>)
          .map((entry) => ThoughtEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}
