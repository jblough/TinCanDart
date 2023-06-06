import 'dart:convert';

import 'package:test/test.dart';
import 'package:tincan/tincan.dart';

void main() {
  test("should read activity definition with choices", () {
    final statement = Statement.fromJson(json.decode(_json))!;

    expect(statement, isNotNull);
    expect(statement.actor, isNotNull);
    expect(statement.object, isNotNull);
    expect(statement.verb, isNotNull);
    final activity = statement.object as Activity;
    expect(activity.definition, isNotNull);
    expect(activity.definition?.extensions, isNotNull);
    expect(activity.definition?.choices, isNotNull);
    expect(activity.definition?.choices?.length, 4);
    final choice = activity.definition?.choices?.first;
    expect(choice?.description, {'en-US': 'Golf Example'});
    expect(choice?.id, 'golf');
  });
}

const _json = '''
{
    "actor": {
        "objectType": "Agent"
    },
    "verb": {
        "id": "http://adlnet.gov/expapi/verbs/answered",
        "display": {
            "en-US": "answered"
        }
    },
    "object": {
        "id": "http://adlnet.gov/expapi/activities/example",
        "definition": {
            "name": {
                "en-US": "Example Activity"
            },
            "description": {
                "en-US": "Example activity description"
            },
            "type": "http://adlnet.gov/expapi/activities/cmi.interaction",
            "interactionType": "choice",
            "choices": [
                {
                    "id": "golf",
                    "description": {
                        "en-US": "Golf Example"
                    }
                },
                {
                    "id": "facebook",
                    "description": {
                        "en-US": "Facebook App"
                    }
                },
                {
                    "id": "tetris",
                    "description": {
                        "en-US": "Tetris Example"
                    }
                },
                {
                    "id": "scrabble",
                    "description": {
                        "en-US": "Scrabble Example"
                    }
                }
            ]
        },
        "objectType": "Activity"
    }
}
''';
