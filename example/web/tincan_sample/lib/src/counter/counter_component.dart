import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:tincan/tincan.dart';
import 'package:tincan_sample/src/blocs/lrs_bloc.dart';

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
)
class CounterComponent {
  final LrsBloc _lrsBloc;

  CounterComponent(this._lrsBloc);

  int currentValue = 0;

  void increment() {
    currentValue++;
    _sendStatement();
  }

  Future<void> _sendStatement() async {
    _lrsBloc.recordStatement(
      Statement(
        verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/incremented',
          display: {'en-US': 'incremented'},
        ),
        result: Result(
          response: currentValue.toString(),
        ),
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
