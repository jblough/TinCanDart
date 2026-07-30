import './agent.dart';
import './agent_account.dart';
import './versions.dart';

class Group extends Agent {
  final List<Agent>? members;

  Group({
    super.name,
    super.mbox,
    super.mboxSHA1Sum,
    super.openID,
    super.account,
    this.members,
  });

  static Group? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    final agents = <Agent>[];
    json['member']?.forEach((dynamic agent) {
      final member = Agent.fromJson(agent as Map<String, dynamic>?);
      if (member != null) {
        agents.add(member);
      }
    });

    return Group(
      name: json['name'] as String?,
      mbox: json['mbox'] as String?,
      mboxSHA1Sum: json['mbox_sha1sum'] as String?,
      openID: json['openid'] as String?,
      account: AgentAccount.fromJson(json['account'] as Map<String, dynamic>?),
      members: agents,
    );
  }

  @override
  Map<String, dynamic> toJson([Version? version]) {
    version ??= TinCanVersion.latest();

    // Start with the base class members
    final json = super.toJson(version);

    // Override the object type
    json['objectType'] = 'Group';

    // Add the members
    if (members?.isNotEmpty == true) {
      json['member'] =
          members!.map((member) => member.toJson(version)).toList();
    }

    return json;
  }
}
