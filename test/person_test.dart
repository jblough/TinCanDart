import 'dart:convert';

import 'package:TinCanDart/src/person.dart';
import 'package:test/test.dart';

void main() {
  test("should import person", () {
    final result = Person.fromJson(json.decode(_json));
    expect(result, isNotNull);
  });
}

final _json = """
{"name":["Test Agent"],"mbox":["mailto:tincanjava@tincanapi.com"],"objectType":"Person"}
""";
