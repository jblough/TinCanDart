import 'dart:typed_data';

import 'package:TinCanDart/src/activity.dart';
import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/document.dart';

class StateDocument extends Document {
  final Activity activity;
  final Agent agent;
  final String registration; // UUID

  StateDocument(
      {this.activity,
      this.agent,
      this.registration,
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
