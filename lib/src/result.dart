import './duration.dart';
import './extensions.dart';
import './score.dart';
import './versions.dart';

class Result {
  final Score score;
  final bool success;
  final bool completion;
  final TinCanDuration duration;
  final String response;
  final Extensions extensions;

  Result({
    this.score,
    this.success,
    this.completion,
    this.duration,
    this.response,
    this.extensions,
  });

  Result copyWith({
    Score score,
    bool success,
    bool completion,
    TinCanDuration duration,
    String response,
    Extensions extensions,
  }) {
    return Result(
      score: score ?? this.score,
      success: success ?? this.success,
      completion: completion ?? this.completion,
      duration: duration ?? this.duration,
      response: response ?? this.response,
      extensions: extensions ?? this.extensions,
    );
  }

  static Result fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Result(
      score: Score.fromJson(json['score']),
      success: json['success'],
      completion: json['completion'],
      duration: TinCanDuration.fromString(json['duration']),
      response: json['response'],
      extensions: Extensions.fromJson(json['extensions']),
    );
  }

  Map<String, dynamic> toJson([Version version]) {
    version ??= TinCanVersion.latest();

    final json = {
      'score': score?.toJson(),
      'success': success,
      'completion': completion,
      'duration': duration?.toString(), // ???
      'response': response,
      'extensions': extensions?.toJson(),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
