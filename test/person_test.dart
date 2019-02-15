import 'dart:convert';

import 'package:test/test.dart';
import 'package:tin_can/tin_can.dart' show Person;

void main() {
  test("should import person", () {
    final result = Person.fromJson(json.decode(_json));
    expect(result, isNotNull);
  });
}

final _json = """
{"name":["Test Agent"],"mbox":["mailto:tincanjava@tincanapi.com"],"objectType":"Person"}
""";
