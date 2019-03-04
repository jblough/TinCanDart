import 'package:flutter/material.dart';
import 'package:tincan_sample/screens/menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TinCan Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MenuScreen());
  }
}
