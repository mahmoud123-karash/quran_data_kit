/// Represents a Hizb quarter (Rub el-Hizb) location in the Holy Quran.
class Quarter {
  /// Surah number where the quarter begins (1–114).
  final int surah;

  /// Ayah number where the quarter begins.
  final int ayah;

  const Quarter({required this.surah, required this.ayah});

  factory Quarter.fromJson(Map<String, dynamic> json) =>
      Quarter(surah: json['surah'] as int, ayah: json['ayah'] as int);

  Map<String, dynamic> toJson() => {'surah': surah, 'ayah': ayah};
}
