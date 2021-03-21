class LanguageMap {
  final Map<String, dynamic> map;

  LanguageMap(this.map);

  static LanguageMap /*?*/ fromJson(Map<String, dynamic> /*?*/ json) {
    if (json == null) {
      return null;
    }

    return LanguageMap(json);
  }

  Map<String, dynamic> toJson() {
    return map;
  }
}
