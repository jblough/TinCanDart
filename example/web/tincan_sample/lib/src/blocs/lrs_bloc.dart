import 'dart:async';
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tincan/tincan.dart';

export 'package:tincan/tincan.dart';

class LrsFeedback {
  final bool isError;
  final String feedback;

  LrsFeedback({this.isError = false, this.feedback});
}

@Injectable()
class LrsBloc {
  final _statementStream = BehaviorSubject<List<Statement>>();
  final _feedback = StreamController<LrsFeedback>();
  Stream<LrsFeedback> _feedbackBroadcast;

  /// Stream of statements retrieved from the LRS
  Stream<List<Statement>> get statements => _statementStream.stream;

  /// Stream of responses from LRS operations
  Stream<LrsFeedback> get feedback => _feedbackBroadcast;

  final _reportStatementController = StreamController<Statement>();

  /// Record a Statement on the LRS
  Function(Statement) get recordStatement =>
      _reportStatementController.sink.add;

  LRS _lrs;
  final Agent _agent = Agent(
      mbox: 'mailto:test-${Random.secure().nextInt(30000)}@example.com',
      name: 'Sample User');

  LrsBloc() {
    _feedbackBroadcast = _feedback.stream.asBroadcastStream();
    String endpoint = '...';
    String username = '...';
    String password = '...';
    _lrs = RemoteLRS(
      endpoint: endpoint,
      username: username,
      password: password,
    );

    _reportStatementController.stream.listen((statement) async {
      final response =
          await _lrs.saveStatement(statement.copyWith(actor: _agent));
      if (response.success) {
        print('Recorded statement successfully');
        _feedback.add(LrsFeedback(feedback: 'Recorded statement successfully'));
      } else {
        print('Error recording statement - ${response.errMsg}');
        _feedback.add(LrsFeedback(isError: true, feedback: response.errMsg));
      }
    });
  }

  void refreshStatements() async {
    final response = await _lrs.queryStatements(StatementsQuery(
      agent: _agent,
      attachments: true,
    ));

    if (response.success) {
      _statementStream.add(response.data.statements);
    } else {
      print('Error : ${response.errMsg}');
      _feedback.add(LrsFeedback(feedback: response.errMsg));
    }
  }
}

final lrsBloc = LrsBloc();
