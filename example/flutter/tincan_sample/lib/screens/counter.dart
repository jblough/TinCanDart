import 'package:flutter/material.dart';
import 'package:tincan_sample/blocs/lrs_bloc.dart';
import 'package:tincan_sample/screens/lrs_feedback_screen_state.dart';

class CounterScreen extends StatefulWidget {
  CounterScreen({super.key});

  @override
  State createState() => _CounterScreenState();
}

class _CounterScreenState extends LrsFeedbackScreenState<CounterScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    _sendIncrementCounterStatement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 24.0),
                textAlign: TextAlign.center,
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
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
    lrsBloc.recordStatement(
      Statement(
        verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/incremented',
          display: {'en-US': 'incremented'},
        ),
        result: Result(
          response: _counter.toString(),
        ),
        object: Activity(
          id: 'http://tincanapi.com/TinCanDart/example/counter',
          definition: ActivityDefinition(
            name: {'en-US': 'incrementing counter'},
          ),
        ),
      ),
    );
  }

}
