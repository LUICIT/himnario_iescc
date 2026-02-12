import 'hymn_content.dart';

class Hymn {
  final int id;
  final int number;
  final String title;
  final HymnContent content;

  Hymn({
    required this.id,
    required this.number,
    required this.title,
    required this.content,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) {
    final contentRaw = json['content'] as Map<String, dynamic>?;

    return Hymn(
      id: json['id'] as int,
      number: json['number'] as int,
      title: json['title'] as String,
      content: contentRaw != null
          ? HymnContent.fromJson(contentRaw)
          : HymnContent(
              lyrics: (json['lyrics'] as String?) ?? '',
            ), // compatibilidad
    );
  }
}
