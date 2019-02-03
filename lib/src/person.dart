import 'package:TinCanDart/src/agent_account.dart';

class Person {
  final List<String> name;
  final List<String> mbox;
  final List<String> mbox_sha1sum;
  final List<String> openid;
  final List<AgentAccount> account;

  Person({
    this.name,
    this.mbox,
    this.mbox_sha1sum,
    this.openid,
    this.account,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Person(
      name: json['name']?.cast<String>(),
      mbox: json['mbox']?.cast<String>(),
      mbox_sha1sum: json['mbox_sha1sum']?.cast<String>(),
      openid: json['openid']?.cast<String>(),
      account: AgentAccount.listFromJson(json['account']),
    );
  }
}
