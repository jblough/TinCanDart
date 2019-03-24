import 'dart:typed_data';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:http/http.dart';
import 'package:tincan_sample/src/blocs/lrs_bloc.dart';

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
  providers: [Client],
)
class ImageSelectionComponent {
  final LrsBloc _lrsBloc;
  final Client _http;

  ImageSelectionComponent(this._lrsBloc, this._http);
  Future<void> select(image) async {
    print(image);
    // Pull image from href
    // Attach to statement
    final data = await _downloadImage(image);
    print('image size - ${data.length}');
    final statement = Statement(
      verb: Verb(
          id: 'http://adlnet.gov/expapi/verbs/selected',
          display: {'en-US': 'selected'}),
      object: Activity(
          id: 'http://tincanapi.com/TinCanDart/example/images',
          definition: ActivityDefinition(
            name: {'en-US': image},
          )),
      attachments: [
        Attachment(
            content: AttachmentContent.fromUint8List(data),
            display: {'en-US': image},
            description: {'en-US': 'A picture of $image'},
            contentType: "image/png",
            usageType: 'http://id.tincanapi.com/attachment/supporting_media'),
      ],
    );
    await _lrsBloc.recordStatement(statement);
  }

  Future<Uint8List> _downloadImage(String image) async {
    try {
      final response =
          await _http.get('http://localhost:8080/images/$image.png');
      return response.bodyBytes;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic e) {
    print(e); // for demo purposes only
    return Exception('Server error; cause: $e');
  }
}
