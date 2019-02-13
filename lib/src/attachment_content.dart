import 'dart:convert';
import 'dart:typed_data';

class AttachmentContent {
  final List<int> _content;

  AttachmentContent.fromString(String content)
      : _content = Uint8List.fromList(content.codeUnits);

  AttachmentContent.fromList(List<int> content) : _content = content;

  AttachmentContent.fromUint8List(Uint8List content) : _content = content;

  ByteBuffer asByteBuffer() => Uint8List.fromList(_content).buffer;

  String asString() => utf8.decode(_content);

  List<int> asList() => _content;

  int get length => _content.length;
}
