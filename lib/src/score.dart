class Score {
  final double scaled;
  final double raw;
  final double min;
  final double max;

  Score({
    this.scaled,
    this.raw,
    this.min,
    this.max,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
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
