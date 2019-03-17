import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'image-selection-component',
  styleUrls: ['image_selection_component.css'],
  templateUrl: 'image_selection_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    MaterialButtonComponent,
    NgFor,
    NgIf,
  ],
  providers: [],
)
class ImageSelectionComponent {
  void select(image) {
    print(image);
  }
}
