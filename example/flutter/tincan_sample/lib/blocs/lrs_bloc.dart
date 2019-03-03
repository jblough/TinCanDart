import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:rxdart/rxdart.dart';
import 'package:tin_can/tin_can.dart';

class LrsBloc {
  final BehaviorSubject<List<Statement>> _statementStream =
      BehaviorSubject<List<Statement>>();

  /// Stream of statements retrieved from the LRS
  Stream<List<Statement>> get statements => _statementStream;
  final _reportStatementController = StreamController<Statement>();

  /// Record a Statement on the LRS
  Function(Statement) get recordStatement =>
      _reportStatementController.sink.add;

  LRS _lrs;
  final Agent _agent = Agent(
      mbox: 'mailto:test-${Random.secure().nextInt(30000)}@example.com',
      name: 'Sample User');

  LrsBloc() {
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

    _reportStatementController.stream.listen((statement) {
      _lrs.saveStatement(statement.copyWith(actor: _agent));
    });
  }

  void refreshStatements() {
    _lrs
        .queryStatements(StatementsQuery(
      agent: _agent,
    ))
        .then((response) {
      if (response.success) {
        _statementStream.add(response.data.statements);
      }
    });
  }
}

final lrsBloc = LrsBloc();
