import 'dart:typed_data';

class Document {
  final String id;
  final String etag;
  final DateTime timestamp;
  final String contentType;
  final ByteBuffer content;

  Document(
      {this.id, this.etag, this.timestamp, this.contentType, this.content});
}
