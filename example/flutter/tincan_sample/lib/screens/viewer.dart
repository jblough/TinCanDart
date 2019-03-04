import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tin_can/tin_can.dart' as tincan;
import 'package:tincan_sample/blocs/lrs_bloc.dart';

class StatementViewer extends StatefulWidget {
  @override
  State createState() => _StatementViewerState();
}

class _StatementViewerState extends State<StatementViewer> {
  String _currentlyExpanded;

  @override
  void initState() {
    super.initState();

    lrsBloc.refreshStatements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statement Viewer'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<tincan.Statement>>(
            stream: lrsBloc.statements,
            builder: (context, snapshot) {
              return _generateBody(context, snapshot);
            }),
      )),
    );
  }

  Widget _generateBody(
      BuildContext context, AsyncSnapshot<List<tincan.Statement>> snapshot) {
    if (snapshot.hasData) {
      final statements = snapshot.data ?? [];
      final encoder = JsonEncoder.withIndent('  ');
      return ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            if (!isExpanded) {
              _currentlyExpanded = statements[index].id;
            } else {
              _currentlyExpanded = null;
            }
          });
        },
        children: statements.map((statement) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              if (isExpanded) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_statementShortSummary(statement)),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_statementSummary(statement)),
                );
              }
            },
            body: Container(
              foregroundDecoration: BoxDecoration(
                  border: Border.all(
                color: Colors.grey,
                width: 1,
                style: BorderStyle.solid,
              )),
              margin: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              padding: EdgeInsets.all(8.0),
              child: Text(
                encoder.convert(statement.toJson()),
              ),
            ),
            isExpanded: _currentlyExpanded == statement.id,
          );
        }).toList(),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  String _statementSummary(tincan.Statement statement) {
    String who = '';
    if (statement.actor is tincan.Group) {
      who = 'Group: ${(statement.actor as tincan.Group).name}';
    } else {
      who = statement.actor.name;
    }

    String verb = statement.verb.display?.map?.values?.first;

    String when = statement.timestamp?.toIso8601String() ?? '';

    String what = '';
    if (statement.object is tincan.Activity) {
      what = (statement.object as tincan.Activity)
          .definition
          ?.name
          ?.map
          ?.values
          ?.first;
    } else if (statement.object is tincan.StatementRef) {
      what = (statement.object as tincan.StatementRef).id;
    }

    String result = '';

    if (statement.result != null) {
      result = '${statement.result.score.raw}%';
    }

    return '$when $who $verb $what $result';
  }

  String _statementShortSummary(tincan.Statement statement) {
    String who = '';
    if (statement.actor is tincan.Group) {
      who = 'Group: ${(statement.actor as tincan.Group).name}';
    } else {
      who = statement.actor.name;
    }

    String when = statement.timestamp?.toIso8601String() ?? '';

    return '$when $who';
  }
}
