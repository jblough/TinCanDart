import 'dart:convert';

import 'package:test/test.dart';
import 'package:tin_can/tin_can.dart' show Person;

void main() {
  test("should import person", () {
    final result = Person.fromJson(json.decode(_json));
    expect(result, isNotNull);
    expect(result.name.length, 1);
    expect(result.name[0], 'Test Agent');
    expect(result.mbox[0], 'mailto:tincanjava@tincanapi.com');
  });

  test("should export person", () {
    final person = Person(
      mbox: ['mailto:tincanjava@tincanapi.com'],
      name: ['Test Agent'],
    );
    expect(json.encode(person.toJson()), _json.trim());
  });
}

final _json = """
{"objectType":"Person","name":["Test Agent"],"mbox":["mailto:tincanjava@tincanapi.com"]}
""";
