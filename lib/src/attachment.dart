import 'package:crypto/crypto.dart' show sha256;

import './attachment_content.dart';
import './validated_uri.dart';
import './versions.dart';

class Attachment {
  final ValidatedUri usageType;
  final Map<String, dynamic> display;
  final Map<String, dynamic> description;
  final String contentType;
  final int length;
  final String sha2;
  final ValidatedUri fileUrl;

  AttachmentContent content;

  /// Examples: https://registry.tincanapi.com/#home/attachmentUsages
  Attachment({
    dynamic usageType,
    this.display,
    this.description,
    this.contentType,
    int length,
    String sha2,
    dynamic fileUrl,
    this.content,
  })  : this.usageType = ValidatedUri.fromString(usageType?.toString()),
        this.fileUrl = ValidatedUri.fromString(fileUrl?.toString()),
        this.length = length ?? content?.length,
        this.sha2 =
            sha2 ?? ((content != null) ? sha2sum(content.asList()) : null);

  static String sha2sum(List<int> data) {
    return sha256.convert(data).toString();
  }

  static Attachment fromJson(
      Map<String, dynamic> /*?*/ json, AttachmentContent content) {
    if (json == null) {
      return null;
    }

    return Attachment(
      usageType: json['usageType'],
      display: json['display'],
      description: json['description'],
      contentType: json['contentType'],
      length: json['length'],
      sha2: json['sha2'],
      fileUrl: json['fileUrl'],
      content: content,
    );
  }

  static List<Attachment /*!*/ > listFromJson(List<dynamic> list) {
    return list
        ?.map((json) => Attachment.fromJson(json, null))
        ?.where((attachment) => attachment != null)
        ?.toList();
  }

  Map<String, dynamic> toJson([Version version]) {
    final json = {
      'usageType': usageType?.toString(),
      'display': display,
      'description': description,
      'contentType': contentType,
      'length': length,
      'sha2': sha2,
      'fileUrl': fileUrl?.toString(),
      //'content': content,
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
