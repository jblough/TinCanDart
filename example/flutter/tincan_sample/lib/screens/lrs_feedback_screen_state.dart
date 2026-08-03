import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tincan_sample/blocs/lrs_bloc.dart';

class LrsFeedbackScreenState<T extends StatefulWidget> extends State {

  StreamSubscription<LrsFeedback>? _subscription;


  @override
  void initState() {
    super.initState();

    _subscription = lrsBloc.feedback!.listen(_listenForFeedback);
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void _showFeedback(LrsFeedback feedback) async {
    if (feedback.isError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: <Widget>[
          Icon(Icons.error),
          Container(width: 5, height: 1),
          Text(feedback.feedback!),
        ]),
        backgroundColor: Colors.red,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: <Widget>[
          Icon(Icons.done),
          Container(width: 5, height: 1),
          Text(feedback.feedback!),
        ]),
      ));
    }
  }

  void _listenForFeedback(LrsFeedback feedback) {
    _showFeedback(feedback);
  }
}
