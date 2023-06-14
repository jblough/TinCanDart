enum Version {
  V103, // ("1.0.3")
  V102, // ("1.0.2")
  V101, // ("1.0.1")
  V100, // ("1.0.0")
  V095, // ("0.95")
  V09, // ("0.9")
}

class TinCanVersion {
  static Version latest() => Version.V103;

  static Version? fromJsonString(String? version) {
    if (version == null) {
      return null;
    }

    return switch (version) {
      '1.0.3' => Version.V103,
      '1.0.2' => Version.V102,
      '1.0.1' => Version.V101,
      '1.0.0' => Version.V100,
      '0.95' => Version.V095,
      '0.9' => Version.V09,
      _ => throw Exception("Unrecognized version $version"),
    };
  }

  static String? toJsonString(Version? version) {
    if (version == null) {
      return null;
    }

    return switch (version) {
      Version.V103 => '1.0.3',
      Version.V102 => '1.0.2',
      Version.V101 => '1.0.1',
      Version.V100 => '1.0.0',
      Version.V095 => '0.95',
      Version.V09 => '0.9',
      () => throw Exception('Unrecognized version $version'),
    };
  }
}
