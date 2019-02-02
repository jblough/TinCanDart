import 'package:TinCanDart/src/agent_account.dart';
import 'package:TinCanDart/src/statement_target.dart';
import 'package:TinCanDart/src/versions.dart';

class Agent extends StatementTarget {
  final String name;
  final String mbox;
  final String mboxSHA1Sum;
  final String openID;
  final AgentAccount account;

  Agent({
    this.name,
    this.mbox,
    this.mboxSHA1Sum,
    this.openID,
    this.account,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Agent(
      name: json['name'],
      mbox: json['mbox'],
      mboxSHA1Sum: json['mboxSHA1Sum'],
      openID: json['openID'],
      account: AgentAccount.fromJson(json['account']),
    );
  }

  @override
  Map<String, dynamic> toJson(Version version) {
    final json = {
      'objectType': 'Agent',
      'name': name,
      'mbox': mbox,
      'mboxSHA1Sum': mboxSHA1Sum,
      'openID': openID,
      'account': account?.toJson(version),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
