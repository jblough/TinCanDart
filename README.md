## A Dart library of the Tin Can API

For more information about the Tin Can API visit:


http://tincanapi.com/

## Installation:

In your pubspec.yaml
```
dependencies:
  tincan: any
```


## Sample Usage:

In your code:
```dart
import 'package:tincan/tincan.dart';

final lrs = RemoteLRS(
      version: Version.V103,
      endpoint: 'https://my.lrs.provider,
      username: 'account key or user name',
      password: 'account secret or password',
    );

final statement = Statement(
  actor: Agent(
    mbox: 'mailto:person@doingsomething.com',
    name: 'Test Agent',
  ),
  verb: Verb(
    id: 'http://adlnet.gov/expapi/verbs/experienced',
    display: LanguageMap({'en-US': 'experienced'}),
  ),
  object: Activity(
    id: 'http://tincanapi.com/TinCanDart/Test/Unit/0',
    definition: ActivityDefinition(
      type: 'http://id.tincanapi.com/activitytype/unit-test',
      name: LanguageMap({'en-US': 'TinCanDart Tests: Unit 0'}),
      description: LanguageMap({
        'en-US': 'Unit test 0 in the test suite for the Tin Can Dart library.'
      }),
    ),
  ),
);

lrs.sendStatement(statement);
```

