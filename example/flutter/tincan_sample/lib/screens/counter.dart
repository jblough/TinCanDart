import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tin_can/tin_can.dart' as tincan;
import 'package:tincan_sample/blocs/lrs_bloc.dart';

class CounterScreen extends StatefulWidget {
  CounterScreen({Key key}) : super(key: key);

  @override
  State createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _feedback;
  StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = lrsBloc.feedback.listen(_listenForFeedback);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    _sendIncrementCounterStatement();
  }

  @override
  Widget build(BuildContext context) {
    if (_feedback != null) {
      _showFeedback(_feedback);
      _feedback = null;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
                style:
                    Theme.of(context).textTheme.body1.copyWith(fontSize: 24.0),
                textAlign: TextAlign.center,
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.display1,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendIncrementCounterStatement() {
    lrsBloc.recordStatement(tincan.Statement(
      verb: tincan.Verb(
          id: 'http://adlnet.gov/expapi/verbs/incremented',
          display: tincan.LanguageMap({'en-US': 'incremented'})),
      object: tincan.Activity(
          id: 'http://tincanapi.com/TinCanDart/example/counter'),
    ));
  }

  void _showFeedback(String feedback) async {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(feedback),
      duration: Duration(milliseconds: 500),
    ));
  }

  void _listenForFeedback(String feedback) {
    setState(() {
      _feedback = feedback;
    });
  }
}
