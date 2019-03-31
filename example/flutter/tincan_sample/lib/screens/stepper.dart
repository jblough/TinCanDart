import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tincan_sample/blocs/lrs_bloc.dart';

class StepperScreen extends StatefulWidget {
  @override
  _StepperScreenState createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  int _currentStep = 0;
  DateTime _start;
  DateTime _finish;
  final _stepOneFocus = FocusNode();
  final _stepTwoFocus = FocusNode();
  final _stepThreeFocus = FocusNode();

  final _data = <String, dynamic>{};
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _start = DateTime.now();
  }

  @override
  void dispose() {
    _stepOneFocus.dispose();
    _stepTwoFocus.dispose();
    _stepThreeFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Stepper'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildSteps(context),
              Container(
                height: 15,
              ),
              RaisedButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 64.0),
                  child: Text(
                    "SUBMIT",
                    style: Theme.of(context).textTheme.headline.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
                onPressed: () {
                  _finish = DateTime.now();
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    _sendStatements(context);
                  } else {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                            'Please fill in the form completely before submitting')));
                  }
                },
              )
            ],
          ),
        ));
  }

  Widget _buildSteps(BuildContext context) {
    final steps = [
      Step(
          title: Text('Step 1'),
          content: TextFormField(
            decoration:
                InputDecoration(hintText: 'First name (not necessarily yours)'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a value';
              }
            },
            onSaved: (value) {
              _data['firstName'] = value;
            },
            autofocus: true,
            focusNode: _stepOneFocus,
          ),
          isActive: true),
      Step(
          title: Text('Step 2'),
          content: TextFormField(
            decoration:
                InputDecoration(hintText: 'Last name (not necessarily yours)'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a value';
              }
            },
            onSaved: (value) {
              _data['lastName'] = value;
            },
            focusNode: _stepTwoFocus,
          ),
          isActive: true),
      Step(
          title: Text('Step 3'),
          content: TextFormField(
            decoration: InputDecoration(hintText: 'Number'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a number';
              }
            },
            onSaved: (value) {
              _data['number'] = value;
            },
            focusNode: _stepThreeFocus,
          ),
          isActive: true),
    ];
    return Stepper(
      steps: steps,
      currentStep: _currentStep,
      onStepContinue: () {
        // Close the keyboard if open
        FocusScope.of(context).requestFocus(FocusNode());

        // Update the stepper position
        if (_currentStep < steps.length - 1) {
          setState(() {
            _currentStep++;
          });
        } else {
          setState(() {
            _currentStep = 0;
          });
        }

        _updateFocus(context);
      },
      onStepCancel: () {
        // Close the keyboard if open
        FocusScope.of(context).requestFocus(FocusNode());

        // Update the stepper position
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
          });
        } else {
          setState(() {
            _currentStep = steps.length - 1;
          });
        }

        _updateFocus(context);
      },
      onStepTapped: (int step) {
        // Close the keyboard if open
        FocusScope.of(context).requestFocus(FocusNode());

        // Update the stepper position
        setState(() {
          _currentStep = step;
        });

        _updateFocus(context);
      },
    );
  }

  void _updateFocus(BuildContext context) {
    switch (_currentStep) {
      case 0:
        FocusScope.of(context).requestFocus(_stepOneFocus);
        break;
      case 1:
        FocusScope.of(context).requestFocus(_stepTwoFocus);
        break;
      case 2:
        FocusScope.of(context).requestFocus(_stepThreeFocus);
        break;
    }
  }

  Future<void> _sendStatements(BuildContext context) async {
    /*
      Records to record:
        completed
        answered step 1
        answered step 2
        answered step 3
     */

    final context = Context(
      extensions: Extensions(
        {
          'http://id.tincanapi.com/extension/powered-by':
              Platform.operatingSystemVersion
        },
      ),
      platform: Platform.operatingSystem,
    );

    // Completed statement
    Statement statement = Statement(
      result: Result(duration: TinCanDuration.fromDiff(_start, _finish)),
      verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/completed',
          display: {'en-US': 'completed'}),
      object: Activity(
        id: 'http://example.com/TinCanDart/stepper',
        definition: ActivityDefinition(
          name: {'en-US': 'Stepper'},
        ),
      ),
      context: context,
    );

    await lrsBloc.recordStatement(statement);

    // Answered step 1 statement
    statement = Statement(
      verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/answered',
          display: {'en-US': 'answered'}),
      result: Result(response: _data['firstName']),
      object: Activity(
        id: 'http://example.com/TinCanDart/stepper/one',
        definition: ActivityDefinition(
          name: {'en-US': 'Step 1'},
        ),
      ),
      context: context,
    );

    await lrsBloc.recordStatement(statement);

    // Answered step 2 statement
    statement = Statement(
      verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/answered',
          display: {'en-US': 'answered'}),
      result: Result(response: _data['lastName']),
      object: Activity(
        id: 'http://example.com/TinCanDart/stepper/two',
        definition: ActivityDefinition(
          name: {'en-US': 'Step 2'},
        ),
      ),
      context: context,
    );

    await lrsBloc.recordStatement(statement);

    // Answered step 3 statement
    statement = Statement(
      verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/answered',
          display: {'en-US': 'answered'}),
      result: Result(response: _data['number']),
      object: Activity(
        id: 'http://example.com/TinCanDart/stepper/three',
        definition: ActivityDefinition(
          name: {'en-US': 'Step 3'},
        ),
      ),
      context: context,
    );

    lrsBloc.recordStatement(statement);
  }
}
