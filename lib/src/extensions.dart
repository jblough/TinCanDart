class Extensions {
  final Map<Uri, dynamic> json;

  Extensions(this.json);

  factory Extensions.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    Map<Uri, dynamic> data = {};
    json.forEach((key, value) {
      try {
        data[Uri.parse(key)] = value;
      } catch (e) {
        print(e);
      }
    });
    return Extensions(data);
  }

  Map<String, dynamic> toJson() {
    if (json == null || json.isEmpty) {
      return null;
    }

    final map = {};
    json?.forEach((key, value) => map[key.toString()] = value);
    return map;
  }
}
