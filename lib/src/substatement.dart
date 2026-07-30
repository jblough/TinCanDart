import './agent.dart';
import './attachment.dart';
import './context.dart';
import './result.dart';
import './statement_target.dart';
import './verb.dart';
import './versions.dart';

class SubStatement extends StatementTarget {
  final Agent? actor;
  final Verb? verb;
  final StatementTarget? object;
  final Result? result;
  final Context? context;
  final DateTime? timestamp;
  final List<Attachment>? attachments;

  /// https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#substatements
  SubStatement({
    this.actor,
    this.verb,
    this.object,
    this.result,
    this.context,
    this.timestamp,
    this.attachments,
  });

  static SubStatement? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return SubStatement(
      actor: Agent.fromJson(json['actor'] as Map<String, dynamic>?),
      verb: Verb.fromJson(json['verb'] as Map<String, dynamic>?),
      object: StatementTarget.toTarget(json['object'] as Map<String, dynamic>?),
      result: Result.fromJson(json['result'] as Map<String, dynamic>?),
      context: Context.fromJson(json['context'] as Map<String, dynamic>?),
      timestamp: _readDate(json['timestamp'] as String?),
      attachments: Attachment.listFromJson(json['attachments'] as List<dynamic>?),
    );
  }

  @override
  Map<String, dynamic> toJson([Version? version]) {
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

  static DateTime? _readDate(String? date) {
    return (date == null) ? null : DateTime.tryParse(date);
  }
}
