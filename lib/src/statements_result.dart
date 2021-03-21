import './statement.dart';

class StatementsResult {
  final List<Statement?>? statements;
  final String? moreUrl;

  StatementsResult({this.statements, this.moreUrl});

  static StatementsResult? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    final list = <Statement?>[];
    json['statements']?.forEach((statement) {
      list.add(Statement.fromJson(statement));
    });

    return StatementsResult(
      statements: list,
      moreUrl: json['more'],
    );
  }
}
