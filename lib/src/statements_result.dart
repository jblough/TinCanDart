import './statement.dart';

class StatementsResult {
  final List<Statement>? statements;
  final String? moreUrl;

  StatementsResult({this.statements, this.moreUrl});

  static StatementsResult? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    final list = <Statement>[];
    (json['statements'] as List<dynamic>?)?.forEach((dynamic statement) {
      list.add(Statement.fromJson(statement as Map<String, dynamic>?)!);
    });

    return StatementsResult(
      statements: list,
      moreUrl: json['more'] as String?,
    );
  }
}
