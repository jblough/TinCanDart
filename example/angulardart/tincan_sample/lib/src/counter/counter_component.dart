import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

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

  void _sendStatement() {}
}
