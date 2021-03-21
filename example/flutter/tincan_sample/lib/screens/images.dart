import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tincan_sample/blocs/lrs_bloc.dart';

class ImageSelectionScreen extends StatefulWidget {
  @override
  _ImageSelectionScreenState createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final _nameRegex = RegExp('assets/images/(.*).png');

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
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Select an image'),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          _imageButton('assets/images/bird.png'),
          _imageButton('assets/images/books.png'),
          _imageButton('assets/images/checkmark.png'),
          _imageButton('assets/images/fire.png'),
          _imageButton('assets/images/fish.png'),
          _imageButton('assets/images/night-city.png'),
          _imageButton('assets/images/pencil.png'),
          _imageButton('assets/images/soccer-ball.png'),
          _imageButton('assets/images/tux.png'),
          _imageButton('assets/images/yin-yang.png'),
        ],
      ),
    );
  }

  Widget _imageButton(String asset) {
    return TextButton(
      child: Image.asset(asset),
      onPressed: () => _imageSelected(asset),
    );
  }

  Future<void> _imageSelected(String asset) async {
    final name = _nameRegex.firstMatch(asset)!.group(1);
    // Save the selection as an xAPI statement with the image as an attachment
    final image = await rootBundle.load(asset);
    lrsBloc.recordStatement(
      Statement(
        verb: Verb(
            id: 'http://adlnet.gov/expapi/verbs/selected',
            display: {'en-US': 'selected'}),
        object: Activity(
            id: 'http://tincanapi.com/TinCanDart/example/images',
            definition: ActivityDefinition(
              name: {'en-US': name},
            )),
        attachments: [
          Attachment(
              content: AttachmentContent.fromByteData(image),
              display: {'en-US': name},
              description: {'en-US': 'A picture of $name'},
              contentType: "image/png",
              usageType: 'http://id.tincanapi.com/attachment/supporting_media'),
        ],
      ),
    );
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
