class HymnContent {
  final String lyrics;
  final String? audio1;
  final String? audio2;
  final String? audio3;

  HymnContent({required this.lyrics, this.audio1, this.audio2, this.audio3});

  factory HymnContent.fromJson(Map<String, dynamic> json) {
    return HymnContent(
      lyrics: (json['lyrics'] as String?) ?? '',
      audio1: json['audio_1'] as String?,
      audio2: json['audio_2'] as String?,
      audio3: json['audio_3'] as String?,
    );
  }
}
