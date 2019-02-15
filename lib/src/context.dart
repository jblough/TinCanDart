import './agent.dart';
import './context_activities.dart';
import './extensions.dart';
import './statement_ref.dart';
import './versions.dart';

class Context {
  final String registration; // UUID
  final Agent instructor;
  final Agent team;
  final ContextActivities contextActivities;
  final String revision;
  final String platform;
  final String language;
  final StatementRef statement;
  final Extensions extensions;

  Context({
    this.registration,
    this.instructor,
    this.team,
    this.contextActivities,
    this.revision,
    this.platform,
    this.language,
    this.statement,
    this.extensions,
  });

  factory Context.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Context(
      registration: json['registration'],
      instructor: Agent.fromJson(json['instructor']),
      team: Agent.fromJson(json['team']),
      contextActivities: ContextActivities.fromJson(json['contextActivities']),
      revision: json['revision'],
      platform: json['platform'],
      language: json['language'],
      statement: StatementRef.fromJson(json['statement']),
      extensions: Extensions.fromJson(json['extensions']),
    );
  }

  Map<String, dynamic> toJson(Version version) {
    final json = {
      'registration': registration,
      'instructor': instructor?.toJson(version),
      'team': team?.toJson(version),
      'contextActivities': contextActivities?.toJson(version),
      'revision': revision,
      'platform': platform,
      'language': language,
      'statement': statement?.toJson(version),
      'extensions': extensions?.toJson(),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
