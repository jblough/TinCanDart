import 'package:TinCanDart/src/statement_target.dart';
import 'package:TinCanDart/src/versions.dart';

class StatementRef extends StatementTarget {
  final String id; // UUID

  StatementRef({this.id});

  factory StatementRef.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return StatementRef(
      id: json['id'],
    );
  }

  @override
  Map<String, dynamic> toJson(Version version) {
    return {
      'objectType': 'StatementRef',
      'id': id,
    };
  }
}
