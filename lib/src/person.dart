import './agent_account.dart';

class Person {
  final List<String> name;
  final List<String> mbox;
  final List<String> mboxSHA1Sum;
  final List<String> openID;
  final List<AgentAccount> account;

  Person({
    this.name,
    this.mbox,
    this.mboxSHA1Sum,
    this.openID,
    this.account,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Person(
      name: json['name']?.cast<String>(),
      mbox: json['mbox']?.cast<String>(),
      mboxSHA1Sum: json['mbox_sha1sum']?.cast<String>(),
      openID: json['openid']?.cast<String>(),
      account: AgentAccount.listFromJson(json['account']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'objectType': 'Person',
      'name': name,
      'mbox': mbox,
      'mbox_sha1sum': mboxSHA1Sum,
      'openid': openID,
      'account': account?.toList(),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
