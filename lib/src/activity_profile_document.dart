import './activity.dart';
import './attachment_content.dart';
import './document.dart';

class ActivityProfileDocument extends Document {
  final Activity? activity;

  ActivityProfileDocument({
    this.activity,
    String? id,
    String? etag,
    DateTime? timestamp,
    String? contentType,
    AttachmentContent? content,
  }) : super(
            id: id,
            etag: etag,
            timestamp: timestamp,
            contentType: contentType,
            content: content);

  ActivityProfileDocument copyWith(
      {Activity? activity,
      String? id,
      String? etag,
      DateTime? timestamp,
      String? contentType,
      AttachmentContent? content}) {
    return ActivityProfileDocument(
      activity: activity ?? this.activity,
      id: id ?? this.id,
      etag: etag ?? this.etag,
      timestamp: timestamp ?? this.timestamp,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
    );
  }
}
