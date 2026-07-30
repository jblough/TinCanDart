class Score {
  final num? scaled;
  final num? raw;
  final num? min;
  final num? max;

  Score({
    this.scaled,
    this.raw,
    this.min,
    this.max,
  });

  static Score? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return Score(
      scaled: json['scaled'] as num?,
      raw: json['raw'] as num?,
      min: json['min'] as num?,
      max: json['max'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scaled': scaled,
      'raw': raw,
      'min': min,
      'max': max,
    };
  }
}
