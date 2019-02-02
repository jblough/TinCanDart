import 'package:TinCanDart/src/activity_definition.dart';
import 'package:TinCanDart/src/parsing_utils.dart';
import 'package:TinCanDart/src/statement_target.dart';
import 'package:TinCanDart/src/versions.dart';

class Activity extends StatementTarget {
  final Uri id;
  final ActivityDefinition definition;

  Activity({this.id, this.definition});

  factory Activity.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Activity(
      id: ParsingUtils.toUri(json['id']),
      definition: ActivityDefinition.fromJson(json['definition']),
    );
  }

  static List<Activity> listFromJson(List<Map<String, dynamic>> list) {
    if (list == null || list.isEmpty) {
      return null;
    }

    List<Activity> activities = [];
    list.forEach((json) {
      activities.add(Activity.fromJson(json));
    });

    return activities;
  }

  @override
  Map<String, dynamic> toJson(Version version) {
    return {
      'objectType': 'Activity',
      'id': id?.toString(),
      'definition': definition?.toJson(version: version),
    };
  }
}
