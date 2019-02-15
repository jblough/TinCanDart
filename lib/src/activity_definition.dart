import './extensions.dart';
import './interaction_component.dart';
import './interaction_type.dart';
import './language_map.dart';
import './validated_uri.dart';
import './versions.dart';

class ActivityDefinition {
  final LanguageMap name;
  final LanguageMap description;
  final ValidatedUri type;
  final ValidatedUri moreInfo;
  final Extensions extensions;
  final InteractionType interactionType;
  final List<String> correctResponsesPattern;
  final List<InteractionComponent> choices;
  final List<InteractionComponent> scale;
  final List<InteractionComponent> source;
  final List<InteractionComponent> target;
  final List<InteractionComponent> steps;

  ActivityDefinition({
    this.name,
    this.description,
    dynamic type,
    dynamic moreInfo,
    this.extensions,
    this.interactionType,
    this.correctResponsesPattern,
    this.choices,
    this.scale,
    this.source,
    this.target,
    this.steps,
  })  : this.type = ValidatedUri.fromString(type?.toString()),
        this.moreInfo = ValidatedUri.fromString(moreInfo?.toString());

  factory ActivityDefinition.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return ActivityDefinition(
      name: LanguageMap.fromJson(json['name']),
      description: LanguageMap.fromJson(json['description']),
      type: json['type'],
      moreInfo: json['moreInfo'],
      extensions: Extensions.fromJson(json['extensions']),
      interactionType: InteractionType.fromString(json['interactionType']),
      correctResponsesPattern: json['correctResponsesPattern'],
      choices: InteractionComponent.listFromJson(json['choices']),
      scale: InteractionComponent.listFromJson(json['scale']),
      source: InteractionComponent.listFromJson(json['source']),
      target: InteractionComponent.listFromJson(json['target']),
      steps: InteractionComponent.listFromJson(json['steps']),
    );
  }

  Map<String, dynamic> toJson({Version version, bool pretty}) {
    if (version == null) {
      version = TinCanVersion.latest();
    }

    final json = {
      'name': name.toJson(),
      'description': description.toJson(),
      'type': type?.toString(),
      'moreInfo': moreInfo?.toString(),
      'extensions': extensions?.toJson(),
      'interactionType': interactionType?.text,
      'correctResponsesPattern': correctResponsesPattern,
      'choices': choices?.map((choice) => choice.toJson())?.toList(),
      'scale': scale?.map((s) => s.toJson())?.toList(),
      'source': source?.map((s) => s.toJson())?.toList(),
      'target': target?.map((t) => t.toJson())?.toList(),
      'steps': steps?.map((s) => s.toJson())?.toList(),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }
}
