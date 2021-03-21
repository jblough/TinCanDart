class InteractionComponent {
  final String id;
  final Map<String, dynamic> description;

  InteractionComponent({this.id, this.description});

  static InteractionComponent /*?*/ fromJson(Map<String, dynamic> /*?*/ json) {
    if (json == null) {
      return null;
    }

    return InteractionComponent(
      id: json['id'],
      description: json['description'],
    );
  }

  static List<InteractionComponent /*!*/ > listFromJson(
      List<Map<String, dynamic>> /*?*/ list) {
    return list?.map((json) => InteractionComponent.fromJson(json))?.toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }
}
