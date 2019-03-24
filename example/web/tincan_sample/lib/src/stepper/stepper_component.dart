import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_stepper/material_step.dart';
import 'package:angular_components/material_stepper/material_stepper.dart';
import 'package:angular_components/model/action/async_action.dart';
import 'package:angular_components/utils/angular/scroll_host/angular_2.dart';
import 'package:tincan_sample/src/blocs/lrs_bloc.dart';

@Component(
  selector: 'stepper-component',
  styleUrls: ['stepper_component.css'],
  templateUrl: 'stepper_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    MaterialInputComponent,
    materialInputDirectives,
    MaterialStepperComponent,
    StepDirective,
    NgFor,
    NgIf,
  ],
  providers: [scrollHostProviders],
)
class StepperComponent {
  final LrsBloc _lrsBloc;

  String firstName = '';
  String lastName = '';
  String number = '';
  DateTime _start;

  StepperComponent(this._lrsBloc);

  void focused() {
    _start ??= DateTime.now();
  }

  void submit(AsyncAction<bool> action) {
    /*action.cancelIf(Future.delayed(const Duration(seconds: 1), () {
      // Don't cancel
      return false;
    }));*/
    _sendStatements();
  }

  bool canSubmit() {
    return firstName.isNotEmpty == true &&
        lastName.isNotEmpty == true &&
        int.tryParse(number) != null;
  }

  Future<void> _sendStatements() async {
    /*
      Records to record:
        completed
        answered step 1
        answered step 2
        answered step 3
     */

    final finish = DateTime.now();

    // TODO - Figure out how to get Browser/OS information for context data

    // Completed statement
    var statement = Statement(
      result: Result(duration: TinCanDuration.fromDiff(_start, finish)),
      verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/completed',
          display: {'en-US': 'completed'}),
      object: Activity(
        id: 'http://example.com/TinCanDart/stepper',
        definition: ActivityDefinition(
          name: {'en-US': 'Stepper'},
        ),
      ),
    );

    _lrsBloc.recordStatement(statement);

    // Answered step 1 statement
    statement = Statement(
      verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/answered',
          display: {'en-US': 'answered'}),
      result: Result(response: this.firstName),
      object: Activity(
        id: 'http://example.com/TinCanDart/stepper/one',
        definition: ActivityDefinition(
          name: {'en-US': 'Step 1'},
        ),
      ),
    );

    _lrsBloc.recordStatement(statement);

    // Answered step 2 statement
    statement = Statement(
      verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/answered',
          display: {'en-US': 'answered'}),
      result: Result(response: this.lastName),
      object: Activity(
        id: 'http://example.com/TinCanDart/stepper/two',
        definition: ActivityDefinition(
          name: {'en-US': 'Step 2'},
        ),
      ),
    );

    _lrsBloc.recordStatement(statement);

    // Answered step 3 statement
    statement = Statement(
      verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/answered',
          display: {'en-US': 'answered'}),
      result: Result(response: this.number),
      object: Activity(
        id: 'http://example.com/TinCanDart/stepper/three',
        definition: ActivityDefinition(
          name: {'en-US': 'Step 3'},
        ),
      ),
    );

    _lrsBloc.recordStatement(statement);
  }
}
