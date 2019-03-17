import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_stepper/material_step.dart';
import 'package:angular_components/material_stepper/material_stepper.dart';
import 'package:angular_components/utils/angular/scroll_host/angular_2.dart';

@Component(
  selector: 'stepper-component',
  styleUrls: ['stepper_component.css'],
  templateUrl: 'stepper_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    MaterialStepperComponent,
    StepDirective,
    NgFor,
    NgIf,
  ],
  providers: [scrollHostProviders],
)
class StepperComponent {
  void submit() {
    print('submitting...');
  }
}
