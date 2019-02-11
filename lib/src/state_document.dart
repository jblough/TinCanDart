import 'package:TinCanDart/src/activity.dart';
import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/attachment_content.dart';
import 'package:TinCanDart/src/document.dart';
import 'package:TinCanDart/src/versions.dart';

class StateDocument extends Document {
  final Activity activity;
  final Agent agent;
  final String registration; // UUID

  StateDocument({
    this.activity,
    this.agent,
    this.registration,
    String id,
    String etag,
    DateTime timestamp,
    String contentType,
    AttachmentContent content,
  }) : super(
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

  StateDocument copyWith({
    Activity activity,
    Agent agent,
    String registration,
    String id,
    String etag,
    DateTime timestamp,
    String contentType,
    AttachmentContent content,
  }) {
    return StateDocument(
      activity: activity ?? this.activity,
      agent: agent ?? this.agent,
      registration: registration ?? this.registration,
      id: id ?? this.id,
      etag: etag ?? this.etag,
      timestamp: timestamp ?? this.timestamp,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
    );
  }
}
