import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:tin_can/tin_can.dart';

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
