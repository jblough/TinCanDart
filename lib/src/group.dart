import 'package:TinCanDart/src/agent.dart';

class Group {
  final List<Agent> members;

  Group({this.members});

  factory Group.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    List<Agent> agents = [];
    json['members']?.forEach((agent) {
      final member = Agent.fromJson(agent);
      if (member != null) {
        agents.add(member);
      }
    });

    return Group(
      members: agents,
    );
  }
}
