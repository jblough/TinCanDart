import 'package:flutter/material.dart';

class StepperScreen extends StatefulWidget {
  @override
  _StepperScreenState createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Stepper'),
        ),
        body: _buildSteps(context));
  }

  Widget _buildSteps(BuildContext context) {
    final steps = [
      Step(
          title: Text('Step 1'),
          content: Text('First step...'),
          isActive: true),
      Step(
          title: Text('Step 2'),
          content: Text('Second step...'),
          isActive: true),
      Step(
          title: Text('Step 3'),
          content: Text('Third step...'),
          isActive: true),
    ];
    return Stepper(
      steps: steps,
      currentStep: _currentStep,
      onStepContinue: () {
        if (_currentStep < steps.length - 1) {
          setState(() {
            _currentStep++;
          });
        } else {
          Navigator.of(context).pop();
        }
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
          });
        } else {
          Navigator.of(context).pop();
        }
      },
      onStepTapped: (int step) {
        setState(() {
          _currentStep = step;
        });
      },
    );
  }
}
