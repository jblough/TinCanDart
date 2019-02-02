import 'package:TinCanDart/src/versions.dart';

class AgentAccount {
  final String homePage;
  final String name;

  AgentAccount({this.homePage, this.name});

  factory AgentAccount.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return AgentAccount(
      homePage: json['homePage'],
      name: json['name'],
    );
  }

  static List<AgentAccount> listFromJson(List<Map<String, dynamic>> list) {
    if (list == null || list.isEmpty) {
      return null;
    }

    List<AgentAccount> accounts = [];
    list.forEach((json) {
      accounts.add(AgentAccount.fromJson(json));
    });

    return accounts;
  }

  Map<String, dynamic> toJson(Version version) {
    return {
      'homePage': homePage,
      'name': name,
    };
  }
}
