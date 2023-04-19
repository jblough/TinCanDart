import './versions.dart';

class AgentAccount {
  final String? homePage;
  final String? name;

  AgentAccount({this.homePage, this.name});

  static AgentAccount? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return AgentAccount(
      name: json['name'],
      homePage: json['homePage'],
    );
  }

  static List<AgentAccount>? listFromJson(List<dynamic>? list) {
    if (list == null) {
      return null;
    }
    final agents = <AgentAccount>[];
    for (final json in list) {
      final agent = AgentAccount.fromJson(json);
      if (agent != null) {
        agents.add(agent);
      }
    }
    return agents;
  }

  Map<String, dynamic> toJson([Version? version]) {
    return {
      'name': name,
      'homePage': homePage,
    };
  }
}
