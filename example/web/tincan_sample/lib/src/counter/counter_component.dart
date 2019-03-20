import 'dart:math';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:tincan/tincan.dart';

@Component(
  selector: 'counter-component',
  styleUrls: ['counter_component.css'],
  templateUrl: 'counter_component.html',
  directives: [
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    NgFor,
    NgIf,
  ],
  providers: [],
)
class CounterComponent {
  int currentValue = 0;

  void increment() {
    currentValue++;
    _sendStatement();
  }

  Future<void> _sendStatement() async {
    // TODO - centralize xAPI operations into a class
    final lrs = RemoteLRS(
      endpoint: '...',
      username: '...',
      password: '...',
    );
    await lrs.saveStatement(
      Statement(
        actor: Agent(
            mbox: 'mailto:test-${Random.secure().nextInt(30000)}@example.com',
            name: 'Sample User'),
        verb: Verb(
            id: 'http://adlnet.gov/expapi/verbs/incremented',
            display: {'en-US': 'incremented'}),
        object: Activity(
          id: 'http://tincanapi.com/TinCanDart/example/counter',
          definition: ActivityDefinition(
            name: {'en-US': 'incrementing counter'},
          ),
        ),
      ),
    );
  }
}
