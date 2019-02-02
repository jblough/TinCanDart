import 'dart:typed_data';

import 'package:TinCanDart/src/activity.dart';
import 'package:TinCanDart/src/document.dart';

class ActivityProfileDocument extends Document {
  final Activity activity;

  ActivityProfileDocument(
      {this.activity,
      String id,
      String etag,
      DateTime timestamp,
      String contentType,
      ByteBuffer content})
      : super(
            id: id,
            etag: etag,
            timestamp: timestamp,
            contentType: contentType,
            content: content);
}
