import './language_map.dart';

class InteractionComponent {
  final String id;
  final LanguageMap description;

  InteractionComponent({this.id, this.description});

  factory InteractionComponent.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return InteractionComponent(
      id: json['id'],
      description: LanguageMap.fromJson(json['description']),
    );
  }

  static List<InteractionComponent> listFromJson(
      List<Map<String, dynamic>> list) {
    if (list == null || list.isEmpty) {
      return null;
    }

    List<InteractionComponent> components = [];
    list.forEach((json) {
      components.add(InteractionComponent.fromJson(json));
    });

    return components;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description?.toJson(),
    };
  }
}
