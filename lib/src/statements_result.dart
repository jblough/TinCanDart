import 'package:TinCanDart/src/statement.dart';

class StatementsResult {
  final List<Statement> statements;
  final String moreUrl;

  StatementsResult({this.statements, this.moreUrl});

  factory StatementsResult.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    List<Statement> list = [];
    json['statements']?.forEach((statement) {
      list.add(Statement.fromJson(statement));
    });

    return StatementsResult(
      statements: list,
      moreUrl: json['more'],
    );
  }
}
