import 'package:TinCanDart/src/duration.dart';
import 'package:TinCanDart/src/extensions.dart';
import 'package:TinCanDart/src/score.dart';
import 'package:TinCanDart/src/versions.dart';

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

  factory Result.fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson(Version version) {
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
