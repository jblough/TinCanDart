import 'dart:async';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_dialog/material_dialog.dart';
import 'package:tincan_sample/src/blocs/lrs_bloc.dart';

@Component(
  selector: 'viewer-component',
  styleUrls: ['viewer_component.css'],
  templateUrl: 'viewer_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialButtonComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    MaterialExpansionPanel,
    MaterialExpansionPanelSet,
    AutoDismissDirective,
    AutoFocusDirective,
    MaterialDialogComponent,
    ModalComponent,
    NgFor,
    NgIf,
  ],
  providers: [overlayBindings],
)
class ViewerComponent implements OnInit, OnDestroy {
  final LrsBloc _lrsBloc;
  List<Statement> statements;
  StreamSubscription _subscription;
  final encoder = JsonEncoder.withIndent('  ');
  bool showAttachmentDialog = false;
  Attachment selectedAttachment;

  ViewerComponent(this._lrsBloc);

  @override
  void ngOnInit() {
    setUp();
  }

  setUp() async {
    try {
      _subscription = _lrsBloc.statements.listen(_displayStatements);
      statements = await _lrsBloc.statements.first;
      _subscription.onData((data) {
        statements = data;
      });
      _subscription.onDone(() {
        print('done!!!');
      });
      _subscription.onError((error) {
        print('Error - $error');
      });
    } catch (e) {
      print('Error - $e');
    }
  }

  @override
  ngOnDestroy() {
    _subscription?.cancel();
  }

  void _displayStatements(List<Statement> statements) {
    print('Displaying ${statements?.length} statements');
  }

  String statementShortSummary(Statement statement) {
    String who = '';
    if (statement.actor is Group) {
      who = 'Group: ${(statement.actor as Group).name}';
    } else {
      who = statement.actor.name;
    }

    String when = statement.timestamp?.toIso8601String() ?? '';

    return '$when $who';
  }

  String statementSummary(Statement statement) {
    String who = '';
    if (statement.actor is Group) {
      who = 'Group: ${(statement.actor as Group).name}';
    } else {
      who = statement.actor.name;
    }

    String verb = statement.verb.display?.values?.first;

    String when = statement.timestamp?.toIso8601String() ?? '';

    String what = '';
    if (statement.object is Activity) {
      what = (statement.object as Activity).definition?.name?.values?.first ??
          'Unknown';
    } else if (statement.object is StatementRef) {
      what = (statement.object as StatementRef).id ?? 'Unknown';
    }

    String result = '';

    if (statement.result != null) {
      if (statement.result.score != null) {
        result = '${statement.result.score?.raw ?? 0}%';
      } else {
        result = statement.result.response ?? 'Unknown';
      }
    }

    return '$when $who $verb $what $result';
  }

  String statementBody(Statement statement) {
    return encoder.convert(statement.toJson());
  }

  String attachmentTitle(Attachment attachment) {
    return attachment?.display?.values?.first ?? 'Unknown';
  }

  String attachmentSubtitle(Attachment attachment) {
    return attachment?.description?.values?.first ?? 'Unknown';
  }

  displayAttachment(attachment) {
    selectedAttachment = attachment;
    showAttachmentDialog = true;
  }

  String base64ImageData(attachment) {
    if (attachment == null) {
      return '';
    }

    return base64.encode(attachment.content.asList());
  }
}
