import './agent.dart';
import './attachment_content.dart';
import './document.dart';

class AgentProfileDocument extends Document {
  final Agent? agent;

  AgentProfileDocument({
    this.agent,
    super.id,
    super.etag,
    super.timestamp,
    super.contentType,
    super.content,
  });

  AgentProfileDocument copyWith({
    Agent? agent,
    String? id,
    String? etag,
    DateTime? timestamp,
    String? contentType,
    AttachmentContent? content,
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
