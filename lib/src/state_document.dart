import 'dart:typed_data';

import 'package:TinCanDart/src/activity.dart';
import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/document.dart';
import 'package:TinCanDart/src/versions.dart';

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

  Map<String, dynamic> toJson(Version version) {
    return {
      'id': id,
      'etag': etag,
      'timestamp': timestamp?.toIso8601String(),
      'contentType': contentType,
      'content': content,
      'activity': activity?.toJson(version),
      'agent': agent?.toJson(version),
      'registration': registration, // UUID
    };
  }
}
