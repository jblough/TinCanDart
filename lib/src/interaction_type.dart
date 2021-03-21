class InteractionType {
  final String? text;

  InteractionType({this.text});

  static InteractionType? fromString(String? text) {
    if (text == null) {
      return null;
    }

    return InteractionType(text: text);
  }
}
