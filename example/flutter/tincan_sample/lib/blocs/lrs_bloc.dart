import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tin_can/tin_can.dart';

export 'package:tin_can/tin_can.dart'
    show
        Statement,
        Agent,
        Group,
        Attachment,
        AttachmentContent,
        Activity,
        LanguageMap,
        Verb,
        Extensions,
        TinCanDuration,
        Result,
        Score;

class LrsBloc {
  final _statementStream = BehaviorSubject<List<Statement>>();
  final _feedback = StreamController<String>();
  Stream<String> _feedbackBroadcast;

  /// Stream of statements retrieved from the LRS
  Stream<List<Statement>> get statements => _statementStream.stream;

  /// Stream of responses from LRS operations
  Stream<String> get feedback => _feedbackBroadcast;

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
    rootBundle.loadString('assets/lrs.properties').then((value) {
      String endpoint = '';
      String username = '';
      String password = '';
      value.split('\n').forEach((line) {
        final parts = line.split('=');
        switch (parts[0].toLowerCase()) {
          case 'endpoint':
            endpoint = parts[1];
            break;
          case 'username':
            username = parts[1];
            break;
          case 'password':
            password = parts[1];
            break;
        }
      });

      _lrs = RemoteLRS(
        endpoint: endpoint,
        username: username,
        password: password,
      );
    });

    _reportStatementController.stream.listen((statement) async {
      final response =
          await _lrs.saveStatement(statement.copyWith(actor: _agent));
      if (response.success) {
        print('Recorded statement successfully');
        _feedback.add('Recorded statement successfully');
      } else {
        print('Error recording statement - ${response.errMsg}');
        _feedback.add(response.errMsg);
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
      _feedback.add(response.errMsg);
    }
  }
}

final lrsBloc = LrsBloc();
