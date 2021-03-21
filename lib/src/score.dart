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
      scaled: json['scaled'],
      raw: json['raw'],
      min: json['min'],
      max: json['max'],
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
