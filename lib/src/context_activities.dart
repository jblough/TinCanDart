import './activity.dart';
import './versions.dart';

class ContextActivities {
  final List<Activity> parent;
  final List<Activity> grouping;
  final List<Activity> other;
  final List<Activity> category;

  ContextActivities({
    this.parent,
    this.grouping,
    this.other,
    this.category,
  });

  factory ContextActivities.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return ContextActivities(
      parent: Activity.listFromJson(json['parent']),
      grouping: Activity.listFromJson(json['grouping']),
      other: Activity.listFromJson(json['other']),
      category: Activity.listFromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson(Version version) {
    final json = {
      'parent': parent?.map((a) => a.toJson(version))?.toList(),
      'grouping': grouping?.map((a) => a.toJson(version))?.toList(),
      'other': other?.map((a) => a.toJson(version))?.toList(),
      'category': category?.map((a) => a.toJson(version))?.toList(),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
