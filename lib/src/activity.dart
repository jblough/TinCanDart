import './activity_definition.dart';
import './statement_target.dart';
import './validated_uri.dart';
import './versions.dart';

class Activity extends StatementTarget {
  final ValidatedUri? id;
  final ActivityDefinition? definition;

  Activity({
    dynamic id,
    this.definition,
  }) : id = ValidatedUri.fromString(id?.toString());

  static Activity? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return Activity(
      id: json['id'],
      definition: ActivityDefinition.fromJson(json['definition']),
    );
  }

  static List<Activity>? listFromJson(List<dynamic>? list) {
    if (list == null) {
      return null;
    }
    final activities = <Activity>[];
    for (final json in list) {
      final activity = Activity.fromJson(json);
      if (activity != null) {
        activities.add(activity);
      }
    }
    return activities;
  }

  @override
  Map<String, dynamic> toJson([Version? version]) {
    version ??= TinCanVersion.latest();

    final json = {
      'objectType': 'Activity',
      'id': id?.toString(),
      'definition': definition?.toJson(version: version),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
