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

  static Version fromJsonString(String version) {
    switch (version) {
      case "1.0.3":
        return Version.V103;
      case "1.0.2":
        return Version.V102;
      case "1.0.1":
        return Version.V101;
      case "1.0.0":
        return Version.V100;
      case "0.95":
        return Version.V095;
      case "0.9":
        return Version.V09;
      default:
        throw Exception("Unrecognized version $version");
    }
  }

  static String toJsonString(Version version) {
    if (version == null) {
      return null;
    }

    switch (version) {
      case Version.V103:
        return "1.0.3";
      case Version.V102:
        return "1.0.2";
      case Version.V101:
        return "1.0.1";
      case Version.V100:
        return "1.0.0";
      case Version.V095:
        return "0.95";
      case Version.V09:
        return "0.9";
      default:
        throw Exception("Unrecognized version $version");
    }
  }
}
