import 'dart:convert';
import 'dart:typed_data';

class AttachmentContent {
  final List<int>? _content;

  AttachmentContent.fromString(String content)
      : _content = Uint8List.fromList(content.codeUnits);

  AttachmentContent.fromList(List<int> content) : _content = content;

  AttachmentContent.fromUint8List(Uint8List? content) : _content = content;

  AttachmentContent.fromByteData(ByteData content)
      : _content = content.buffer.asUint8List();

  AttachmentContent.fromNumber(num content)
      : _content = _convertNumber(content);

  ByteBuffer asByteBuffer() => Uint8List.fromList(_content!).buffer;

  String asString() => utf8.decode(_content!);

  List<int>? asList() => _content;

  Uint8List asUint8List() => Uint8List.fromList(_content!);

  int? asInt() {
    try {
      return ByteData.view(Uint8List.fromList(_content!).buffer).getInt64(0);
    } catch (e) {
      return null;
    }
  }

  double? asDouble() {
    try {
      return ByteData.view(Uint8List.fromList(_content!).buffer).getFloat64(0);
    } catch (e) {
      return null;
    }
  }

  int get length => _content!.length;

  static List<int> _convertNumber(num content) {
    ByteData data = ByteData(8);
    if (content is int) {
      data.setInt64(0, content);
    } else {
      data.setFloat64(0, content as double);
    }
    return data.buffer.asUint8List();
  }
}
