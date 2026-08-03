import './activity.dart';
import './agent.dart';
import './group.dart';
import './statement_ref.dart';
import './substatement.dart';
import './versions.dart';

abstract class StatementTarget {
  Map<String, dynamic> toJson([Version? version]);

  static StatementTarget? toTarget(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    final type = json['objectType'];
    return switch (type) {
      'Group' => Group.fromJson(json),
      'Agent' => Agent.fromJson(json),
      'StatementRef' => StatementRef.fromJson(json),
      'SubStatement' => SubStatement.fromJson(json),
      _ => Activity.fromJson(json)
    };
  }
}
