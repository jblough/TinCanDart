import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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
        child: StreamBuilder<List<Statement>>(
            stream: lrsBloc.statements,
            builder: (context, snapshot) {
              return _generateBody(context, snapshot);
            }),
      )),
    );
  }

  Widget _generateBody(
      BuildContext context, AsyncSnapshot<List<Statement>> snapshot) {
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
          final statementWidgets = <Widget>[
            Container(
              foregroundDecoration: BoxDecoration(
                  border: Border.all(
                color: Colors.grey,
                width: 1,
                style: BorderStyle.solid,
              )),
              margin: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              padding: EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentlyExpanded = null;
                  });
                },
                child: Text(
                  encoder.convert(statement.toJson()),
                ),
              ),
            )
          ];
          statement.attachments?.forEach((Attachment attachment) {
            statementWidgets.add(ListTile(
              onTap: () => _displayAttachment(context, attachment),
              leading: Icon(Icons.attachment, size: 48.0),
              title: Text(attachment.display?.values?.first ?? 'Unknown'),
              subtitle:
                  Text(attachment.description?.values?.first ?? 'Unknown'),
            ));
          });

          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              if (isExpanded) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentlyExpanded = null;
                        });
                      },
                      child: Text(_statementShortSummary(statement))),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentlyExpanded = statement.id;
                      });
                    },
                    child: Text(_statementSummary(statement)),
                  ),
                );
              }
            },
            body: Column(
              children: statementWidgets,
            ),
            isExpanded: _currentlyExpanded == statement.id,
          );
        }).toList(),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  String _statementSummary(Statement statement) {
    String who = '';
    if (statement.actor is Group) {
      who = 'Group: ${(statement.actor as Group).name}';
    } else {
      who = statement.actor.name;
    }

    String verb = statement.verb.display?.values?.first;

    String when = statement.timestamp?.toIso8601String() ?? '';

    String what = '';
    if (statement.object is Activity) {
      what = (statement.object as Activity).definition?.name?.values?.first;
    } else if (statement.object is StatementRef) {
      what = (statement.object as StatementRef).id;
    }

    String result = '';

    if (statement.result != null) {
      result = '${statement.result.score?.raw ?? 0}%';
    }

    return '$when $who $verb $what $result';
  }

  String _statementShortSummary(Statement statement) {
    String who = '';
    if (statement.actor is Group) {
      who = 'Group: ${(statement.actor as Group).name}';
    } else {
      who = statement.actor.name;
    }

    String when = statement.timestamp?.toIso8601String() ?? '';

    return '$when $who';
  }

  Future<void> _displayAttachment(
      BuildContext context, Attachment attachment) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(attachment.display?.values?.first ?? ''),
          content: Container(
            child: Image.memory(attachment.content.asList()),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
      barrierDismissible: true,
    );
  }
}
