import 'package:TinCanDart/src/language_map.dart';
import 'package:TinCanDart/src/validated_uri.dart';

class Verb {
  final ValidatedUri id;
  final LanguageMap display;

  Verb({this.id, this.display});

  factory Verb.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Verb(
      id: ValidatedUri.fromString(json['id']),
      display: LanguageMap.fromJson(json['display']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString(),
      'display': display.toJson(),
    };
  }
}
