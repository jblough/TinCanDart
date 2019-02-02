import 'dart:typed_data';

import 'package:TinCanDart/src/language_map.dart';
import 'package:TinCanDart/src/versions.dart';

class Attachment {
  final Uri usageType;
  final LanguageMap display;
  final LanguageMap description;
  final String contentType;
  final int length;
  final String sha2;
  final Uri fileUrl;
  final ByteBuffer content;

  Attachment(
      {this.usageType,
      this.display,
      this.description,
      this.contentType,
      this.length,
      this.sha2,
      this.fileUrl,
      this.content});

  factory Attachment.fromJson(Map<String, dynamic> json, ByteBuffer content) {
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

  static List<Attachment> listFromJson(List<Map<String, dynamic>> list) {
    if (list == null || list.isEmpty) {
      return null;
    }

    List<Attachment> attachments = [];
    list.forEach((json) {
      attachments.add(Attachment.fromJson(json, null));
    });

    return attachments;
  }

  Map<String, dynamic> toJson(Version version) {
    final json = {
      'usageType': usageType?.toString(),
      'display': display?.toJson(),
      'description': description?.toJson(),
      'contentType': contentType,
      'length': length,
      'sha2': sha2,
      'fileUrl': fileUrl?.toString(),
      'content': content,
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
