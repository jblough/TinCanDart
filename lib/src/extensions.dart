class Extensions {
  final Map<Uri, dynamic> json;

  Extensions(Map<dynamic, dynamic> json) : this.json = _convertMap(json);

  static Map<Uri, dynamic> _convertMap(Map<dynamic, dynamic> json) {
    if (json == null) {
      return null;
    }

    Map<Uri, dynamic> data = {};
    json.forEach((key, value) {
      try {
        data[Uri.parse(key.toString())] = value;
      } catch (e) {
        print(e);
      }
    });
    return data;
  }

  factory Extensions.fromJson(Map<String, dynamic> json) {
    return Extensions(json);
  }

  Map<String, dynamic> toJson() {
    if (json == null || json.isEmpty) {
      return null;
    }

    final map = <String, dynamic>{};
    json.forEach((key, value) => map[key.toString()] = value);
    return map;
  }
}
