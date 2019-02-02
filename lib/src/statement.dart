import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/attachment.dart';
import 'package:TinCanDart/src/context.dart';
import 'package:TinCanDart/src/parsing_utils.dart';
import 'package:TinCanDart/src/result.dart';
import 'package:TinCanDart/src/statement_target.dart';
import 'package:TinCanDart/src/verb.dart';
import 'package:TinCanDart/src/versions.dart';

class Statement {
  final String id; // Uuid
  final DateTime stored;
  final Agent authority;
  final Version version;

  final Agent actor;
  final Verb verb;
  final StatementTarget object;
  final Result result;
  final Context context;
  final DateTime timestamp;
  final List<Attachment> attachments;

  @deprecated
  final bool voided;

  Statement({
    this.id,
    this.stored,
    this.authority,
    this.version,
    this.actor,
    this.verb,
    this.object,
    this.result,
    this.context,
    this.timestamp,
    this.attachments,
    this.voided,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Statement(
      id: json['id'],
      stored: ParsingUtils.parseDate(json['stored']),
      authority: Agent.fromJson(json['authority']),
      version: TinCanVersion.fromJsonString(json['version']),
      actor: Agent.fromJson(json['actor']),
      verb: Verb.fromJson(json['verb']),

      // This can be StatementRef or SubStatement final StatementTarget object;
      object: ParsingUtils.parseTarget(json['object']),

      result: Result.fromJson(json['result']),
      context: Context.fromJson(json['context']),
      timestamp: ParsingUtils.parseDate(json['timestamp']),
      attachments: Attachment.listFromJson(json['attachments']),
      voided: json['voided'],
    );
  }

  Map<String, dynamic> toJson(Version version) {
    final json = {
      'id': id,
      'stored': stored,
      'authority': authority?.toJson(version),
      //'version': TinCanVersion.toJsonString(version),
      'actor': actor?.toJson(version),
      'verb': verb?.toJson(),
      'object': object?.toJson(version),
      'result': result?.toJson(version),
      'context': context?.toJson(version),
      'timestamp': timestamp?.toUtc()?.toIso8601String(),
      'attachments': attachments?.map((a) => a.toJson(version))?.toList(),
      'voided': voided,
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }

  Statement copyWith({String id}) {
    return Statement(
      id: id,
      stored: stored,
      authority: authority,
      version: version,
      actor: actor,
      verb: verb,
      object: object,
      result: result,
      context: context,
      timestamp: timestamp,
      attachments: attachments,
      voided: voided,
    );
  }
}
