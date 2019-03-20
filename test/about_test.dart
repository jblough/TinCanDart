import 'dart:convert';

import 'package:test/test.dart';
import 'package:tincan/tincan.dart' show About;

void main() {
  test("should import about", () {
    final about = About.fromJson(json.decode(_json));
    expect(about.version.length, 3);
    expect(about.extensions.json.length, 1);
    expect(about.extensions.json.keys.first.toString(),
        "http://id.tincanapi.com/extension/powered-by");
  });
}

final _json = """
{
  "extensions" : {
    "http://id.tincanapi.com/extension/powered-by" : {
      "name" : "xAPI Engine",
      "version" : "2018.1.5.216",
      "homePage" : "http://experienceapi.com/lrs-lms/lrs-for-lmss-home/"
    }
  },
  "version" : [ "0.9", "0.95", "1.0.3" ]
}
""";
