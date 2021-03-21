import 'dart:convert';

import 'package:test/test.dart';
import 'package:tincan/tincan.dart'
    show Group, Agent, AgentAccount, TinCanVersion;

void main() {
  test("should import group", () {
    final result = Group.fromJson(json.decode(_json))!;
    expect(result, isNotNull);
    expect(result.name, 'HT2');
    expect(result.members!.length, 1);
    expect(result.members![0].account!.name, '123');
    expect(
        result.members![0].account!.homePage, 'http://www.example.com/users/');
  });

  test("should export group", () {
    final group = Group(
      name: 'HT2',
      members: [
        Agent(
          name: 'John Smith',
          account: AgentAccount(
            name: '123',
            homePage: 'http://www.example.com/users/',
          ),
        ),
      ],
    );
    expect(json.encode(group.toJson(TinCanVersion.latest())), _json.trim());
  });
}

final _json = """
{"objectType":"Group","name":"HT2","member":[{"objectType":"Agent","name":"John Smith","account":{"name":"123","homePage":"http://www.example.com/users/"}}]}
""";
