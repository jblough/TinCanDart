import './language_map.dart';
import './validated_uri.dart';

class Verb {
  final ValidatedUri id;
  final LanguageMap display;

  Verb({
    dynamic id,
    this.display,
  }) : this.id = ValidatedUri.fromString(id?.toString());

  factory Verb.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Verb(
      id: json['id'],
      display: LanguageMap.fromJson(json['display']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString(),
      'display': display?.toJson(),
    };
  }
}
