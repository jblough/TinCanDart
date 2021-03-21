import './statement_target.dart';
import './versions.dart';

class StatementRef extends StatementTarget {
  final String id; // UUID

  /// https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#statement-references
  StatementRef({this.id});

  static StatementRef fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return StatementRef(
      id: json['id'],
    );
  }

  @override
  Map<String, dynamic> toJson([Version version]) {
    return {
      'objectType': 'StatementRef',
      'id': id,
    };
  }
}
