import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:tincan/tincan.dart';
import 'package:uuid/uuid.dart';

void compareStatements(Statement statement1, Statement statement2) {
  // Convert both statements to JSON maps
  final json1 = statement1.toJson(TinCanVersion.latest());
  final json2 = statement2.toJson(TinCanVersion.latest());

  // If either of the statements doesn't have the id defined, remove it for the comparison
  if (statement1.id == null || statement2.id == null) {
    json1.remove('id');
    json2.remove('id');
  }

  // Compare the maps
  expect(json1, json2);
}

void main() {
  var endpoint;
  var username;
  var password;

  late LRS lrs;
  Agent? agent;
  Verb? verb;
  Activity? activity;
  Activity? parent;
  StatementRef? statementRef;
  Context? context;
  Score score;
  Result? result;
  SubStatement? subStatement;
  Attachment? attachment1;
  Attachment? attachment2;
  Attachment? attachment3;

  setUpAll(() {
    final config = File('./test/lrs.properties');
    final lines = config.readAsLinesSync();
    lines.forEach((line) {
      final parts = line.split('=');
      switch (parts[0].toLowerCase()) {
        case 'endpoint':
          endpoint = parts[1];
          break;
        case 'username':
          username = parts[1];
          break;
        case 'password':
          password = parts[1];
          break;
        default:
          print("Unrecognized variable : ${parts[0]}");
      }
    });

    agent = Agent(
      mbox: 'mailto:tincandart@tincanapi.com',
      name: 'Test Agent',
    );

    verb = Verb(
      id: 'http://adlnet.gov/expapi/verbs/experienced',
      display: {'en-US': 'experienced'},
    );

    activity = Activity(
      id: 'http://tincanapi.com/TinCanDart/Test/Unit/0',
      definition: ActivityDefinition(
        type: 'http://id.tincanapi.com/activitytype/unit-test',
        name: {'en-US': 'TinCanDart Tests: Unit 0'},
        description: {
          'en-US': 'Unit test 0 in the test suite for the Tin Can Dart library.'
        },
      ),
    );

    parent = Activity(
      id: 'http://tincanapi.com/TinCanDart/Test',
      definition: ActivityDefinition(
          type: 'http://id.tincanapi.com/activitytype/unit-test-suite',
          moreInfo: 'http://rusticisoftware.github.io/TinCanDart/',
          name: {
            'en-US': 'TinCanDart Tests'
          },
          description: {
            'en-US': 'Unit test suite for the Tin Can Dart library.'
          }),
    );

    statementRef = StatementRef(id: Uuid().v4().toString());

    context = Context(
      registration: Uuid().v4().toString(),
      statement: statementRef,
      contextActivities: ContextActivities(parent: [parent]),
    );

    score = Score(
      raw: 97.0,
      scaled: 0.97,
      max: 100.0,
      min: 0.0,
    );

    result = Result(
      score: score,
      success: true,
      completion: true,
      duration: TinCanDuration.fromDuration(
        Duration(
          hours: 1,
          minutes: 2,
          seconds: 16,
          milliseconds: 43,
        ),
      ),
    );

    subStatement = SubStatement(
      actor: agent,
      verb: verb,
      object: parent,
    );

    attachment1 = Attachment(
        content: AttachmentContent.fromString('hello world'),
        contentType: "application/octet-stream",
        description: {'en-US': 'Test Description'},
        display: {'en-US': 'Test Display'},
        usageType: 'http://id.tincanapi.com/attachment/supporting_media');

    attachment2 = Attachment(
      content: AttachmentContent.fromString('hello world 2'),
      contentType: "text/plain",
      description: {'en-US': 'Test Description 2'},
      display: {'en-US': 'Test Display 2'},
      usageType: 'http://id.tincanapi.com/attachment/supporting_media',
    );

    attachment3 = Attachment(
      content: AttachmentContent.fromList(
          File('./test/image.jpg').readAsBytesSync()),
      contentType: "image/jpeg",
      description: {'en-US': 'Test Description 3'},
      display: {'en-US': 'Test Display 3'},
      usageType: 'http://id.tincanapi.com/attachment/supporting_media',
    );
  });

  setUp(() {
    lrs = RemoteLRS(
      endpoint: endpoint,
      username: username,
      password: password,
    );
  });

  test("should retrieve about", () async {
    final about = await lrs.about();
    expect(about.success, isTrue);
  });

  test("endpoint", () {
    var obj = RemoteLRS();
    expect(obj.endpoint, isNull);

    String strURL = "http://tincanapi.com/test/TinCanDart";
    obj = RemoteLRS(endpoint: strURL);
    expect(obj.endpoint.toString(), '$strURL/');
  });

  test("should set username", () {
    final lrs = RemoteLRS(username: 'test', password: 'pass');
    expect(lrs.auth, 'Basic dGVzdDpwYXNz');
  });

  test("should set password", () {
    final lrs = RemoteLRS(username: 'user', password: 'test');
    expect(lrs.auth, 'Basic dXNlcjp0ZXN0');
  });

  test("should calculate basic auth", () {
    final obj = RemoteLRS(username: "user", password: "pass");
    expect(obj.auth, "Basic dXNlcjpwYXNz");
  });

  test("should fail on about", () async {
    final obj = RemoteLRS(
        version: Version.V100,
        endpoint: 'https://cloud.scorm.com/lrs/1Y32ZYODBD/sandbox/');
    final response = await obj.about();
    final data = response.data;
    expect(response.success, isTrue);
    expect(data, isNotNull);
  });

  test("about should fail", () async {
    final obj = RemoteLRS(
        version: Version.V100,
        endpoint: 'http://cloud.scorm.com/tc/3TQLAI9/sandbox/');
    final response = await obj.about();
    final data = response.data;
    final error = response.errMsg;
    expect(response.success, isFalse);
    expect(data, isNull);
    expect(error, isNotNull);
  });

  test("should save statement", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
    );

    expect(statement.id, isNull);
    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    compareStatements(response.data!, statement);
  });

  test("should save statement with id", () async {
    final statement = Statement(
      id: Uuid().v4().toString(),
      timestamp: DateTime.now(),
      actor: agent,
      verb: verb,
      object: activity,
    );

    final originalId = statement.id;
    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    expect(response.data!.id, originalId);
    compareStatements(response.data!, statement);
  });

  test("should save statement with context", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      context: context,
    );

    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    compareStatements(response.data!, statement);
  });

  test("should save statement with result", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      context: context,
      result: result,
    );

    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    compareStatements(response.data!, statement);
  });

  test("should save statement with StatementRef", () async {
    final statement = Statement(
      id: Uuid().v4().toString(),
      timestamp: DateTime.now(),
      actor: agent,
      verb: verb,
      object: statementRef,
    );

    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    compareStatements(response.data!, statement);
  });

  test("should save statement with substatement", () async {
    final statement = Statement(
      id: Uuid().v4().toString(),
      timestamp: DateTime.now(),
      actor: agent,
      verb: verb,
      object: subStatement,
    );

    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    compareStatements(response.data!, statement);
  });

  test("should save statements", () async {
    final statement1 = Statement(
      actor: agent,
      verb: verb,
      object: parent,
    );

    final statement2 = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      context: context,
    );

    final statements = [statement1, statement2];

    final response = await lrs.saveStatements(statements);
    expect(response.success, isTrue);

    final s1 = response.data!.statements![0]!;
    final s2 = response.data!.statements![1]!;

    expect(s1.id, isNotNull);
    expect(s2.id, isNotNull);

    expect(s1.actor, agent);
    expect(s1.verb, verb);
    expect(s1.object, parent);

    expect(s2.actor, agent);
    expect(s2.verb, verb);
    expect(s2.object, activity);
    expect(s2.context, context);
  });

  test("should retrieve statement", () async {
    final statement = Statement(
      id: Uuid().v4().toString(),
      timestamp: DateTime.now(),
      actor: agent,
      verb: verb,
      object: activity,
      context: context,
      result: result,
    );

    final saveResponse = await lrs.saveStatement(statement);
    expect(saveResponse.success, isTrue);

    final getResponse = await lrs.retrieveStatement(saveResponse.data!.id);
    expect(getResponse.success, isTrue);
  });

  test("should query statements", () async {
    final query = StatementsQuery(
      agent: agent,
      verbID: verb!.id,
      activityID: parent!.id,
      relatedActivities: true,
      relatedAgents: true,
      format: QueryResultFormat.IDS,
      limit: 10,
    );

    final response = await lrs.queryStatements(query);
    expect(response.success, isTrue);
  });

  test("should get more statements", () async {
    final query = StatementsQuery(
      format: QueryResultFormat.IDS,
      limit: 2,
    );

    final response = await lrs.queryStatements(query);
    expect(response.success, isTrue);
    expect(response.data!.moreUrl, isNotNull);

    final moreResponse = (await lrs.moreStatements(response.data!.moreUrl))!;
    expect(moreResponse.success, isTrue);
  });

  test("should retrieve state ids", () async {
    final response = await lrs.retrieveStateIds(activity, agent);
    expect(response.success, isTrue);
  });

  test("should retrieve state", () async {
    final clear = await lrs.clearState(activity, agent);
    expect(clear.success, isTrue);

    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
      content: AttachmentContent.fromString('Test value'),
    );

    final save = await lrs.saveState(doc);
    expect(save.success, isTrue);

    final stateResponse = await lrs.retrieveState('test', activity, agent);
    print('state attachment - "${stateResponse.data!.content!.asString()}"');
    expect(stateResponse.success, isTrue);
    expect(
        stateResponse.data!.etag, 'c140f82cb70e3884ad729b5055b7eaa81c795f1f');
  });

  test("should save state", () async {
    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
      content: AttachmentContent.fromString('Test value'),
    );

    final save = await lrs.saveState(doc);
    print(save.errMsg);
    expect(save.success, isTrue);
  });

  test("should overwrite state", () async {
    final clear = await lrs.clearState(activity, agent);
    expect(clear.success, isTrue);

    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
      content: AttachmentContent.fromString('Test value'),
    );

    final save = await lrs.saveState(doc);
    expect(save.success, isTrue);

    final retrieve = await lrs.retrieveState('test', activity, agent);
    print(retrieve.data!.toJson());
    expect(retrieve.success, isTrue);

    final doc2 = StateDocument(
      id: 'testing',
      activity: parent,
      agent: agent,
      content: AttachmentContent.fromString('Test value'),
      etag: retrieve.data!.etag,
    );
    final stateResponse = await lrs.saveState(doc2);
    expect(stateResponse.success, isTrue);
  });

  test("should update state", () async {
    // What changes are to be made
    Map<String, String> changeSet = {};
    // What the correct content should be after change
    Map<String, String> correctSet = {};
    // What the actual content is after change
    Map<String, String> currentSet = {};

    // Load initial change set
    Map<String, String> changeSetMap = {'x': 'foo', 'y': 'bar'};
    changeSetMap.forEach((key, value) {
      changeSet[key] = value;
    });
    Map<String, String> correctSetMap =
        changeSetMap; // In the beginning, these are equal
    correctSetMap.forEach((key, value) {
      correctSet[key] = value;
    });

    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
    );

    final clear = await lrs.deleteState(doc);
    expect(clear.success, isTrue);

    final doc2 = doc.copyWith(
      contentType: 'application/json',
      content: AttachmentContent.fromString(json.encode(changeSet)),
    );

    final save = await lrs.saveState(doc2);
    expect(save.success, isTrue);

    final retrieveBeforeUpdate =
        await lrs.retrieveState('test', activity, agent);
    expect(retrieveBeforeUpdate.success, isTrue);

    final beforeDoc = retrieveBeforeUpdate.data!;
    final c = json.decode(String.fromCharCodes(beforeDoc.content!.asList()!));
    c.forEach((key, value) {
      currentSet[key] = value;
    });
    expect(currentSet, correctSet);

    changeSetMap = {'x': 'bash', 'z': 'faz'};
    changeSet.clear();
    changeSetMap.forEach((key, value) {
      changeSet[key] = value;
    });

    final doc3 = doc2.copyWith(
      contentType: 'application/json',
      content: AttachmentContent.fromString(json.encode(changeSet)),
    );

    // Update the correct set with the changes
    changeSetMap.forEach((key, value) {
      correctSet[key] = value;
    });

    currentSet.clear();

    final update = await lrs.updateState(doc3);
    expect(update.success, isTrue);

    final retrieveAfterUpdate =
        await lrs.retrieveState('test', activity, agent);
    expect(retrieveAfterUpdate.success, isTrue);

    final afterDoc = retrieveAfterUpdate.data!;
    final ac = json.decode(String.fromCharCodes(afterDoc.content!.asList()!));
    ac.forEach((key, value) {
      currentSet[key] = value;
    });

    expect(currentSet, correctSet);
  });

  test("should delete state", () async {
    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
    );

    final response = await lrs.deleteState(doc);
    expect(response.success, isTrue);
  });

  test("should clear state", () async {
    final response = await lrs.clearState(activity, agent);
    expect(response.success, isTrue);
  });

  test("should retrieve activity", () async {
    final response = await lrs.retrieveActivity(activity!.id.toString());
    expect(response.success, isTrue);

    final returnedActivity = response.data!;
    expect(activity!.id.toString(), returnedActivity.id.toString());
  });

  test("should retrieve activity profile ids", () async {
    final response = await lrs.retrieveActivityProfileIds(activity);
    expect(response.success, isTrue);
  });

  test("should retrieve activity profile", () async {
    final doc = ActivityProfileDocument(
      id: 'test',
      activity: activity,
    );

    final response = await lrs.deleteActivityProfile(doc);
    expect(response.success, isTrue);

    final doc2 = ActivityProfileDocument(
      id: 'test',
      activity: activity,
      content: AttachmentContent.fromString('Test value2'),
    );

    final save = await lrs.saveActivityProfile(doc2);
    print(save.errMsg);
    expect(save.success, isTrue);

    final retrieveResponse =
        await lrs.retrieveActivityProfile('test', activity);
    expect(retrieveResponse.data!.etag,
        '6e6e6c11d7e0bffe0369873a2a5fd751ab2ea64f');
    expect(retrieveResponse.success, isTrue);
  });

  test("should save activity profile", () async {
    final doc = ActivityProfileDocument(
      id: 'test',
      activity: activity,
    );

    final response = await lrs.deleteActivityProfile(doc);
    expect(response.success, isTrue);

    final doc2 = ActivityProfileDocument(
      id: 'test',
      activity: activity,
      content: AttachmentContent.fromString('Test value2'),
    );

    final save = await lrs.saveActivityProfile(doc2);
    expect(save.success, isTrue);
  });

  test("should overwrite activity profile", () async {
    final response = await lrs.deleteActivityProfile(ActivityProfileDocument(
      id: 'test',
      activity: activity,
    ));
    expect(response.success, isTrue);

    final save = await lrs.saveActivityProfile(
      ActivityProfileDocument(
        id: 'test',
        activity: activity,
        content: AttachmentContent.fromString('Test value2'),
      ),
    );
    expect(save.success, isTrue);

    final retrieve = await lrs.retrieveActivityProfile('test', activity);
    expect(retrieve.success, isTrue);

    final lrsResp = await lrs.saveActivityProfile(ActivityProfileDocument(
      id: 'test2',
      activity: activity,
      etag: retrieve.data!.etag,
      content: AttachmentContent.fromString('Test value3'),
    ));
    expect(lrsResp.success, isTrue);
  });

  test("should delete activity profile", () async {
    final response = await lrs.deleteActivityProfile(ActivityProfileDocument(
      id: 'test',
      activity: activity,
    ));
    expect(response.success, isTrue);
  });

  test("should retrieve person", () async {
    final profile = AgentProfileDocument(
      id: 'test',
      agent: agent,
    );

    // Delete any pre-existing profiles for this agent
    final deleteResponse = await lrs.deleteAgentProfile(profile);
    print(deleteResponse.success);

    // Create the agent
    final saveResponse = await lrs.saveAgentProfile(profile);
    print(saveResponse.errMsg);
    expect(saveResponse.success, isTrue);

    // Retrieve the agent
    final response = await lrs.retrievePerson(agent);
    expect(response.success, isTrue);

    final person = response.data!;
    print(person.toJson());
    //expect(person.name[0], agent.name);
    expect(person.mbox![0], agent!.mbox);
  });

  test("should retrieve agent profile ids", () async {
    final response = await lrs.retrieveAgentProfileIds(agent);
    expect(response.success, isTrue);
  });

  test("should retrieve agent profile", () async {
    final response = await lrs.deleteAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
    ));
    expect(response.success, isTrue);

    final save = await lrs.saveAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
      content: AttachmentContent.fromString('Test value4'),
    ));
    expect(save.success, isTrue);

    final retrieve = await lrs.retrieveAgentProfile('test', agent);
    expect(retrieve.success, isTrue);
    expect(retrieve.data!.etag, 'da16d3e0cbd55e0f13558ad0ecfd2605e2238c71');
  });

  test("should save agent profile", () async {
    final response = await lrs.deleteAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
    ));
    expect(response.success, isTrue);

    final save = await lrs.saveAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
      content: AttachmentContent.fromString('Test value'),
    ));
    expect(save.success, isTrue);
  });

  test("should update agent profile", () async {
    // What changes are to be made
    Map<String, String> changeSet = {};
    // What the correct content should be after change
    Map<String, String> correctSet = {};
    // What the actual content is after change
    Map<String, String> currentSet = {};

    // Load initial change set
    Map<String, String> changeSetMap = {
      'firstName': 'Dave',
      'lastName': 'Smith',
      'State': 'CO'
    };
    changeSetMap.forEach((key, value) {
      changeSet[key] = value;
    });
    Map<String, String> correctSetMap =
        changeSetMap; // In the beginning, these are equal
    correctSetMap.forEach((key, value) {
      correctSet[key] = value;
    });

    final doc = AgentProfileDocument(
      id: 'test',
      agent: agent,
    );

    final clear = await lrs.deleteAgentProfile(doc);
    expect(clear.success, isTrue);

    final doc2 = doc.copyWith(
      contentType: 'application/json',
      content: AttachmentContent.fromString(json.encode(changeSet)),
    );

    final save = await lrs.saveAgentProfile(doc2);
    expect(save.success, isTrue);

    final retrieveBeforeUpdate = await lrs.retrieveAgentProfile('test', agent);
    expect(retrieveBeforeUpdate.success, isTrue);
    final beforeDoc = retrieveBeforeUpdate.data!;
    final c = json.decode(String.fromCharCodes(beforeDoc.content!.asList()!));
    c.forEach((key, value) {
      currentSet[key] = value;
    });
    expect(currentSet, correctSet);

    changeSetMap = {'lastName': 'Jones', 'City': 'Colorado Springs'};
    changeSet.clear();
    changeSetMap.forEach((key, value) {
      changeSet[key] = value;
    });

    final doc3 = doc2.copyWith(
      contentType: 'application/json',
      content: AttachmentContent.fromString(json.encode(changeSet)),
    );

    // Update the correct set with the changes
    changeSetMap.forEach((key, value) {
      correctSet[key] = value;
    });

    currentSet.clear();

    final update = await lrs.updateAgentProfile(doc3);
    expect(update.success, isTrue);

    final retrieveAfterUpdate = await lrs.retrieveAgentProfile('test', agent);
    expect(retrieveAfterUpdate.success, isTrue);

    final afterDoc = retrieveAfterUpdate.data!;
    final ac = json.decode(String.fromCharCodes(afterDoc.content!.asList()!));
    ac.forEach((key, value) {
      currentSet[key] = value;
    });

    expect(currentSet, correctSet);
  });

  test("should overwrite agent profile", () async {
    final response = await lrs.deleteAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
    ));
    expect(response.success, isTrue);

    final save = await lrs.saveAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
      content: AttachmentContent.fromString('Test value4'),
    ));
    expect(save.success, isTrue);

    final retrieve = await lrs.retrieveAgentProfile('test', agent);
    expect(retrieve.success, isTrue);

    final overwrite = await lrs.saveAgentProfile(AgentProfileDocument(
      id: 'test2',
      agent: agent,
      etag: retrieve.data!.etag,
      content: AttachmentContent.fromString('Test value5'),
    ));
    expect(overwrite.success, isTrue);
  });

  test("should delete agent profile", () async {
    final response = await lrs.deleteAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
    ));
    expect(response.success, isTrue);
  });

  test("should save statement with attachment", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      attachments: [attachment1!],
    );

    final response = await lrs.saveStatement(statement);
    print(response.errMsg);
    expect(response.success, isTrue);
    expect(response.data!.id, isNotNull);
    compareStatements(response.data!, statement);
  });

  test("should save statement with multiple attachments", () async {
    final statement = Statement(
        actor: agent,
        verb: verb,
        object: activity,
        attachments: [attachment1!, attachment2!]);

    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    expect(response.data!.id, isNotNull);
    compareStatements(response.data!, statement);
  });

  test("should save statements with attachment", () async {
    final statement1 = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      attachments: [attachment1!],
    );

    final statement2 = Statement(
      actor: agent,
      verb: verb,
      object: activity,
    );

    final statements = [statement1, statement2];

    final response = await lrs.saveStatements(statements);
    expect(response.success, isTrue);
    compareStatements(response.data!.statements![1]!, statement2);
    expect(response.data, isNotNull);
    expect(response.data!.statements![0]!.id, isNotNull);
    expect(response.data!.statements![1]!.id, isNotNull);
  });

  test("should retrieve statement with attachment", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      attachments: [attachment1!],
    );

    final saved = await lrs.saveStatement(statement);
    print(saved.errMsg);
    expect(saved.success, isTrue);

    final retrieved = await lrs.retrieveStatement(saved.data!.id, true);
    expect(retrieved.success, isTrue);
    final calculated =
        sha256.convert(retrieved.data!.attachments![0].content!.asList()!);
    final expected = sha256.convert(attachment1!.content!.asList()!);
    expect(calculated, expected);
  });

  test("should retrieve statement with binary attachment", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      attachments: [attachment3!],
    );

    final saved = await lrs.saveStatement(statement);
    print(saved.errMsg);
    expect(saved.success, isTrue);

    final retrieved = await lrs.retrieveStatement(saved.data!.id, true);
    print(retrieved.errMsg);
    expect(retrieved.success, isTrue);

    final calculated =
        sha256.convert(retrieved.data!.attachments![0].content!.asList()!);
    final expected = sha256.convert(attachment3!.content!.asList()!);
    expect(calculated, expected);
  });

  test("should query statement with attachments", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      attachments: [attachment1!],
    );

    final saved = await lrs.saveStatement(statement);
    expect(saved.success, isTrue);

    final query = StatementsQuery(
      format: QueryResultFormat.EXACT,
      limit: 10,
      attachments: true,
    );

    final queryResult = await lrs.queryStatements(query);
    expect(queryResult.success, isTrue);

    final calculated = sha256.convert(
        queryResult.data!.statements![0]!.attachments![0].content!.asList()!);
    final expected = sha256.convert(attachment1!.content!.asList()!);
    expect(calculated, expected);
  });

  test("should update activity profile", () async {
    // What changes are to be made
    Map<String, String> changeSet = {};
    // What the correct content should be after change
    Map<String, String> correctSet = {};
    // What the actual content is after change
    Map<String, String> currentSet = {};

    // Load initial change set
    Map<String, String> changeSetMap = {'x': 'foo', 'y': 'bar'};
    changeSetMap.forEach((key, value) {
      changeSet[key] = value;
    });
    Map<String, String> correctSetMap =
        changeSetMap; // In the beginning, these are equal
    correctSetMap.forEach((key, value) {
      correctSet[key] = value;
    });

    final doc = ActivityProfileDocument(id: 'test', activity: activity);

    final clear = await lrs.deleteActivityProfile(doc);
    expect(clear.success, isTrue);

    final doc2 = doc.copyWith(
      contentType: 'application/json',
      content: AttachmentContent.fromString(json.encode(changeSet)),
    );

    final save = await lrs.saveActivityProfile(doc2);
    print(save.errMsg);
    expect(save.success, isTrue);

    final retrieveBeforeUpdate =
        await lrs.retrieveActivityProfile('test', activity);
    expect(retrieveBeforeUpdate.success, isTrue);

    final beforeDoc = retrieveBeforeUpdate.data!;
    final c = json.decode(String.fromCharCodes(beforeDoc.content!.asList()!));
    c.forEach((key, value) {
      currentSet[key] = value;
    });
    expect(currentSet, correctSet);

    changeSetMap = {'x': 'bash', 'z': 'faz'};
    changeSet.clear();
    changeSetMap.forEach((key, value) {
      changeSet[key] = value;
    });

    final doc3 = doc2.copyWith(
      contentType: 'application/json',
      content: AttachmentContent.fromString(json.encode(changeSet)),
    );

    // Update the correct set with the changes
    changeSetMap.forEach((key, value) {
      correctSet[key] = value;
    });

    currentSet.clear();

    final update = await lrs.updateActivityProfile(doc3);
    expect(update.success, isTrue);

    final retrieveAfterUpdate =
        await lrs.retrieveActivityProfile('test', activity);
    expect(retrieveAfterUpdate.success, isTrue);

    final afterDoc = retrieveAfterUpdate.data!;
    final ac = json.decode(String.fromCharCodes(afterDoc.content!.asList()!));
    ac.forEach((key, value) {
      currentSet[key] = value;
    });

    expect(currentSet, correctSet);
  });

  test("should save statement with group", () async {
    final statement = Statement(
      actor: Group(
        name: 'test agents',
        members: [agent],
      ),
      verb: verb,
      object: activity,
    );

    expect(statement.id, isNull);
    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    compareStatements(response.data!, statement);
  });

  test("should save agent with sha1sum", () async {
    final sumAgent = Agent(
      mboxSHA1Sum: Agent.sha1sum('mailto:tincandart@tincanapi.com'),
      name: 'Test SHA1 Agent',
    );

    final response = await lrs.deleteAgentProfile(AgentProfileDocument(
      id: 'test2s',
      agent: sumAgent,
    ));
    expect(response.success, isTrue);

    final save = await lrs.saveAgentProfile(AgentProfileDocument(
      id: 'test2s',
      agent: sumAgent,
      content: AttachmentContent.fromString('Test value'),
    ));
    print(save.errMsg);
    expect(save.success, isTrue);
  });

  test("should save statement with time diff result duration", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      result: result!.copyWith(
        duration: TinCanDuration.fromDiff(
          DateTime.now().subtract(Duration(hours: 1, seconds: 9)),
          DateTime.now(),
        ),
      ),
    );

    expect(statement.id, isNull);
    final response = await lrs.saveStatement(statement);
    print(response.errMsg);
    expect(response.success, isTrue);
    compareStatements(response.data!, statement);
  });
}
