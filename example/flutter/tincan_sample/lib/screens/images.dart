import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tincan_sample/blocs/lrs_bloc.dart';

import 'lrs_feedback_screen_state.dart';

class ImageSelectionScreen extends StatefulWidget {
  @override
  State createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends LrsFeedbackScreenState<ImageSelectionScreen> {
  final _nameRegex = RegExp('assets/images/(.*).png');

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
}
