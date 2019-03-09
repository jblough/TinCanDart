import 'package:flutter/material.dart';
import 'package:tincan_sample/screens/counter.dart';
import 'package:tincan_sample/screens/images.dart';
import 'package:tincan_sample/screens/stepper.dart';
import 'package:tincan_sample/screens/viewer.dart';

typedef MenuSelectionCallback = void Function(BuildContext);

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final items = [
    'Counter',
    'Stepper',
    'Select an image',
    'View Statements',
  ];

  final onTaps = <MenuSelectionCallback>[
    (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CounterScreen()),
      );
    },
    (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StepperScreen()),
      );
    },
    (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImageSelectionScreen()),
      );
    },
    (context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StatementViewer()),
      );
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TinCan Demo'),
      ),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return MenuItem(items[index], onTaps[index]);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.grey,
            height: 1,
          );
        },
        itemCount: items.length,
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String text;
  final MenuSelectionCallback onTap;

  MenuItem(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Container(
        padding: EdgeInsets.all(24.0),
        child: Text(
          this.text,
          style: TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
