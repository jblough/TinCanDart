import 'package:crypto/crypto.dart' show sha1;

import './agent_account.dart';
import './group.dart';
import './statement_target.dart';
import './versions.dart';

class Agent extends StatementTarget {
  final String? name;
  final String? mbox;
  final String? mboxSHA1Sum;
  final String? openID;
  final AgentAccount? account;

  Agent({
    this.name,
    this.mbox,
    this.mboxSHA1Sum,
    this.openID,
    this.account,
  });

  static String sha1sum(String value) {
    return sha1.convert(value.codeUnits).toString();
  }

  static Agent? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    final type = json['objectType'];
    if (type == 'Group') {
      return Group.fromJson(json);
    } else {
      return Agent(
        name: json['name'] as String?,
        mbox: json['mbox'] as String?,
        mboxSHA1Sum: json['mbox_sha1sum'] as String?,
        openID: json['openid'] as String?,
        account: AgentAccount.fromJson(json['account'] as Map<String, dynamic>?),
      );
    }
  }

  @override
  Map<String, dynamic> toJson([Version? version]) {
    version ??= TinCanVersion.latest();

    final json = {
      'objectType': 'Agent',
      'name': name,
      'mbox': mbox,
      'mbox_sha1sum': mboxSHA1Sum,
      'openid': openID,
      'account': account?.toJson(version),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
