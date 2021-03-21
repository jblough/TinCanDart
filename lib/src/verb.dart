import './validated_uri.dart';

class Verb {
  final ValidatedUri id;
  final Map<String, dynamic> display;

  /// Examples: https://registry.tincanapi.com/#home/verbs
  Verb({
    dynamic id,
    this.display,
  }) : this.id = ValidatedUri.fromString(id?.toString());

  static Verb fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Verb(
      id: json['id'],
      display: json['display'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString(),
      'display': display,
    };
  }
}
