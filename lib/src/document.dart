import './attachment_content.dart';

abstract class Document {
  final String id;
  final String etag;
  final DateTime timestamp;
  final String contentType;

  final AttachmentContent content;

  Document({
    this.id,
    this.etag,
    this.timestamp,
    this.contentType,
    this.content,
  });
}
