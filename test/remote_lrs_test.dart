import 'dart:io';

import 'package:TinCanDart/src/activity.dart';
import 'package:TinCanDart/src/activity_definition.dart';
import 'package:TinCanDart/src/activity_profile_document.dart';
import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/agent_profile_document.dart';
import 'package:TinCanDart/src/attachment.dart';
import 'package:TinCanDart/src/context.dart';
import 'package:TinCanDart/src/context_activities.dart';
import 'package:TinCanDart/src/duration.dart';
import 'package:TinCanDart/src/language_map.dart';
import 'package:TinCanDart/src/parsing_utils.dart';
import 'package:TinCanDart/src/remote_lrs.dart';
import 'package:TinCanDart/src/result.dart';
import 'package:TinCanDart/src/score.dart';
import 'package:TinCanDart/src/state_document.dart';
import 'package:TinCanDart/src/statement.dart';
import 'package:TinCanDart/src/statement_ref.dart';
import 'package:TinCanDart/src/statements_query.dart';
import 'package:TinCanDart/src/substatement.dart';
import 'package:TinCanDart/src/verb.dart';
import 'package:TinCanDart/src/versions.dart';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
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

  RemoteLRS lrs;
  Agent agent;
  Verb verb;
  Activity activity;
  Activity parent;
  StatementRef statementRef;
  Context context;
  Score score;
  Result result;
  SubStatement subStatement;
  Attachment attachment1;
  Attachment attachment2;
  Attachment attachment3;

  setUpAll(() {
    print(Directory.current);
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
      mbox: 'mailto:tincanjava@tincanapi.com',
      name: 'Test Agent',
    );

    /*
        verb = new Verb("http://adlnet.gov/expapi/verbs/experienced");
        verb.setDisplay(new LanguageMap());
        verb.getDisplay().put("en-US", "experienced");
     */
    verb = Verb(
      id: Uri.parse('http://adlnet.gov/expapi/verbs/experienced'),
      display: LanguageMap({'en-US': 'experienced'}),
    );

    /*
        activity = new Activity();
        activity.setId(new URI("http://tincanapi.com/TinCanJava/Test/Unit/0"));
        activity.setDefinition(new ActivityDefinition());
        activity.getDefinition().setType(new URI("http://id.tincanapi.com/activitytype/unit-test"));
        activity.getDefinition().setName(new LanguageMap());
        activity.getDefinition().getName().put("en-US", "TinCanJava Tests: Unit 0");
        activity.getDefinition().setDescription(new LanguageMap());
        activity.getDefinition().getDescription().put("en-US", "Unit test 0 in the test suite for the Tin Can Java library.");
    */
    activity = Activity(
      id: ParsingUtils.toUri('http://tincanapi.com/TinCanJava/Test/Unit/0'),
      definition: ActivityDefinition(
        type: ParsingUtils.toUri(
            'http://id.tincanapi.com/activitytype/unit-test'),
        name: LanguageMap({'en-US': 'TinCanJava Tests: Unit 0'}),
        description: LanguageMap({
          'en-US': 'Unit test 0 in the test suite for the Tin Can Java library.'
        }),
      ),
    );

    /*
        parent = new Activity();
        parent.setId(new URI("http://tincanapi.com/TinCanJava/Test"));
        parent.setDefinition(new ActivityDefinition());
        parent.getDefinition().setType(new URI("http://id.tincanapi.com/activitytype/unit-test-suite"));
        //parent.getDefinition().setMoreInfo(new URI("http://rusticisoftware.github.io/TinCanJava/"));
        parent.getDefinition().setName(new LanguageMap());
        parent.getDefinition().getName().put("en-US", "TinCanJavava Tests");
        parent.getDefinition().setDescription(new LanguageMap());
        parent.getDefinition().getDescription().put("en-US", "Unit test suite for the Tin Can Java library.");
     */
    parent = Activity(
      id: ParsingUtils.toUri('http://tincanapi.com/TinCanJava/Test'),
      definition: ActivityDefinition(
          type: ParsingUtils.toUri(
              'http://id.tincanapi.com/activitytype/unit-test-suite'),
          moreInfo: ParsingUtils.toUri(
              'http://rusticisoftware.github.io/TinCanJava/'),
          name: LanguageMap({'en-US': 'TinCanJavava Tests'}),
          description: LanguageMap(
              {'en-US': 'Unit test suite for the Tin Can Java library.'})),
    );

    /*
        statementRef = new StatementRef(UUID.randomUUID());
     */
    statementRef = StatementRef(id: Uuid().v4().toString());

    /*
        context = new Context();
        context.setRegistration(UUID.randomUUID());
        context.setStatement(statementRef);
        context.setContextActivities(new ContextActivities());
        context.getContextActivities().setParent(new ArrayList<Activity>());
        context.getContextActivities().getParent().add(parent);
     */
    context = Context(
      registration: Uuid().v4().toString(),
      statement: statementRef,
      contextActivities: ContextActivities(parent: [parent]),
    );

    /*
        score = new Score();
        score.setRaw(97.0);
        score.setScaled(0.97);
        score.setMax(100.0);
        score.setMin(0.0);
     */
    score = Score(
      raw: 97.0,
      scaled: 0.97,
      max: 100.0,
      min: 0.0,
    );

    /*
        result = new Result();
        result.setScore(score);
        result.setSuccess(true);
        result.setCompletion(true);
        result.setDuration(new Period(1, 2, 16, 43));
     */
    /*result = Result(
      score: score,
      success: true,
      completion: true,
      duration: TinCanDuration.fromParts(
        hours: 1.toString(),
        minutes: 2.toString(),
        seconds: 16.04.toString(),
      ),
    );*/

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

    /*
        subStatement = new SubStatement();
        subStatement.setActor(agent);
        subStatement.setVerb(verb);
        subStatement.setObject(parent);
     */
    subStatement = SubStatement(
      actor: agent,
      verb: verb,
      object: parent,
    );

    /*
        attachment1 = new Attachment();
        attachment1.setContent("hello world".getBytes("UTF-8"));
        attachment1.setContentType("application/octet-stream");
        attachment1.setDescription(new LanguageMap());
        attachment1.getDescription().put("en-US", "Test Description");
        attachment1.setDisplay(new LanguageMap());
        attachment1.getDisplay().put("en-US", "Test Display");
        attachment1.setUsageType(new URI("http://id.tincanapi.com/attachment/supporting_media"));
     */

    attachment1 = Attachment(
        content: ParsingUtils.toBuffer('hello world'),
        contentType: "application/octet-stream",
        description: LanguageMap({'en-US': 'Test Description'}),
        display: LanguageMap({'en-US': 'Test Display'}),
        usageType: ParsingUtils.toUri(
            'http://id.tincanapi.com/attachment/supporting_media'));

    /*
        attachment2 = new Attachment();
        attachment2.setContent("hello world 2".getBytes("UTF-8"));
        attachment2.setContentType("text/plain");
        attachment2.setDescription(new LanguageMap());
        attachment2.getDescription().put("en-US", "Test Description 2");
        attachment2.setDisplay(new LanguageMap());
        attachment2.getDisplay().put("en-US", "Test Display 2");
        attachment2.setUsageType(new URI("http://id.tincanapi.com/attachment/supporting_media"));
    */
    attachment2 = Attachment(
      content: ParsingUtils.toBuffer('hello world 2'),
      contentType: "text/plain",
      description: LanguageMap({'en-US': 'Test Description 2'}),
      display: LanguageMap({'en-US': 'Test Display 2'}),
      usageType: ParsingUtils.toUri(
          'http://id.tincanapi.com/attachment/supporting_media'),
    );

    /*
        attachment3 = new Attachment();
        attachment3.setContent(getResourceAsByteArray("/files/image.jpg"));
        attachment3.setContentType("image/jpeg");
        attachment3.setDescription(new LanguageMap());
        attachment3.getDescription().put("en-US", "Test Description 3");
        attachment3.setDisplay(new LanguageMap());
        attachment3.getDisplay().put("en-US", "Test Display 3");
        attachment3.setUsageType(new URI("http://id.tincanapi.com/attachment/supporting_media"));
     */
    attachment3 = Attachment(
      content:
          ParsingUtils.listToBuffer(File('./test/image.jpg').readAsBytesSync()),
      contentType: "image/jpeg",
      description: LanguageMap({'en-US': 'Test Description 3'}),
      display: LanguageMap({'en-US': 'Test Display 3'}),
      usageType: ParsingUtils.toUri(
          'http://id.tincanapi.com/attachment/supporting_media'),
    );
  });

  setUp(() {
    lrs = RemoteLRS(
      version: Version.V103,
      endpoint: ParsingUtils.toUri(endpoint),
      username: username,
      password: password,
    );
  });

  /*
    @Test
    public void testAbout() throws Exception {
        AboutLRSResponse lrsRes = lrs.about();
	      System.out.println(lrsRes);
        Assert.assertTrue(lrsRes.getSuccess());
    }
   */

  test("should retrieve about", () async {
    final about = await lrs.about();
    expect(about.success, isTrue);
  });

  test("endpoint", () {
    var obj = RemoteLRS();
    expect(obj.endpoint, isNull);

    String strURL = "http://tincanapi.com/test/TinCanJava";
    obj = RemoteLRS(endpoint: ParsingUtils.toUri(strURL));
    expect(obj.endpoint.toString(), '$strURL/');
  });

  /*
    @Test(expected = MalformedURLException.class)
    public void testEndPointBadURL() throws MalformedURLException {
        RemoteLRS obj = new RemoteLRS();
        obj.setEndpoint("test");
    }
   */
  test("should throw exception on endpoint bad url", () {
    expect(
        RemoteLRS(endpoint: ParsingUtils.toUri("test")), throwsFormatException);
  });

  /*
    @Test
    public void testVersion() throws Exception {
        RemoteLRS obj = new RemoteLRS();
        Assert.assertNull(obj.getVersion());

        obj.setVersion(TCAPIVersion.V100);
        Assert.assertEquals(TCAPIVersion.V100, lrs.getVersion());
    }
*/
  /*test("should get version", () {
    RemoteLRS(version:);
  });*/

/*

    @Test
    public void testUsername() throws Exception {
        RemoteLRS obj = new RemoteLRS();
        obj.setPassword("pass");

        Assert.assertNull(obj.getUsername());
        Assert.assertNull(obj.getAuth());

        obj.setUsername("test");
        Assert.assertEquals("test", obj.getUsername());
        Assert.assertEquals(obj.getAuth(), "Basic dGVzdDpwYXNz");
    }
*/
  test("should set username", () {
    final lrs = RemoteLRS(username: 'test', password: 'pass');
    expect(lrs.auth, 'Basic dGVzdDpwYXNz');
  });

/*
    @Test
    public void testPassword() throws Exception {
        RemoteLRS obj = new RemoteLRS();
        obj.setUsername("user");

        Assert.assertNull(obj.getPassword());
        Assert.assertNull(obj.getAuth());

        obj.setPassword("test");
        Assert.assertEquals("test", obj.getPassword());
        Assert.assertEquals("Basic dXNlcjp0ZXN0", obj.getAuth());
    }
 */
  test("should set password", () {
    final lrs = RemoteLRS(username: 'user', password: 'test');
    expect(lrs.auth, 'Basic dXNlcjp0ZXN0');
  });

  /*
    @Test
    public void testCalculateBasicAuth() throws Exception {
        RemoteLRS obj = new RemoteLRS();
        obj.setUsername("user");
        obj.setPassword("pass");
        Assert.assertEquals("Basic dXNlcjpwYXNz", obj.calculateBasicAuth());
    }
   */
  test("should calculate basic auth", () {
    final obj = RemoteLRS(username: "user", password: "pass");
    expect(obj.auth, "Basic dXNlcjpwYXNz");
  });

  /*
    @Test
    public void testAboutFailure() throws Exception {
        RemoteLRS obj = new RemoteLRS(TCAPIVersion.V100);
        obj.setEndpoint(new URI("http://cloud.scorm.com/tc/3TQLAI9/sandbox/").toString());

        AboutLRSResponse lrsRes = obj.about();
        Assert.assertFalse(lrsRes.getSuccess());
    }
   */
  test("about", () async {
    final obj = RemoteLRS(
        version: Version.V100,
        endpoint: ParsingUtils.toUri(
            'https://cloud.scorm.com/lrs/1Y32ZYODBD/sandbox/'));
    final response = await obj.about();
    final data = response.data;
    expect(response.success, isTrue);
    expect(data, isNotNull);
  });

  /*
    @Test
    public void testAboutFailure() throws Exception {
        RemoteLRS obj = new RemoteLRS(TCAPIVersion.V100);
        obj.setEndpoint(new URI("http://cloud.scorm.com/tc/3TQLAI9/sandbox/").toString());

        AboutLRSResponse lrsRes = obj.about();
        Assert.assertFalse(lrsRes.getSuccess());
    }
   */
  test("about should fail", () async {
    final obj = RemoteLRS(
        version: Version.V100,
        endpoint:
            ParsingUtils.toUri('http://cloud.scorm.com/tc/3TQLAI9/sandbox/'));
    final response = await obj.about();
    final data = response.data;
    final error = response.errMsg;
    //print(error);
    expect(response.success, isFalse);
    expect(data, isNull);
    expect(error, isNotNull);
  });

  /*
    @Test
    public void testSaveStatement() throws Exception {
        Statement statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);

        StatementLRSResponse lrsRes = lrs.saveStatement(statement);
        Assert.assertTrue(lrsRes.getSuccess());
        Assert.assertEquals(statement, lrsRes.getContent());
        Assert.assertNotNull(lrsRes.getContent().getId());
    }
   */
  test("should save statement", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
    );

    expect(statement.id, isNull);
    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    compareStatements(response.data, statement);
  });

  /*
    @Test
    public void testSaveStatementWithID() throws Exception {
        Statement statement = new Statement();
        statement.stamp();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);

        StatementLRSResponse lrsRes = lrs.saveStatement(statement);
        Assert.assertTrue(lrsRes.getSuccess());
        Assert.assertEquals(statement, lrsRes.getContent());
    }
   */
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
    expect(response.data.id, originalId);
    compareStatements(response.data, statement);
  });

  /*
    @Test
    public void testSaveStatementWithContext() throws Exception {
        Statement statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statement.setContext(context);

        StatementLRSResponse lrsRes = lrs.saveStatement(statement);
        Assert.assertTrue(lrsRes.getSuccess());
        Assert.assertEquals(statement, lrsRes.getContent());
    }  
   */
  test("should save statement with context", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      context: context,
    );

    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    compareStatements(response.data, statement);
  });

  /*
    @Test
    public void testSaveStatementWithResult() throws Exception {
        Statement statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statement.setContext(context);
        statement.setResult(result);

        StatementLRSResponse lrsRes = lrs.saveStatement(statement);
        Assert.assertTrue(lrsRes.getSuccess());
        Assert.assertEquals(statement, lrsRes.getContent());
    }
   */
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
    compareStatements(response.data, statement);
  });

  /*
    @Test
    public void testSaveStatementStatementRef() throws Exception {
        Statement statement = new Statement();
        statement.stamp();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(statementRef);

        StatementLRSResponse lrsRes = lrs.saveStatement(statement);
        Assert.assertTrue(lrsRes.getSuccess());
        Assert.assertEquals(statement, lrsRes.getContent());
    }
   */
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
    //expect(response.data.object, isNotNull);
    compareStatements(response.data, statement);
  });

  /*
    @Test
    public void testSaveStatementSubStatement() throws Exception {
        Statement statement = new Statement();
        statement.stamp();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(subStatement);

        StatementLRSResponse lrsRes = lrs.saveStatement(statement);
        Assert.assertTrue(lrsRes.getSuccess());
        Assert.assertEquals(statement, lrsRes.getContent());
    }
   */
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
    //expect(response.data.object, isNotNull);
    compareStatements(response.data, statement);
  });

  /*
    @Test
    public void testSaveStatements() throws Exception {
        Statement statement1 = new Statement();
        statement1.setActor(agent);
        statement1.setVerb(verb);
        statement1.setObject(parent);

        Statement statement2 = new Statement();
        statement2.setActor(agent);
        statement2.setVerb(verb);
        statement2.setObject(activity);
        statement2.setContext(context);

        List<Statement> statements = new ArrayList<Statement>();
        statements.add(statement1);
        statements.add(statement2);

        StatementsResultLRSResponse lrsRes = lrs.saveStatements(statements);
        Assert.assertTrue(lrsRes.getSuccess());

        Statement s1 = lrsRes.getContent().getStatements().get(0);
        Statement s2 = lrsRes.getContent().getStatements().get(1);

        Assert.assertNotNull(s1.getId());
        Assert.assertNotNull(s2.getId());

        Assert.assertEquals(s1.getActor(), agent);
        Assert.assertEquals(s1.getVerb(), verb);
        Assert.assertEquals(s1.getObject(), parent);

        Assert.assertEquals(s2.getActor(), agent);
        Assert.assertEquals(s2.getVerb(), verb);
        Assert.assertEquals(s2.getObject(), activity);
        Assert.assertEquals(s2.getContext(), context);
    }
   */
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

    final s1 = response.data.statements[0];
    final s2 = response.data.statements[1];

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

  /*
    @Test
    public void testRetrieveStatement() throws Exception {
        Statement statement = new Statement();
        statement.stamp();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statement.setContext(context);
        statement.setResult(result);

        StatementLRSResponse saveRes = lrs.saveStatement(statement);
        Assert.assertTrue(saveRes.getSuccess());
        StatementLRSResponse retRes = lrs.retrieveStatement(saveRes.getContent().getId().toString(), false);
        Assert.assertTrue(retRes.getSuccess());
    }
   */
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

    final getResponse = await lrs.retrieveStatement(saveResponse.data.id);
    expect(getResponse.success, isTrue);
  });

  /*
    @Test
    public void testQueryStatements() throws Exception {
        StatementsQuery query = new StatementsQuery();
        query.setAgent(agent);
        query.setVerbID(verb.getId().toString());
        query.setActivityID(parent.getId());
        query.setRelatedActivities(true);
        query.setRelatedAgents(true);
        query.setFormat(QueryResultFormat.IDS);
        query.setLimit(10);

        StatementsResultLRSResponse lrsRes = lrs.queryStatements(query);
        Assert.assertTrue(lrsRes.getSuccess());
    }
   */
  test("should query statements", () async {
    final query = StatementsQuery(
      agent: agent,
      verbID: verb.id,
      activityID: parent.id,
      relatedActivities: true,
      relatedAgents: true,
      format: QueryResultFormat.IDS,
      limit: 10,
    );

    final response = await lrs.queryStatements(query);
    expect(response.success, isTrue);
  });

/*
    @Test
    public void testMoreStatements() throws Exception {
        StatementsQuery query = new StatementsQuery();
        query.setFormat(QueryResultFormat.IDS);
        query.setLimit(2);

        StatementsResultLRSResponse queryRes = lrs.queryStatements(query);
        Assert.assertTrue(queryRes.getSuccess());
        Assert.assertNotNull(queryRes.getContent().getMoreURL());
        StatementsResultLRSResponse moreRes = lrs.moreStatements(queryRes.getContent().getMoreURL());
        Assert.assertTrue(moreRes.getSuccess());
    }
*/
  test("should get more statements", () async {
    final query = StatementsQuery(
      format: QueryResultFormat.IDS,
      limit: 2,
    );

    final response = await lrs.queryStatements(query);
    expect(response.success, isTrue);
    expect(response.data.moreUrl, isNotNull);

    final moreResponse = await lrs.moreStatements(response.data.moreUrl);
    expect(moreResponse.success, isTrue);
  });

/*
    @Test
    public void testRetrieveStateIds() throws Exception {
        ProfileKeysLRSResponse lrsRes = lrs.retrieveStateIds(activity, agent, null);
        Assert.assertTrue(lrsRes.getSuccess());
    }
*/
  test("should retrieve state ids", () async {
    final response = await lrs.retrieveStateIds(activity, agent, null);
    expect(response.success, isTrue);
  });

/*
    @Test
    public void testRetrieveState() throws Exception {
        LRSResponse clear = lrs.clearState(activity, agent, null);
        Assert.assertTrue(clear.getSuccess());

        StateDocument doc = new StateDocument();
        doc.setActivity(activity);
        doc.setAgent(agent);
        doc.setId("test");
        doc.setContent("Test value".getBytes("UTF-8"));

        LRSResponse save = lrs.saveState(doc);
        Assert.assertTrue(save.getSuccess());

        StateLRSResponse lrsRes = lrs.retrieveState("test", activity, agent, null);
        Assert.assertEquals("\"c140f82cb70e3884ad729b5055b7eaa81c795f1f\"", lrsRes.getContent().getEtag());
        Assert.assertTrue(lrsRes.getSuccess());
    }
*/
  test("should retrieve state", () async {
    final clear = await lrs.clearState(activity, agent, null);
    expect(clear.success, isTrue);

    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
      content: ParsingUtils.toBuffer('Test value'),
    );

    final save = await lrs.saveState(doc);
    expect(save.success, isTrue);

    final stateResponse =
        await lrs.retrieveState('test', activity, agent, null);
    expect(stateResponse.success, isTrue);
    expect(
        stateResponse.data.etag, '"c140f82cb70e3884ad729b5055b7eaa81c795f1f"');
  });

/*
    @Test
    public void testSaveState() throws Exception {
        StateDocument doc = new StateDocument();
        doc.setActivity(activity);
        doc.setAgent(agent);
        doc.setId("test");
        doc.setContent("Test value".getBytes("UTF-8"));

        LRSResponse lrsRes = lrs.saveState(doc);
        Assert.assertTrue(lrsRes.getSuccess());
    }
*/
  test("should save state", () async {
    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
      content: ParsingUtils.toBuffer('Test value'),
    );

    final save = await lrs.saveState(doc);
    expect(save.success, isTrue);
  });

/*
    @Test
    public void testOverwriteState() throws Exception {
        LRSResponse clear = lrs.clearState(activity, agent, null);
        Assert.assertTrue(clear.getSuccess());

        StateDocument doc = new StateDocument();
        doc.setActivity(activity);
        doc.setAgent(agent);
        doc.setId("test");
        doc.setContent("Test value".getBytes("UTF-8"));

        LRSResponse save = lrs.saveState(doc);
        Assert.assertTrue(save.getSuccess());

        StateLRSResponse retrieve = lrs.retrieveState("test", activity, agent, null);
        Assert.assertTrue(retrieve.getSuccess());

        doc.setEtag(retrieve.getContent().getEtag());
        doc.setId("testing");
        doc.setActivity(parent);
        LRSResponse lrsResp = lrs.saveState(doc);
        Assert.assertTrue(lrsResp.getSuccess());
    }
*/
  test("should overwrite state", () async {
    final clear = await lrs.clearState(activity, agent, null);
    expect(clear.success, isTrue);

    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
      content: ParsingUtils.toBuffer('Test value'),
    );

    final save = await lrs.saveState(doc);
    expect(save.success, isTrue);

    final retrieve = await lrs.retrieveState("test", activity, agent, null);
    expect(retrieve.success, isTrue);

    final doc2 = StateDocument(
      id: 'testing',
      activity: parent,
      agent: agent,
      content: ParsingUtils.toBuffer('Test value'),
      etag: retrieve.data.etag,
    );
    final stateResponse = await lrs.saveState(doc2);
    expect(stateResponse.success, isTrue);
  });

/*
    @Test
    public void testUpdateState() throws Exception {
        ObjectMapper mapper = Mapper.getInstance();
        ObjectNode changeSet = mapper.createObjectNode();  // What changes are to be made
        ObjectNode correctSet = mapper.createObjectNode(); // What the correct content should be after change
        ObjectNode currentSet = mapper.createObjectNode(); // What the actual content is after change

        // Load initial change set
        String data = "{ \"x\" : \"foo\", \"y\" : \"bar\" }";
        Map<String, String> changeSetMap = mapper.readValue(data, Map.class);
        for (String k : changeSetMap.keySet()) {
            String v = changeSetMap.get(k);
            changeSet.put(k, v);
        }
        Map<String, String> correctSetMap = changeSetMap; // In the beginning, these are equal
        for (String k : correctSetMap.keySet()) {
            String v = correctSetMap.get(k);
            correctSet.put(k, v);
        }

        StateDocument doc = new StateDocument();
        doc.setActivity(activity);
        doc.setAgent(agent);
        doc.setId("test");

        LRSResponse clear = lrs.deleteState(doc);
        Assert.assertTrue(clear.getSuccess());

        doc.setContentType("application/json");
        doc.setContent(changeSet.toString().getBytes("UTF-8"));

        LRSResponse save = lrs.saveState(doc);
        Assert.assertTrue(save.getSuccess());
        StateLRSResponse retrieveBeforeUpdate = lrs.retrieveState("test", activity, agent, null);
        Assert.assertTrue(retrieveBeforeUpdate.getSuccess());
        StateDocument beforeDoc = retrieveBeforeUpdate.getContent();
        Map<String, String> c = mapper.readValue(new String(beforeDoc.getContent(), "UTF-8"), Map.class);
        for (String k : c.keySet()) {
            String v = c.get(k);
            currentSet.put(k, v);
        }
        Assert.assertTrue(currentSet.equals(correctSet));

        doc.setContentType("application/json");
        data = "{ \"x\" : \"bash\", \"z\" : \"faz\" }";
        changeSet.removeAll();
        changeSetMap = mapper.readValue(data, Map.class);
        for (String k : changeSetMap.keySet()) {
            String v = changeSetMap.get(k);
            changeSet.put(k, v);
        }

        doc.setContent(changeSet.toString().getBytes("UTF-8"));

        // Update the correct set with the changes
        for (String k : changeSetMap.keySet()) {
            String v = changeSetMap.get(k);
            correctSet.put(k, v);
        }

        currentSet.removeAll();

        LRSResponse update = lrs.updateState(doc);
        Assert.assertTrue(update.getSuccess());
        StateLRSResponse retrieveAfterUpdate = lrs.retrieveState("test", activity, agent, null);
        Assert.assertTrue(retrieveAfterUpdate.getSuccess());
        StateDocument afterDoc = retrieveAfterUpdate.getContent();
        Map<String, String> ac = mapper.readValue(new String(afterDoc.getContent(), "UTF-8"), Map.class);
        for (String k : ac.keySet()) {
            String v = ac.get(k);
            currentSet.put(k, v);
        }
        Assert.assertTrue(currentSet.equals(correctSet));
    }
*/
/*
  test("should update state", () async {
    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
    );

    final clear = await lrs.deleteState(doc);
    expect(clear.success, isTrue);

    final doc2 = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
      contentType: 'application/json',
      content: null, // changeSet.toString().getBytes("UTF-8")
    );

    final save = await lrs.saveState(doc2);
    expect(save.success, isTrue);

    final retrieveBeforeUpdate =
        await lrs.retrieveState("test", activity, agent, null);
    expect(retrieveBeforeUpdate.success, isTrue);

    final StateDocument beforeDoc = retrieveBeforeUpdate.data;
  });
  */

  /*
    @Test
    public void testDeleteState() throws Exception {
        StateDocument doc = new StateDocument();
        doc.setActivity(activity);
        doc.setAgent(agent);
        doc.setId("test");

        LRSResponse lrsRes = lrs.deleteState(doc);
        Assert.assertTrue(lrsRes.getSuccess());
    }
  */
  test("should delete state", () async {
    final doc = StateDocument(
      id: 'test',
      activity: activity,
      agent: agent,
    );

    final response = await lrs.deleteState(doc);
    expect(response.success, isTrue);
  });

  /*
    @Test
    public void testClearState() throws Exception {
        LRSResponse lrsRes = lrs.clearState(activity, agent, null);
        Assert.assertTrue(lrsRes.getSuccess());
    }
 */
  test("should clear state", () async {
    final response = await lrs.clearState(activity, agent, null);
    expect(response.success, isTrue);
  });

  /*
    @Test
    public void testRetrieveActivity() throws Exception {
        ActivityLRSResponse lrsResponse = lrs.retrieveActivity(activity);
        Assert.assertTrue(lrsResponse.getSuccess());

        Activity returnedActivity = lrsResponse.getContent();
        Assert.assertTrue(activity.getId().toString().equals(returnedActivity.getId().toString()));
    }
  */
  test("should retrieve activity", () async {
    final response = await lrs.retrieveActivity(activity);
    expect(response.success, isTrue);

    final returnedActivity = response.data;
    expect(activity.id.toString(), returnedActivity.id.toString());
  });

  /*
    @Test
    public void testRetrieveActivityProfileIds() throws Exception {
        ProfileKeysLRSResponse lrsRes = lrs.retrieveActivityProfileIds(activity);
        Assert.assertTrue(lrsRes.getSuccess());
    }
  */
  test("should retrieve activity profile ids", () async {
    final response = await lrs.retrieveActivityProfileIds(activity);
    expect(response.success, isTrue);
  });

  /*
    @Test
    public void testRetrieveActivityProfile() throws Exception {
        ActivityProfileDocument doc = new ActivityProfileDocument();
        doc.setActivity(activity);
        doc.setId("test");

        LRSResponse clear = lrs.deleteActivityProfile(doc);
        Assert.assertTrue(clear.getSuccess());

        doc.setContent("Test value2".getBytes("UTF-8"));

        LRSResponse save = lrs.saveActivityProfile(doc);
        Assert.assertTrue(save.getSuccess());

        ActivityProfileLRSResponse lrsRes = lrs.retrieveActivityProfile("test", activity);
        Assert.assertEquals("\"6e6e6c11d7e0bffe0369873a2a5fd751ab2ea64f\"", lrsRes.getContent().getEtag());
        Assert.assertTrue(lrsRes.getSuccess());
    }
  */
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
      content: ParsingUtils.toBuffer('Test value2'),
    );

    final save = await lrs.saveActivityProfile(doc2);
    expect(save.success, isTrue);

    final retrieveResponse =
        await lrs.retrieveActivityProfile("test", activity);
    expect(retrieveResponse.data.etag,
        '"6e6e6c11d7e0bffe0369873a2a5fd751ab2ea64f"');
    expect(retrieveResponse.success, isTrue);
  });

  /*
    @Test
    public void testSaveActivityProfile() throws Exception {
        ActivityProfileDocument doc = new ActivityProfileDocument();
        doc.setActivity(activity);
        doc.setId("test");

        LRSResponse clear = lrs.deleteActivityProfile(doc);
        Assert.assertTrue(clear.getSuccess());

        doc.setContent("Test value2".getBytes("UTF-8"));

        LRSResponse lrsRes = lrs.saveActivityProfile(doc);
        Assert.assertTrue(lrsRes.getSuccess());
    }
   */
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
      content: ParsingUtils.toBuffer('Test value2'),
    );

    final save = await lrs.saveActivityProfile(doc2);
    expect(save.success, isTrue);
  });

  /*
    @Test
    public void testOverwriteActivityProfile() throws Exception {
        ActivityProfileDocument doc = new ActivityProfileDocument();
        doc.setActivity(activity);
        doc.setId("test");

        LRSResponse clear = lrs.deleteActivityProfile(doc);
        Assert.assertTrue(clear.getSuccess());

        doc.setContent("Test value2".getBytes("UTF-8"));

        LRSResponse save = lrs.saveActivityProfile(doc);
        Assert.assertTrue(save.getSuccess());

        ActivityProfileLRSResponse retrieve = lrs.retrieveActivityProfile("test", activity);
        Assert.assertTrue(retrieve.getSuccess());

        doc.setEtag(retrieve.getContent().getEtag());
        doc.setId("test2");
        doc.setContent("Test value3".getBytes("UTF-8"));

        LRSResponse lrsResp = lrs.saveActivityProfile(doc);
        Assert.assertTrue(lrsResp.getSuccess());
    }
  */
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
        content: ParsingUtils.toBuffer('Test value2'),
      ),
    );
    expect(save.success, isTrue);

    final retrieve = await lrs.retrieveActivityProfile("test", activity);
    expect(retrieve.success, isTrue);

    final lrsResp = await lrs.saveActivityProfile(ActivityProfileDocument(
      id: 'test2',
      activity: activity,
      etag: retrieve.data.etag,
      content: ParsingUtils.toBuffer('Test value3'),
    ));
    expect(lrsResp.success, isTrue);
  });

  /*
    @Test
    public void testDeleteActivityProfile() throws Exception {
        ActivityProfileDocument doc = new ActivityProfileDocument();
        doc.setActivity(activity);
        doc.setId("test");

        LRSResponse lrsRes = lrs.deleteActivityProfile(doc);
        Assert.assertTrue(lrsRes.getSuccess());
    }
  */
  test("should delete activity profile", () async {
    final response = await lrs.deleteActivityProfile(ActivityProfileDocument(
      id: 'test',
      activity: activity,
    ));
    expect(response.success, isTrue);
  });

  /*
    @Test
    public void testRetrievePerson() throws Exception {
        PersonLRSResponse lrsResponse = lrs.retrievePerson(agent);
        Assert.assertTrue(lrsResponse.getSuccess());

        Person person = lrsResponse.getContent();
        Assert.assertTrue(agent.getName().equals(person.getName().get(0)));
        Assert.assertTrue(agent.getMbox().equals(person.getMbox().get(0)));
    }
  */
  test("should retrieve person", () async {
    final response = await lrs.retrievePerson(agent);
    expect(response.success, isTrue);

    final person = response.data;
    expect(person.name[0], agent.name);
    expect(person.mbox[0], agent.mbox);
  });

  /*
    @Test
    public void testRetrieveAgentProfileIds() throws Exception {
        ProfileKeysLRSResponse lrsRes = lrs.retrieveAgentProfileIds(agent);
        Assert.assertTrue(lrsRes.getSuccess());
    }
  */
  test("should retrieve agent profile ids", () async {
    final response = await lrs.retrieveAgentProfileIds(agent);
    expect(response.success, isTrue);
  });

  /*
    @Test
    public void testRetrieveAgentProfile() throws Exception {
        AgentProfileDocument doc = new AgentProfileDocument();
        doc.setAgent(agent);
        doc.setId("test");

        LRSResponse clear = lrs.deleteAgentProfile(doc);
        Assert.assertTrue(clear.getSuccess());

        doc.setContent("Test value4".getBytes("UTF-8"));

        LRSResponse save = lrs.saveAgentProfile(doc);
        Assert.assertTrue(save.getSuccess());

        AgentProfileLRSResponse lrsRes = lrs.retrieveAgentProfile("test", agent);
        Assert.assertEquals("\"da16d3e0cbd55e0f13558ad0ecfd2605e2238c71\"", lrsRes.getContent().getEtag());
        Assert.assertTrue(lrsRes.getSuccess());
    }
  */
  test("should retrieve agent profile", () async {
    final response = await lrs.deleteAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
    ));
    expect(response.success, isTrue);

    final save = await lrs.saveAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
      content: ParsingUtils.toBuffer('Test value4'),
    ));
    expect(save.success, isTrue);

    final retrieve = await lrs.retrieveAgentProfile("test", agent);
    expect(retrieve.success, isTrue);
    expect(retrieve.data.etag, '"da16d3e0cbd55e0f13558ad0ecfd2605e2238c71"');
  });

  /*
    @Test
    public void testSaveAgentProfile() throws Exception {
        AgentProfileDocument doc = new AgentProfileDocument();
        doc.setAgent(agent);
        doc.setId("test");

        LRSResponse clear = lrs.deleteAgentProfile(doc);
        Assert.assertTrue(clear.getSuccess());

        doc.setContent("Test value".getBytes("UTF-8"));

        LRSResponse lrsRes = lrs.saveAgentProfile(doc);
        Assert.assertTrue(lrsRes.getSuccess());
    }
  */
  test("should save agent profile", () async {
    final response = await lrs.deleteAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
    ));
    expect(response.success, isTrue);

    final save = await lrs.saveAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
      content: ParsingUtils.toBuffer('Test value'),
    ));
    expect(save.success, isTrue);
  });

  /*
    @Test
    public void testUpdateAgentProfile() throws Exception {
        ObjectMapper mapper = Mapper.getInstance();
        ObjectNode changeSet = mapper.createObjectNode();  // What changes are to be made
        ObjectNode correctSet = mapper.createObjectNode(); // What the correct content should be after change
        ObjectNode currentSet = mapper.createObjectNode(); // What the actual content is after change

        // Load initial change set
        String data = "{ \"firstName\" : \"Dave\", \"lastName\" : \"Smith\", \"State\" : \"CO\" }";
        Map<String, String> changeSetMap = mapper.readValue(data, Map.class);
        for (String k : changeSetMap.keySet()) {
            String v = changeSetMap.get(k);
            changeSet.put(k, v);
        }
        Map<String, String> correctSetMap = changeSetMap; // In the beginning, these are equal
        for (String k : correctSetMap.keySet()) {
            String v = correctSetMap.get(k);
            correctSet.put(k, v);
        }

        AgentProfileDocument doc = new AgentProfileDocument();
        doc.setAgent(agent);
        doc.setId("test");

        LRSResponse clear = lrs.deleteAgentProfile(doc);
        Assert.assertTrue(clear.getSuccess());

        doc.setContentType("application/json");
        doc.setContent(changeSet.toString().getBytes("UTF-8"));

        LRSResponse save = lrs.saveAgentProfile(doc);
        Assert.assertTrue(save.getSuccess());
        AgentProfileLRSResponse retrieveBeforeUpdate = lrs.retrieveAgentProfile("test", agent);
        Assert.assertTrue(retrieveBeforeUpdate.getSuccess());
        AgentProfileDocument beforeDoc = retrieveBeforeUpdate.getContent();
        Map<String, String> c = mapper.readValue(new String(beforeDoc.getContent(), "UTF-8"), Map.class);
        for (String k : c.keySet()) {
            String v = c.get(k);
            currentSet.put(k, v);
        }
        Assert.assertTrue(currentSet.equals(correctSet));

        doc.setContentType("application/json");
        data = "{ \"lastName\" : \"Jones\", \"City\" : \"Colorado Springs\" }";
        changeSet.removeAll();
        changeSetMap = mapper.readValue(data, Map.class);
        for (String k : changeSetMap.keySet()) {
            String v = changeSetMap.get(k);
            changeSet.put(k, v);
        }

        doc.setContent(changeSet.toString().getBytes("UTF-8"));

        // Update the correct set with the changes
        for (String k : changeSetMap.keySet()) {
            String v = changeSetMap.get(k);
            correctSet.put(k, v);
        }

        currentSet.removeAll();
        LRSResponse update = lrs.updateAgentProfile(doc);
        Assert.assertTrue(update.getSuccess());
        AgentProfileLRSResponse retrieveAfterUpdate = lrs.retrieveAgentProfile("test", agent);
        Assert.assertTrue(retrieveAfterUpdate.getSuccess());
        AgentProfileDocument afterDoc = retrieveAfterUpdate.getContent();
           Map<String, String> ac = mapper.readValue(new String(afterDoc.getContent(), "UTF-8"), Map.class);
        for (String k : ac.keySet()) {
            String v = ac.get(k);
            currentSet.put(k, v);
        }
        Assert.assertTrue(currentSet.equals(correctSet));
    }
  */

  /*
    @Test
    public void testOverwriteAgentProfile() throws Exception {
        AgentProfileDocument doc = new AgentProfileDocument();
        doc.setAgent(agent);
        doc.setId("test");

        LRSResponse clear = lrs.deleteAgentProfile(doc);
        Assert.assertTrue(clear.getSuccess());

        doc.setContent("Test value4".getBytes("UTF-8"));

        LRSResponse save = lrs.saveAgentProfile(doc);
        Assert.assertTrue(save.getSuccess());

        AgentProfileLRSResponse retrieve = lrs.retrieveAgentProfile("test", agent);
        Assert.assertTrue(retrieve.getSuccess());

        doc.setEtag(retrieve.getContent().getEtag());
        doc.setId("test2");
        doc.setContent("Test value5".getBytes("UTF-8"));

        LRSResponse lrsResp = lrs.saveAgentProfile(doc);
        Assert.assertTrue(lrsResp.getSuccess());
    }
  */
  test("should overwrite agent profile", () async {
    final response = await lrs.deleteAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
    ));
    expect(response.success, isTrue);

    final save = await lrs.saveAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
      content: ParsingUtils.toBuffer('Test value4'),
    ));
    expect(save.success, isTrue);

    final retrieve = await lrs.retrieveAgentProfile("test", agent);
    expect(retrieve.success, isTrue);

    final overwrite = await lrs.saveAgentProfile(AgentProfileDocument(
      id: 'test2',
      agent: agent,
      etag: retrieve.data.etag,
      content: ParsingUtils.toBuffer('Test value5'),
    ));
    expect(overwrite.success, isTrue);
  });

  /*
    @Test
    public void testDeleteAgentProfile() throws Exception {
        AgentProfileDocument doc = new AgentProfileDocument();
        doc.setAgent(agent);
        doc.setId("test");

        LRSResponse lrsRes = lrs.deleteAgentProfile(doc);
        Assert.assertTrue(lrsRes.getSuccess());
    }  
  */
  test("should delete agent profile", () async {
    final response = await lrs.deleteAgentProfile(AgentProfileDocument(
      id: 'test',
      agent: agent,
    ));
    expect(response.success, isTrue);
  });

  /*
    @Test
    public void testSaveStatementWithAttachment() throws Exception {
        Statement statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statement.addAttachment(attachment1);

        StatementLRSResponse lrsRes = lrs.saveStatement(statement);
        Assert.assertTrue(lrsRes.getSuccess());
        Assert.assertEquals(statement, lrsRes.getContent());
        Assert.assertNotNull(lrsRes.getContent().getId());
        Assert.assertNotNull(lrsRes.getResponse().getContent());
    }
   */
  test("should save statement with attachment", () async {
    final statement = Statement(
        actor: agent, verb: verb, object: activity, attachments: [attachment1]);

    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    expect(response.data.id, isNotNull);
    compareStatements(response.data, statement);
  });

  /*
    @Test
    public void testSaveStatementWithAttachments() throws Exception {
        Statement statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statement.addAttachment(attachment1);
        statement.addAttachment(attachment2);

        StatementLRSResponse lrsRes = lrs.saveStatement(statement);
        Assert.assertTrue(lrsRes.getSuccess());
        Assert.assertEquals(statement, lrsRes.getContent());
        Assert.assertNotNull(lrsRes.getContent().getId());
        Assert.assertNotNull(lrsRes.getResponse().getContent());
    }
   */
  test("should save statement with multiple attachments", () async {
    final statement = Statement(
        actor: agent,
        verb: verb,
        object: activity,
        attachments: [attachment1, attachment2]);

    final response = await lrs.saveStatement(statement);
    expect(response.success, isTrue);
    expect(response.data.id, isNotNull);
    compareStatements(response.data, statement);
  });

  /*
    @Test
    public void testSaveStatementsWithAttachment() throws Exception {
        Statement statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statement.addAttachment(attachment1);

        List<Statement> statementList = new ArrayList<Statement>();
        statementList.add(statement);

        statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statementList.add(statement);

        StatementsResultLRSResponse lrsResultResp = lrs.saveStatements(statementList);
        Assert.assertTrue(lrsResultResp.getSuccess());
        Assert.assertEquals(statement, lrsResultResp.getContent().getStatements().get(1));
        Assert.assertNotNull(lrsResultResp.getContent().getStatements().get(0).getId());
        Assert.assertNotNull(lrsResultResp.getContent().getStatements().get(1).getId());
        Assert.assertNotNull(lrsResultResp.getResponse().getContent());
    }
   */
  test("should save statements with attachment", () async {
    final statement1 = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      attachments: [attachment1],
    );

    final statement2 = Statement(
      actor: agent,
      verb: verb,
      object: activity,
    );

    final statements = [statement1, statement2];

    final response = await lrs.saveStatements(statements);
    expect(response.success, isTrue);
    compareStatements(response.data.statements[1], statement2);
    expect(response.data, isNotNull);
    expect(response.data.statements[0].id, isNotNull);
    expect(response.data.statements[1].id, isNotNull);
  });

  /*

    @Test
    public void testRetrieveStatementWithAttachment() throws Exception {
        Statement statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statement.addAttachment(attachment1);

        StatementLRSResponse saveRes = lrs.saveStatement(statement);
        Assert.assertTrue(saveRes.getSuccess());

        StatementLRSResponse retRes = lrs.retrieveStatement(saveRes.getContent().getId().toString(), true);
        Assert.assertTrue(retRes.getSuccess());

        String hash1, hash2;
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        digest.update(attachment1.getContent());
        byte[] hash = digest.digest();
        hash1 = new String(Hex.encodeHex(hash));

        digest.update(retRes.getContent().getAttachments().get(0).getContent());
        hash = digest.digest();
        hash2 = new String(Hex.encodeHex(hash));

        Assert.assertEquals(hash1, hash2);
    }
   */
  test("should retrieve statement with attachment", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      attachments: [attachment1],
    );

    final saved = await lrs.saveStatement(statement);
    expect(saved.success, isTrue);

    final retrieved = await lrs.retrieveStatement(saved.data.id, true);
    expect(retrieved.success, isTrue);
    final calculated =
        sha256.convert(retrieved.data.attachments[0].content.asInt8List());
    final expected = sha256.convert(attachment1.content.asInt8List());
    expect(calculated, expected);
  });

  /*

    @Test
    public void testRetrieveStatementWithBinaryAttachment() throws Exception {
        Statement statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statement.addAttachment(attachment3);

        StatementLRSResponse saveRes = lrs.saveStatement(statement);
        Assert.assertTrue(saveRes.getSuccess());

        StatementLRSResponse retRes = lrs.retrieveStatement(saveRes.getContent().getId().toString(), true);
        Assert.assertTrue(retRes.getSuccess());

        String hash1, hash2;
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        digest.update(attachment3.getContent());
        byte[] hash = digest.digest();
        hash1 = new String(Hex.encodeHex(hash));

        digest.update(retRes.getContent().getAttachments().get(0).getContent());
        hash = digest.digest();
        hash2 = new String(Hex.encodeHex(hash));

        Assert.assertEquals(hash1, hash2);
    }
  */
  test("should retrieve statement with binary attachment", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      attachments: [attachment3],
    );

    final saved = await lrs.saveStatement(statement);
    expect(saved.success, isTrue);

    final retrieved = await lrs.retrieveStatement(saved.data.id, true);
    expect(retrieved.success, isTrue);

    final calculated =
        sha256.convert(retrieved.data.attachments[0].content.asInt8List());
    final expected = sha256.convert(attachment3.content.asInt8List());
    expect(calculated, expected);
  });

  /*
    @Test
    public void testQueryStatementsWithAttachments() throws Exception {
        Statement statement = new Statement();
        statement.setActor(agent);
        statement.setVerb(verb);
        statement.setObject(activity);
        statement.addAttachment(attachment1);

        StatementLRSResponse lrsRes = lrs.saveStatement(statement);
        Assert.assertTrue(lrsRes.getSuccess());
        Assert.assertEquals(statement, lrsRes.getContent());
        Assert.assertNotNull(lrsRes.getContent().getId());
        Assert.assertNotNull(lrsRes.getResponse().getContent());

        StatementsQuery query = new StatementsQuery();
        query.setFormat(QueryResultFormat.EXACT);
        query.setLimit(10);
        query.setAttachments(true);

        StatementsResultLRSResponse lrsStmntRes = lrs.queryStatements(query);
        Assert.assertTrue(lrsStmntRes.getSuccess());

        String hash1, hash2;
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        digest.update(attachment1.getContent());
        byte[] hash = digest.digest();
        hash1 = new String(Hex.encodeHex(hash));

        digest.update(lrsStmntRes.getContent().getStatements().get(0).getAttachments().get(0).getContent());
        hash = digest.digest();
        hash2 = new String(Hex.encodeHex(hash));

        Assert.assertEquals(hash1, hash2);
    }
  */
  test("should query statement with attachments", () async {
    final statement = Statement(
      actor: agent,
      verb: verb,
      object: activity,
      attachments: [attachment1],
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
        queryResult.data.statements[0].attachments[0].content.asInt8List());
    final expected = sha256.convert(attachment1.content.asInt8List());
    expect(calculated, expected);
  });

  /*
    @Test
    public void testUpdateActivityProfile() throws Exception {
        ObjectMapper mapper = Mapper.getInstance();
        ObjectNode changeSet = mapper.createObjectNode();  // What changes are to be made
        ObjectNode correctSet = mapper.createObjectNode(); // What the correct content should be after change
        ObjectNode currentSet = mapper.createObjectNode(); // What the actual content is after change

        // Load initial change set
        String data = "{ \"x\" : \"foo\", \"y\" : \"bar\" }";
        Map<String, String> changeSetMap = mapper.readValue(data, Map.class);
        for (String k : changeSetMap.keySet()) {
            String v = changeSetMap.get(k);
            changeSet.put(k, v);
        }
        Map<String, String> correctSetMap = changeSetMap; // In the beginning, these are equal
        for (String k : correctSetMap.keySet()) {
            String v = correctSetMap.get(k);
            correctSet.put(k, v);
        }

        ActivityProfileDocument doc = new ActivityProfileDocument();
        doc.setActivity(activity);
        doc.setId("test");

        LRSResponse clear = lrs.deleteActivityProfile(doc);
        Assert.assertTrue(clear.getSuccess());

        doc.setContentType("application/json");
        doc.setContent(changeSet.toString().getBytes("UTF-8"));

        LRSResponse save = lrs.saveActivityProfile(doc);
        Assert.assertTrue(save.getSuccess());
        ActivityProfileLRSResponse retrieveBeforeUpdate = lrs.retrieveActivityProfile("test", activity);
        Assert.assertTrue(retrieveBeforeUpdate.getSuccess());
        ActivityProfileDocument beforeDoc = retrieveBeforeUpdate.getContent();
        Map<String, String> c = mapper.readValue(new String(beforeDoc.getContent(), "UTF-8"), Map.class);
        for (String k : c.keySet()) {
            String v = c.get(k);
            currentSet.put(k, v);
        }
        Assert.assertTrue(currentSet.equals(correctSet));

        doc.setContentType("application/json");
        data = "{ \"x\" : \"bash\", \"z\" : \"faz\" }";
        changeSet.removeAll();
        changeSetMap = mapper.readValue(data, Map.class);
        for (String k : changeSetMap.keySet()) {
            String v = changeSetMap.get(k);
            changeSet.put(k, v);
        }

        doc.setContent(changeSet.toString().getBytes("UTF-8"));

        // Update the correct set with the changes
        for (String k : changeSetMap.keySet()) {
            String v = changeSetMap.get(k);
            correctSet.put(k, v);
        }

        currentSet.removeAll();

        LRSResponse update = lrs.updateActivityProfile(doc);
        Assert.assertTrue(update.getSuccess());
        ActivityProfileLRSResponse retrieveAfterUpdate = lrs.retrieveActivityProfile("test", activity);
        Assert.assertTrue(retrieveAfterUpdate.getSuccess());
        ActivityProfileDocument afterDoc = retrieveAfterUpdate.getContent();
           Map<String, String> ac = mapper.readValue(new String(afterDoc.getContent(), "UTF-8"), Map.class);
        for (String k : ac.keySet()) {
            String v = ac.get(k);
            currentSet.put(k, v);
        }
        Assert.assertTrue(currentSet.equals(correctSet));
    }

   */
}
