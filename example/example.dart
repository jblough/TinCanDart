import 'package:tincan/tincan.dart';

main() async {
  final lrs = RemoteLRS(
    endpoint: '',
    username: '',
    password: '',
  );

  final statements = await lrs.queryStatements(StatementsQuery(limit: 10));

  print('Statement count : ${statements.data?.statements?.length}');
  _printStatements(statements.data?.statements);
  print('more at ${statements.data?.moreUrl}');

  String? more = statements.data?.moreUrl;
  while (more != null) {
    _printStatements(statements.data?.statements);
    final moreStatements = (await lrs.moreStatements(more))!;
    print('more at ${moreStatements.data?.moreUrl}');
    more = moreStatements.data?.moreUrl;
  }
}

void _printStatements(List<Statement?>? statements) {
  statements?.forEach((statement) {
    print('  Statement - ${statement!.id}');
  });
}
