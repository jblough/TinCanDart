class LanguageMap {
  final Map<String, String> map;

  LanguageMap(this.map);

  factory LanguageMap.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return LanguageMap(json);
  }

  Map<String, dynamic> toJson() {
    return map;
  }
}
