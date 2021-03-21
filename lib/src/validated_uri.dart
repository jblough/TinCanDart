class ValidatedUri {
  final Uri uri;

  ValidatedUri(this.uri);

  static ValidatedUri? fromString(String? value,
      {bool appendTrailingSlash = false}) {
    if (value == null) {
      return null;
    }

    Uri url;
    if (!appendTrailingSlash || value.endsWith('/')) {
      url = Uri.parse(value);
    } else {
      url = Uri.parse('$value/');
    }

    // Unless the URI is a absolute throw an exception
    if (!url.isAbsolute) {
      throw FormatException;
    }

    return ValidatedUri(url);
  }

  Uri get asUri => uri;

  @override
  String toString() {
    return uri.toString();
  }
}
