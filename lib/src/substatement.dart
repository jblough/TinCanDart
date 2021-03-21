import './agent.dart';
import './attachment.dart';
import './context.dart';
import './result.dart';
import './statement_target.dart';
import './verb.dart';
import './versions.dart';

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

  /// https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#substatements
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

  static SubStatement /*?*/ fromJson(Map<String, dynamic> /*?*/ json) {
    if (json == null) {
      return null;
    }

    return SubStatement(
      actor: Agent.fromJson(json['actor']),
      verb: Verb.fromJson(json['verb']),
      object: StatementTarget.toTarget(json['object']),
      result: Result.fromJson(json['result']),
      context: Context.fromJson(json['context']),
      timestamp: _readDate(json['timestamp']),
      attachments: Attachment.listFromJson(json['attachments']),
      voided: json['voided'],
    );
  }

  @override
  Map<String, dynamic> toJson([Version version]) {
    version ??= TinCanVersion.latest();

    return {
      'objectType': 'SubStatement',
      'actor': actor?.toJson(version),
      'verb': verb?.toJson(),
      'object': object?.toJson(version),
      // 'result': result.toJson(version),
      // 'context': result.to
    };
  }

  static DateTime _readDate(String date) {
    return (date == null) ? null : DateTime.tryParse(date);
  }
}
