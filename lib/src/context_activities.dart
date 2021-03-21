import './activity.dart';
import './versions.dart';

class ContextActivities {
  /// Parent: an Activity with a direct relation to the Activity which is the Object of the Statement. In almost all cases there is only one sensible parent or none, not multiple. For example: a Statement about a quiz question would have the quiz as its parent Activity.
  final List<Activity>? parent;

  /// Grouping: an Activity with an indirect relation to the Activity which is the Object of the Statement. For example: a course that is part of a qualification. The course has several classes. The course relates to a class as the parent, the qualification relates to the class as the grouping.
  final List<Activity>? grouping;

  /// Other: a contextActivity that doesn't fit one of the other properties. For example: Anna studies a textbook for a biology exam. The Statement's Activity refers to the textbook, and the exam is a contextActivity of type other.
  final List<Activity>? other;

  /// Category: an Activity used to categorize the Statement. "Tags" would be a synonym. Category SHOULD be used to indicate a profile of xAPI behaviors, as well as other categorizations. For example: Anna attempts a biology exam, and the Statement is tracked using the cmi5 profile. The Statement's Activity refers to the exam, and the category is the cmi5 profile.
  final List<Activity>? category;

  ContextActivities({
    this.parent,
    this.grouping,
    this.other,
    this.category,
  });

  static ContextActivities? fromJson(Map<String, dynamic>? json) {
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

  Map<String, dynamic> toJson([Version? version]) {
    version ??= TinCanVersion.latest();

    final json = {
      'parent': parent?.map((a) => a.toJson(version)).toList(),
      'grouping': grouping?.map((a) => a.toJson(version)).toList(),
      'other': other?.map((a) => a.toJson(version)).toList(),
      'category': category?.map((a) => a.toJson(version)).toList(),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
