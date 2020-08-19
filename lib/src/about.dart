import './extensions.dart';
import './versions.dart';

class About {
  ///
  /// Sample JSON:
  /// {
  ///      "extensions" : {
  ///          "http://id.tincanapi.com/extension/powered-by" : {
  ///             "name" : "xAPI Engine",
  ///             "version" : "2018.1.5.216",
  ///             "homePage" : "http://experienceapi.com/lrs-lms/lrs-for-lmss-home/"
  ///          }
  ///      },
  ///      "version" : [ "0.9", "0.95", "1.0.3" ]
  ///  }
  ///
  final List<Version> version;
  final Extensions extensions;

  About({this.version, this.extensions});

  factory About.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    final versions = <Version>[];
    json['version']?.forEach((version) {
      final tcVersion = TinCanVersion.fromJsonString(version);
      if (tcVersion != null) {
        versions.add(tcVersion);
      }
    });

    return About(
      version: versions,
      extensions: Extensions.fromJson(json['extensions']),
    );
  }
}
