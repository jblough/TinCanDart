import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/attachment.dart';
import 'package:TinCanDart/src/context.dart';
import 'package:TinCanDart/src/parsing_utils.dart';
import 'package:TinCanDart/src/result.dart';
import 'package:TinCanDart/src/statement_target.dart';
import 'package:TinCanDart/src/verb.dart';
import 'package:TinCanDart/src/versions.dart';

class SubStatement extends StatementTarget {
  final Agent actor;
  final Verb verb;
  final StatementTarget object;
  final Result result;
  final Context context;
  final DateTime timestamp;
  final List<Attachment> attachments;

  @deprecated
  final bool voided;

  SubStatement({
    this.actor,
    this.verb,
    this.object,
    this.result,
    this.context,
    this.timestamp,
    this.attachments,
    this.voided,
  });

  factory SubStatement.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return SubStatement(
      actor: Agent.fromJson(json['actor']),
      verb: Verb.fromJson(json['verb']),
      object: ParsingUtils.parseTarget(json['object']),
      result: Result.fromJson(json['result']),
      context: Context.fromJson(json['context']),
      timestamp: ParsingUtils.parseDate(json['timestamp']),
      attachments: Attachment.listFromJson(json['attachments']),
      voided: json['voided'],
    );
  }

  @override
  Map<String, dynamic> toJson(Version version) {
    return {
      'objectType': 'SubStatement',
      'actor': actor.toJson(version),
      'verb': verb,
      'object': object.toJson(version),
      // 'result': result.toJson(version),
      // 'context': result.to
    };
  }
}
