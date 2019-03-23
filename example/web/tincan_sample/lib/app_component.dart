import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:tincan_sample/src/blocs/lrs_bloc.dart';

import 'src/counter/counter_component.dart';
import 'src/image_selection/image_selection_component.dart';
import 'src/stepper/stepper_component.dart';
import 'src/viewer/viewer_component.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
    selector: 'my-app',
    styleUrls: [
      'app_component.css',
      'package:angular_components/app_layout/layout.scss.css',
    ],
    templateUrl: 'app_component.html',
    directives: [
      CounterComponent,
      ImageSelectionComponent,
      StepperComponent,
      ViewerComponent,
      MaterialTabComponent,
      MaterialTabPanelComponent,
    ],
    providers: [materialProviders, LrsBloc])
class AppComponent implements OnInit {
  final LrsBloc _lrsBloc;

  AppComponent(this._lrsBloc);

  @override
  void ngOnInit() {
    // Set up a tab change listener to refresh the statements when the
    // ViewerComponent tab is selected
  }

  void tabChange() {
    print('tab changed');
    _lrsBloc.refreshStatements();
  }
}
