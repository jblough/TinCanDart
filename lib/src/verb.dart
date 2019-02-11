import 'package:TinCanDart/src/conversion_utils.dart';
import 'package:TinCanDart/src/language_map.dart';

class Verb {
  final Uri id;
  final LanguageMap display;

  Verb({this.id, this.display});

  factory Verb.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Verb(
      id: ConversionUtils.toUri(json['id']),
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
