import 'package:flutter/material.dart';
import 'package:tincan_sample/blocs/lrs_bloc.dart';
import 'package:tincan_sample/screens/menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    WidgetsFlutterBinding.ensureInitialized();
    // Doing this to give lrsBloc time to
    // initialize from settings file
    print(lrsBloc);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TinCan Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: MenuScreen());
  }
}
