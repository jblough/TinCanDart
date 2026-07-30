import './activity.dart';
import './attachment_content.dart';
import './document.dart';

class ActivityProfileDocument extends Document {
  final Activity? activity;

  ActivityProfileDocument({
    this.activity,
    super.id,
    super.etag,
    super.timestamp,
    super.contentType,
    super.content,
  });

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
