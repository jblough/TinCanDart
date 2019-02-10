import 'dart:typed_data';

import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/document.dart';

class AgentProfileDocument extends Document {
  final Agent agent;

  AgentProfileDocument({
    this.agent,
    String id,
    String etag,
    DateTime timestamp,
    String contentType,
    ByteBuffer content,
  }) : super(
            id: id,
            etag: etag,
            timestamp: timestamp,
            contentType: contentType,
            content: content);

  AgentProfileDocument copyWith({
    Agent agent,
    String id,
    String etag,
    DateTime timestamp,
    String contentType,
    ByteBuffer content,
  }) {
    return AgentProfileDocument(
      agent: agent ?? this.agent,
      id: id ?? this.id,
      etag: etag ?? this.etag,
      timestamp: timestamp ?? this.timestamp,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
    );
  }
}
