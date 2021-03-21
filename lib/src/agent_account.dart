import './versions.dart';

class AgentAccount {
  final String homePage;
  final String name;

  AgentAccount({this.homePage, this.name});

  static AgentAccount fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return AgentAccount(
      name: json['name'],
      homePage: json['homePage'],
    );
  }

  static List<AgentAccount /*!*/ > /*?*/ listFromJson(List<dynamic> list) {
    return list?.map((json) => AgentAccount.fromJson(json))?.toList();
  }

  Map<String, dynamic> toJson([Version version]) {
    return {
      'name': name,
      'homePage': homePage,
    };
  }
}
