import 'package:flutter/material.dart';
import 'package:tincan_sample/blocs/lrs_bloc.dart';
import 'package:tincan_sample/screens/menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final LrsBloc _bloc = lrsBloc;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TinCan Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          //textTheme: TextTheme(body1: TextStyle(fontSize: 28.0))
        ),
        home: MenuScreen());
  }
}
