class Extensions {
  final Map<Uri, dynamic>? json;

  /// Examples: https://registry.tincanapi.com/#home/extensions
  Extensions(Map<dynamic, dynamic>? json) : json = _convertMap(json);

  static Map<Uri, dynamic>? _convertMap(Map<dynamic, dynamic>? json) {
    if (json == null) {
      return null;
    }

    final data = <Uri, dynamic>{};
    json.forEach((key, value) {
      try {
        data[Uri.parse(key.toString())] = value;
      } catch (e) {
        print(e);
      }
    });
    return data;
  }

  static Extensions fromJson(Map<String, dynamic>? json) {
    return Extensions(json);
  }

  Map<String, dynamic>? toJson() {
    if (json == null || json!.isEmpty) {
      return null;
    }

    final map = <String, dynamic>{};
    json!.forEach((key, value) => map[key.toString()] = value);
    return map;
  }
}
