import 'package:TinCanDart/src/language_map.dart';
import 'package:TinCanDart/src/parsing_utils.dart';

class Verb {
  final Uri id;
  final LanguageMap display;

  Verb({this.id, this.display});

  factory Verb.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Verb(
      id: ParsingUtils.toUri(json['id']),
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
