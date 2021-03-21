import './agent_account.dart';

class Person {
  final List<String>? name;
  final List<String>? mbox;
  final List<String>? mboxSHA1Sum;
  final List<String>? openID;
  final List<AgentAccount>? account;

  Person({
    this.name,
    this.mbox,
    this.mboxSHA1Sum,
    this.openID,
    this.account,
  });

  static Person? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return Person(
      name: _fromItem(json['name']),
      mbox: _fromItem(json['mbox']),
      mboxSHA1Sum: _fromItem(json['mbox_sha1sum']),
      openID: _fromItem(json['openid']),
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

  static List<String>? _fromItem(dynamic item) {
    if (item == null) {
      return null;
    }

    if (item is List) {
      return item.cast<String>();
    } else if (item is String) {
      return [item];
    }
    throw Exception('Unexpected data type - ${item.runtimeType}');
  }
}
