import 'dart:convert';

import './agent.dart';
import './attachment.dart';
import './attachment_content.dart';
import './context.dart';
import './result.dart';
import './statement_target.dart';
import './verb.dart';
import './versions.dart';

class Statement {
  final String id; // Uuid
  final DateTime stored;
  final Agent authority;
  final Version version;

  final Agent actor;
  final Verb verb;
  final StatementTarget object;
  final Result result;
  final Context context;
  final DateTime timestamp;
  final List<Attachment> attachments;

  @deprecated
  final bool voided;

  Statement({
    this.id,
    this.stored,
    this.authority,
    this.version,
    this.actor,
    this.verb,
    this.object,
    this.result,
    this.context,
    this.timestamp,
    this.attachments,
    this.voided,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    return Statement(
      id: json['id'],
      stored: _readDate(json['stored']),
      authority: Agent.fromJson(json['authority']),
      version: TinCanVersion.fromJsonString(json['version']),
      actor: Agent.fromJson(json['actor']),
      verb: Verb.fromJson(json['verb']),

      // This can be StatementRef or SubStatement final StatementTarget object;
      object: StatementTarget.toTarget(json['object']),

      result: Result.fromJson(json['result']),
      context: Context.fromJson(json['context']),
      timestamp: _readDate(json['timestamp']),
      attachments: Attachment.listFromJson(json['attachments']),
      voided: json['voided'],
    );
  }

  Map<String, dynamic> toJson([Version version]) {
    version ??= TinCanVersion.latest();

    final json = {
      'id': id,
      'stored': stored?.toUtc()?.toIso8601String(),
      'authority': authority?.toJson(version),
      'version': TinCanVersion.toJsonString(version),
      'actor': actor?.toJson(version),
      'verb': verb?.toJson(),
      'object': object?.toJson(version),
      'result': result?.toJson(version),
      'context': context?.toJson(version),
      'timestamp': timestamp?.toUtc()?.toIso8601String(),
      'attachments': attachments?.map((a) => a.toJson(version))?.toList(),
    };

    // Remove all keys where the value is null
    json.removeWhere((key, value) => value == null);

    return json;
  }

  static DateTime _readDate(String date) {
    return (date == null) ? null : DateTime.tryParse(date);
  }

  Statement copyWith({
    String id, // Uuid
    DateTime stored,
    Agent authority,
    Version version,
    Agent actor,
    Verb verb,
    StatementTarget object,
    Result result,
    Context context,
    DateTime timestamp,
    List<Attachment> attachments,
    bool voided,
  }) {
    return Statement(
      id: id ?? this.id,
      stored: stored ?? this.stored,
      authority: authority ?? this.authority,
      version: version ?? this.version,
      actor: actor ?? this.actor,
      verb: verb ?? this.verb,
      object: object ?? this.object,
      result: result ?? this.result,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      attachments: attachments ?? this.attachments,
    );
  }

  static final _headerRegExp = RegExp(r'^(.*?): ?(.*?)$');

  static List<Statement> fromMixedMultipart(String boundary, dynamic body) {
    if (body == null) {
      return [];
    }

    final statements = <Statement>[];

    final reader = (body.runtimeType == String)
        ? _MixedReader(body.codeUnits, boundary: boundary)
        : _MixedReader(body, boundary: boundary);

    var line = reader.readNextLine(); // Boundary (or blank line)
    if (line.isEmpty || line == '\r\n') {
      line = reader.readNextLine(); // Boundary
    }

    // Read the headers
    Map<String, dynamic> headers = {};
    while (line.isNotEmpty && line != '\r\n') {
      line = reader.readNextLine(); // Headers
      final match = _headerRegExp.firstMatch(line);
      if (match != null) {
        headers[match[1]] = match[2];
      }
    }

    // Read the Statements
    int length = (headers['Content-Length'] == null)
        ? null
        : int.tryParse(headers['Content-Length']);
    final jsonData = (length != null)
        ? String.fromCharCodes(reader.readNextBinary(length))
        : reader.readNextLine();
    final Map<String, dynamic> jsonBody = json.decode(jsonData);
    if (jsonBody.containsKey('statements')) {
      final List jsonStatements = jsonBody['statements'];
      jsonStatements.forEach((jsonStatement) {
        var statement = Statement.fromJson(jsonStatement);
        if (statement != null) {
          statements.add(statement);
        }
      });
    } else {
      var statement = Statement.fromJson(jsonBody);
      if (statement != null) {
        statements.add(statement);
      }
    }

    // Read the attachments
    while (!reader.done()) {
      headers.clear();
      line = reader.readNextLine(); // Boundary
      while (!reader.done() && line.isNotEmpty && line != '\r\n') {
        line = reader.readNextLine(); // Headers
        final match = _headerRegExp.firstMatch(line);
        if (match != null) {
          headers[match[1]] = match[2];
        }
      }

      if (headers.isNotEmpty) {
        final hash = headers['X-Experience-API-Hash'];

        int length = (headers['Content-Length'] == null)
            ? null
            : int.tryParse(headers['Content-Length']);

        // If the length wasn't found as a header, try to get it from the statement
        if (length == null) {
          statements?.forEach((statement) {
            statement.attachments?.forEach((attachment) {
              if (attachment.sha2 == hash) {
                length = attachment.length;
              }
            });
          });
        }
        final bytes = reader.readNextBinary(length);
        statements?.forEach((statement) {
          statement.attachments?.forEach((attachment) {
            if (attachment.sha2 == hash && attachment.content == null) {
              attachment.content = AttachmentContent.fromList(bytes);
            }
          });
        });
      }
    }

    /*
    Sample data:
--fd8185b9145b4646bafa518a41d735e3
Content-Length:39315
Content-Type:application/json; charset=UTF-8

{"statements":[{"id":"b1a21cd9-d1ed-4ded-87cb-fa9f40bb272b","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T01:20:26.934Z","stored":"2019-02-08T01:20:26.934Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"090880de-0e69-4989-ae0c-0492c89320e5","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T01:17:56.780Z","stored":"2019-02-08T01:17:56.780Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"5c905738-6280-4dda-ac12-86816c8f38a8","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T01:17:21.558Z","stored":"2019-02-08T01:17:21.558Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"7ba7cb90-738c-4afa-b6d0-b63bad27d5db","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T01:16:09.772Z","stored":"2019-02-08T01:16:09.772Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"7f4a239c-e671-44a1-a028-591a18597b74","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:58:02.010Z","stored":"2019-02-08T00:58:02.010Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"266978c9-e2ed-49ed-af8f-ceba77a1bd26","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:57:33.955Z","stored":"2019-02-08T00:57:33.955Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"933a20ba-b6c3-46f0-9487-9250ffa3ec87","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:56:51.186Z","stored":"2019-02-08T00:56:51.186Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"c69cab85-6c62-4504-abf6-f84a80628d86","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:53:23.038Z","stored":"2019-02-08T00:53:23.039Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"af4c8f74-b9e5-4128-a1f2-b96aea9cb434","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:53:23.038Z","stored":"2019-02-08T00:53:23.038Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"b29aff40-84cb-4085-9f72-b0a0186279fb","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:53:03.686Z","stored":"2019-02-08T00:53:03.687Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"c004d35e-a7cf-47b8-b199-8bb25a73f239","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:53:03.686Z","stored":"2019-02-08T00:53:03.686Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"e7400fed-84b6-48c7-a1d0-80806023bb4b","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:51:33.354Z","stored":"2019-02-08T00:51:33.355Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"2e22b54a-4824-4180-aba9-2f70cb2fa202","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:51:33.354Z","stored":"2019-02-08T00:51:33.354Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"dc74962c-3019-4f1c-8586-878e1b04410f","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:47:52.957Z","stored":"2019-02-08T00:47:52.957Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"},{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display 2"},"description":{"en-US":"Test Description 2"},"contentType":"text/plain","length":13,"sha2":"ed12932f3ef94c0792fbc55263968006e867e522cf9faa88274340a2671d4441"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"c22eaded-e8a9-41da-9eb9-638774a488ba","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:47:38.249Z","stored":"2019-02-08T00:47:38.249Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"},{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display 2"},"description":{"en-US":"Test Description 2"},"contentType":"text/plain","length":13,"sha2":"ed12932f3ef94c0792fbc55263968006e867e522cf9faa88274340a2671d4441"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"2cfcf570-b946-408f-a8d9-e926df2317eb","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:45:43.924Z","stored":"2019-02-08T00:45:43.924Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"ac970158-2aba-4209-b5d8-942d1b449dff","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:45:11.802Z","stored":"2019-02-08T00:45:11.802Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"370607b0-db1c-45e9-9393-f4d65f6469f3","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:44:01.658Z","stored":"2019-02-08T00:44:01.658Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"fcc7c756-743e-4f6e-8d91-ea7bb0cbcb22","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:43:35.748Z","stored":"2019-02-08T00:43:35.748Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"3de0f6ab-1b9d-4f62-97fc-375a71580205","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-08T00:37:53.580Z","stored":"2019-02-08T00:37:53.580Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"7675b013-4269-40bd-ac89-d5f530bca507","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T22:03:06.349Z","stored":"2019-02-07T22:03:06.349Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"b1797d17-d358-46aa-92ae-ddc1b9641bef","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:58:57.178Z","stored":"2019-02-07T21:58:57.178Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"5ec352c4-6874-4062-89d1-04d4ca9559c7","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:58:08.947Z","stored":"2019-02-07T21:58:08.947Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"05d9d4d6-4e04-4acf-a171-e46825c0a400","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:57:35.669Z","stored":"2019-02-07T21:57:35.669Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"78d715c4-53cd-47ae-b5d0-56f763bae3a8","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:56:32.745Z","stored":"2019-02-07T21:56:32.745Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"037410a4-69a1-4892-bb32-59f49451e0b0","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:54:50.614Z","stored":"2019-02-07T21:54:50.614Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"a57136c6-33ae-44bc-8dfb-e2efc3bf7d3b","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:54:20.799Z","stored":"2019-02-07T21:54:20.799Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"a3f1872c-36bd-4eaf-9a4c-03470e71f9cc","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:53:55.543Z","stored":"2019-02-07T21:53:55.543Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"9438e3c0-dac1-46d9-9b7b-1c13f3237271","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:52:09.556Z","stored":"2019-02-07T21:52:09.556Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"7d8201bf-9cff-4a80-8906-e2639deb0518","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:50:40.079Z","stored":"2019-02-07T21:50:40.079Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"44e37259-e650-4359-9fd6-ce2f09b27667","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:49:08.881Z","stored":"2019-02-07T21:49:08.881Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"059b16c3-2bed-4532-ab86-2f53500d8cbb","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:48:30.163Z","stored":"2019-02-07T21:48:30.163Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"38769243-f5b3-472c-83ae-d8cf8ce76b82","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-07T21:40:45.153Z","stored":"2019-02-07T21:40:45.153Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media/","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"267576b7-668e-475c-96a4-be9134167efe","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-05T00:42:49.280Z","stored":"2019-02-05T00:42:49.280Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","attachments":[{"usageType":"http://id.tincanapi.com/attachment/supporting_media","display":{"en-US":"Test Display"},"description":{"en-US":"Test Description"},"contentType":"application/octet-stream","length":11,"sha2":"b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"}],"object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test"},"objectType":"Activity"}},{"id":"b13166dd-fac0-483f-89a4-b9646ba7e124","actor":{"objectType":"Agent","mbox":"mailto:tincanjs-test-tincan+1549229795912@tincanapi.com"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en":"experienced"}},"timestamp":"2019-02-03T21:36:38.597Z","stored":"2019-02-03T21:36:38.789Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","object":{"id":"http://tincanapi.com/TinCanJS/Test/TinCan.LRS-browser","objectType":"Activity"}},{"id":"2086d0d9-486e-40a9-9289-17841dc5fba2","actor":{"objectType":"Agent","mbox":"mailto:tincanjs-test-tincan+1549229795912@tincanapi.com"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"und":"experienced"}},"timestamp":"2019-02-03T21:36:37.797Z","stored":"2019-02-03T21:36:38.017Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","object":{"id":"http://tincanapi.com/TinCanJS/Test/TinCan.LRS-browser","objectType":"Activity"}},{"id":"84680a41-01a3-42d1-af70-42939a11b76d","actor":{"objectType":"Agent","mbox":"mailto:tincanjs-test-tincan+1549229795912@tincanapi.com"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"und":"experienced"}},"timestamp":"2019-02-03T21:36:36.975Z","stored":"2019-02-03T21:36:37.114Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","object":{"id":"http://tincanapi.com/TinCanJS/Test/TinCan.LRS-browser","objectType":"Activity"}},{"id":"9f388843-66b8-40a4-babc-7240de2f57d9","actor":{"objectType":"Agent","mbox":"mailto:tincanjs-test-tincan+1549229795912@tincanapi.com"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"und":"experienced"}},"timestamp":"2019-02-03T21:36:35.963Z","stored":"2019-02-03T21:36:36.220Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","object":{"id":"http://tincanapi.com/TinCanJS/Test/TinCan.LRS-browser","objectType":"Activity"}},{"id":"d2d6f033-1495-4bc4-a8f1-49d01a290fa7","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"context":{"registration":"b961e2fd-e513-4fb0-b0c3-936f3962f6fc","contextActivities":{"parent":[{"id":"http://tincanapi.com/TinCanJava/Test/","definition":{"name":{"en-US":"TinCanJavava Tests"},"description":{"en-US":"Unit test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test-suite/","moreInfo":"http://rusticisoftware.github.io/TinCanJava/"},"objectType":"Activity"}]},"statement":{"id":"191ba4bd-7a06-4563-b915-89c1f41e4f78","objectType":"StatementRef"}},"timestamp":"2019-02-03T21:11:44.334Z","stored":"2019-02-03T21:11:44.335Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","object":{"id":"http://tincanapi.com/TinCanJava/Test/Unit/0/","definition":{"name":{"en-US":"TinCanJava Tests: Unit 0"},"description":{"en-US":"Unit test 0 in the test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test/"},"objectType":"Activity"}},{"id":"428fcb5c-e16d-475e-b308-c1e618b72b09","actor":{"objectType":"Agent","mbox":"mailto:tincanjava@tincanapi.com","name":"Test Agent"},"verb":{"id":"http://adlnet.gov/expapi/verbs/experienced","display":{"en-US":"experienced"}},"timestamp":"2019-02-03T21:11:44.334Z","stored":"2019-02-03T21:11:44.334Z","authority":{"objectType":"Agent","account":{"homePage":"http://cloud.scorm.com","name":"9L2Q71kgCTHPMGgqG-8"},"name":"Unnamed Account"},"version":"1.0.0","object":{"id":"http://tincanapi.com/TinCanJava/Test/","definition":{"name":{"en-US":"TinCanJavava Tests"},"description":{"en-US":"Unit test suite for the Tin Can Java library."},"type":"http://id.tincanapi.com/activitytype/unit-test-suite/","moreInfo":"http://rusticisoftware.github.io/TinCanJava/"},"objectType":"Activity"}}],"more":""}
--fd8185b9145b4646bafa518a41d735e3
X-Experience-API-Hash:b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9
Content-Transfer-Encoding:binary
Content-Length:11
Content-Type:application/octet-stream

hello world
--fd8185b9145b4646bafa518a41d735e3
X-Experience-API-Hash:ed12932f3ef94c0792fbc55263968006e867e522cf9faa88274340a2671d4441
Content-Transfer-Encoding:binary
Content-Length:13
Content-Type:text/plain

hello world 2
--fd8185b9145b4646bafa518a41d735e3--
     */
    return statements;
  }
}

class _MixedReader {
  final List<int> bytes;
  final String boundary;
  final int length;
  int _currentPosition = 0;

  _MixedReader(this.bytes, {this.boundary}) : this.length = bytes.length;

  bool done() => _currentPosition >= this.length;

  String readNextLine() {
    // Read up to next '\r\n';
    final buffer = StringBuffer();

    while (!buffer.toString().endsWith('\r\n') && !done()) {
      buffer.writeCharCode(bytes[_currentPosition++]);
    }

    // Remove the trailing newline characters
    return buffer.toString().replaceAll('\r\n', '');
  }

  List<int> readNextBinary(int bytesToRead) {
    // If value passed in was null, read until the remainder of the content
    bytesToRead ??= length - _currentPosition - (boundary?.length ?? 0 + 2);

    // Read next 'bytes to read' number of bytes into buffer and return
    final buffer = bytes
        .sublist(_currentPosition, _currentPosition + bytesToRead)
        .toList();
    // Add 2 characters for the \r\n after the binary part
    _currentPosition += bytesToRead + 2;
    return buffer;
  }
}
