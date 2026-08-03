// ignore_for_file: constant_identifier_names
enum Version {
  V200("2.0.0"),
  V103("1.0.3"),
  V102("1.0.2"),
  V101("1.0.1"),
  V100("1.0.0"),
  V095("0.95"),
  V09("0.9");

  final String jsonString;

  const Version(this.jsonString);
}

class TinCanVersion {
  static Version latest() => Version.V200;

  static Version? fromJsonString(String? version) => switch (version) {
      null => null,
      "2.0.0" => Version.V200,
      "1.0.3" => Version.V103,
      "1.0.2" => Version.V102,
      "1.0.1" => Version.V101,
      "1.0.0" => Version.V100,
      "0.95" => Version.V095,
      "0.9" => Version.V09,
      _ => throw Exception("Unrecognized version $version")
    };
}
