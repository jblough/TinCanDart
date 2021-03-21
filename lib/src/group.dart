import './agent.dart';
import './agent_account.dart';
import './versions.dart';

class Group extends Agent {
  final List<Agent> members;

  Group({
    String name,
    String mbox,
    String mboxSHA1Sum,
    String openID,
    AgentAccount account,
    this.members,
  }) : super(
          name: name,
          mbox: mbox,
          mboxSHA1Sum: mboxSHA1Sum,
          openID: openID,
          account: account,
        );

  static Group fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    List<Agent> agents = [];
    json['member']?.forEach((agent) {
      final member = Agent.fromJson(agent);
      if (member != null) {
        agents.add(member);
      }
    });

    return Group(
      name: json['name'],
      mbox: json['mbox'],
      mboxSHA1Sum: json['mbox_sha1sum'],
      openID: json['openid'],
      account: AgentAccount.fromJson(json['account']),
      members: agents,
    );
  }

  @override
  Map<String, dynamic> toJson([Version version]) {
    version ??= TinCanVersion.latest();

    // Start with the base class members
    final json = super.toJson(version);

    // Override the object type
    json['objectType'] = 'Group';

    // Add the members
    if (this.members?.isNotEmpty == true) {
      json['member'] =
          this.members.map((member) => member.toJson(version)).toList();
    }

    return json;
  }
}
