import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' show BaseRequest, ByteStream;
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';

import './attachment.dart';

/// A `multipart/mixed` request. Such a request has both json content,
/// which function as the request body, and (potentially streamed) binary
/// [attachments].
///
/// This request automatically sets the Content-Type header to
/// `multipart/mixed`. This value will override any value set by the user.
///
///     var uri = Uri.parse("http://pub.dartlang.org/packages/create");
///     var request = http.MultipartMixedRequest("POST", uri);
///     request.attachments.add(Attachment(
///         'package',
///         File('build/package.tar.gz'),
///         contentType: MediaType('application', 'x-tar'));
///     request.send().then((response) {
///       if (response.statusCode == 200) print("Uploaded!");
///     });
class MultipartMixedRequest extends BaseRequest {
  /// The total length of the multipart boundaries used when building the
  /// request body. According to http://tools.ietf.org/html/rfc1341.html, this
  /// can't be longer than 70.
  static const int _BOUNDARY_LENGTH = 55;

  final String _body;

  /// The private version of [files].
  final List<Attachment> _attachments;

  /// Creates a new [MultipartMixedRequest].
  MultipartMixedRequest(String method, Uri url, String body)
      : _body = body,
        _attachments = <Attachment>[],
        super(method, url);

  /// The list of attachments to upload for this request.
  List<Attachment> get attachments => _attachments;

  /// The total length of the request body, in bytes. This is calculated from
  /// body and [attachments] and cannot be set manually.
  int get contentLength {
    var length = 0;

    final newLineLength = "\r\n".length;

    length += "--".length + _BOUNDARY_LENGTH + newLineLength;
    length += 'Content-Type: application/json\r\n\r\n'.length;
    length += _body.length + newLineLength;

    for (var attachment in _attachments) {
      length += "--".length +
          _BOUNDARY_LENGTH +
          newLineLength +
          utf8.encode(_headerForAttachment(attachment)).length +
          attachment.length +
          newLineLength;
    }

    length += "--".length + _BOUNDARY_LENGTH + "--\r\n".length;
    return length;
  }

  set contentLength(int value) {
    throw UnsupportedError("Cannot set the contentLength property of "
        "multipart requests.");
  }

  void writeAscii(StreamController controller, String string) {
    controller.add(utf8.encode(string));
  }

  writeUtf8(StreamController controller, String string) =>
      controller.add(utf8.encode(string));

  writeLine(StreamController controller) => controller.add([13, 10]); // \r\n

  /// Pipes all data and errors from [stream] into [sink]. Completes [Future] once
  /// [stream] is done. Unlike [store], [sink] remains open after [stream] is
  /// done.
  void writeStreamToSink(ByteBuffer buffer, EventSink sink) {
    sink.add(buffer.asInt8List());
  }

  /// Freezes all mutable fields and returns a single-subscription [ByteStream]
  /// that will emit the request body.
  ByteStream finalize() {
    headers.remove('content-type');
    var boundary = _boundaryString();
    headers['Content-Type'] = 'multipart/mixed; boundary=$boundary';
    super.finalize();

    var controller = StreamController<List<int>>(sync: true);

    controller.add(utf8.encode('--$boundary\r\n'));
    controller.sink.add(utf8.encode('Content-Type: application/json\r\n\r\n'));
    controller.sink.add(utf8.encode('$_body\r\n'));

    Future.forEach(_attachments, (Attachment attachment) {
      writeAscii(controller, '--$boundary\r\n');
      writeAscii(controller, _headerForAttachment(attachment));
      controller.add(attachment.content.asList());
      writeLine(controller);
    });
    writeAscii(controller, '--$boundary--\r\n');
    controller.close();

    return ByteStream(controller.stream);
  }

  /// Returns the header string for a file. The return value is guaranteed to
  /// contain only ASCII characters.
  String _headerForAttachment(Attachment attachment) {
    final contentType =
        MediaType.parse(attachment.contentType ?? 'application/octet-stream');

    final hash = 'X-Experience-API-Hash: ${attachment.sha2}';
    var header =
        'Content-Type: $contentType\r\nContent-Transfer-Encoding: binary\r\n$hash';

    return '$header\r\n\r\n';
  }

  /// Returns a randomly-generated multipart boundary string
  String _boundaryString() {
    return "dart-http-boundary-${Uuid().v4()}";
  }
}
/*
/// A stream of chunks of bytes representing a single piece of data.
class ByteStream extends StreamView<List<int>> {
  ByteStream(Stream<List<int>> stream) : super(stream);

  /// Returns a single-subscription byte stream that will emit the given bytes
  /// in a single chunk.
  factory ByteStream.fromBytes(List<int> bytes) =>
      ByteStream(Stream.fromIterable([bytes]));

  /// Collects the data of this stream in a [Uint8List].
  Future<Uint8List> toBytes() {
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback(
        (bytes) => completer.complete(Uint8List.fromList(bytes)));
    listen(sink.add,
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true);
    return completer.future;
  }

  /// Collect the data of this stream in a [String], decoded according to
  /// [encoding], which defaults to `UTF8`.
  Future<String> bytesToString([Encoding encoding = utf8]) =>
      encoding.decodeStream(this);

  Stream<String> toStringStream([Encoding encoding = utf8]) =>
      encoding.decoder.bind(this);
}
*/

/// A regular expression that matches strings that are composed entirely of
/// ASCII-compatible characters.
final RegExp _ASCII_ONLY = RegExp(r"^[\x00-\x7F]+$");

/// Returns whether [string] is composed entirely of ASCII-compatible
/// characters.
bool isPlainAscii(String string) => _ASCII_ONLY.hasMatch(string);
