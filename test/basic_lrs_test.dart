import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:tincan/tincan.dart';

/// These tests were put together from the xAPI documentation on the
/// Learing Locker website - http://docs.learninglocker.net/overview-xapi/
void main() {
  var endpoint;
  var username;
  var password;

  LRS lrs;

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
  });

  setUp(() {
    lrs = RemoteLRS(
      version: Version.V103,
      endpoint: endpoint,
      username: username,
      password: password,
    );
  });

  // These tests go through the use cases demonstrated in Learning Lockers
  // documentation videos to verify that TinCanDart can handle these
  // use cases properly

  test("should test statements", () async {
    // http://docs.learninglocker.net/http-xapi-statements/
    // PUT/POST/GET - statements

    // PUT
    /*
    {
      "id": "dfb7218c-0fc9-4dfc-9524-d497097de027",
      "actor": { "mbox": "mailto:test@example.org" },
      "verb": { "id": "http://www.example.org/verb" },
      "object": { "id": "http://www.example.org/activity" },
    }
    */
    final putResponse = await lrs.saveStatement(Statement(
      id: 'dfb7218c-0fc9-4dfc-9524-d497097de028',
      actor: Agent(mbox: 'mailto:test@example.org'),
      verb: Verb(id: 'http://www.example.org/verb'),
      object: Activity(id: 'http://www.example.org/activity'),
    ));
    expect(putResponse.success, isTrue);
    expect(putResponse.data.id, 'dfb7218c-0fc9-4dfc-9524-d497097de028');

    // POST
    /*
    [{
      "id": "dfb7218c-0fc9-4dfc-9524-d497097de027",
      "actor": { "mbox": "mailto:test1@example.org" },
      "verb": { "id": "http://www.example.org/verb" },
      "object": { "id": "http://www.example.org/activity" },
    }, {
      "actor": { "mbox": "mailto:test2@example.org" },
      "verb": { "id": "http://www.example.org/verb" },
      "object": { "id": "http://www.example.org/activity" },
    }]
    */
    final postResponse = await lrs.saveStatements([
      Statement(
        id: 'dfb7218c-0fc9-4dfc-9524-d497097de027',
        actor: Agent(mbox: 'mailto:test1@example.org'),
        verb: Verb(id: 'http://www.example.org/verb'),
        object: Activity(id: 'http://www.example.org/activity'),
      ),
      Statement(
        actor: Agent(mbox: 'mailto:test2@example.org'),
        verb: Verb(id: 'http://www.example.org/verb'),
        object: Activity(id: 'http://www.example.org/activity'),
      ),
    ]);

    expect(postResponse.success, isTrue);
    expect(postResponse.data.statements.length, 2);
    expect(postResponse.data.statements[0].id,
        'dfb7218c-0fc9-4dfc-9524-d497097de027');
    expect(postResponse.data.statements[1].id, isNotNull);

    // Get single statement
    final getResponse =
        await lrs.retrieveStatement('dfb7218c-0fc9-4dfc-9524-d497097de027');
    expect(getResponse.success, isTrue);
    expect(getResponse.data.id, 'dfb7218c-0fc9-4dfc-9524-d497097de027');
    expect(getResponse.data.actor.mbox, 'mailto:test1@example.org');
    expect(getResponse.data.verb.id.toString(), 'http://www.example.org/verb');
    expect((getResponse.data.object as Activity).id.toString(),
        'http://www.example.org/activity');

    // Get multiple statements
    final getManyResponse = await lrs.queryStatements(
      StatementsQuery(
        agent: Agent(mbox: 'mailto:test@example.org'),
        verbID: 'http://www.example.org/verb',
        activityID: 'http://www.example.org/activity',
        registration: '361cd8ef-0f6a-40d2-81f2-b988865f640c',
        relatedActivities: false,
        relatedAgents: false,
        since: DateTime.parse('2017-09-04T12:45:31+00:00'),
        until: DateTime.parse('2017-09-06T12:45:31+00:00'),
        limit: 1,
        format: QueryResultFormat.EXACT,
        attachments: false,
        ascending: false,
      ),
    );

    expect(getManyResponse.success, isTrue);
  });

  test("should test activity profiles", () async {
    // http://docs.learninglocker.net/http-xapi-activities/
    // GET - all profiles for an activity
    // PUT/POST/GET/DELETE - activity profile

    // Create multiple activity definitions
    /*
    [{
      "actor": { "mbox": "mailto:test@example.org" },
      "verb": { "id": "http://www.example.org/verb" },
      "object": {
        "id": "http://www.example.org/activity",
        "definition": {
          "name": {
            "en-GB": "GB Activity Name"
          },
          "description": {
            "en-GB": "GB Activity Description"
          },
          "extensions": {
            "http://www.example.com/extension/1": "extension_value_1"
          },
          "moreInfo": "http://www.example.org/activity/moreinfo1",
          "type": "http://www.example.org/activity/type1"
        }
      }
    }, {
      "actor": { "mbox": "mailto:test@example.org" },
      "verb": { "id": "http://www.example.org/verb" },
      "object": {
        "id": "http://www.example.org/activity",
        "definition": {
          "name": {
            "en-US": "US Activity Name"
          },
          "description": {
            "en-US": "US Activity Description"
          },
          "extensions": {
            "http://www.example.com/extension/2": "extension_value_2"
          },
          "moreInfo": "http://www.example.org/activity/moreinfo2",
          "type": "http://www.example.org/activity/type2"
        }
      }
    }]
    */
    final response = await lrs.saveStatements([
      Statement(
        actor: Agent(mbox: 'mailto:test@example.org'),
        verb: Verb(id: 'http://www.example.org/verb'),
        object: Activity(
          id: 'http://www.example.org/activity',
          definition: ActivityDefinition(
            name: {"en-GB": "GB Activity Name"},
            description: {"en-GB": "GB Activity Description"},
            extensions: Extensions(
              {"http://www.example.com/extension/1": "extension_value_1"},
            ),
            moreInfo: 'http://www.example.org/activity/moreinfo1',
            type: 'http://www.example.org/activity/type1',
          ),
        ),
      ),
      Statement(
        actor: Agent(mbox: 'mailto:test@example.org'),
        verb: Verb(id: 'http://www.example.org/verb'),
        object: Activity(
          id: 'http://www.example.org/activity',
          definition: ActivityDefinition(
            name: {"en-US": "US Activity Name"},
            description: {"en-US": "US Activity Description"},
            extensions: Extensions(
              {"http://www.example.com/extension/2": "extension_value_2"},
            ),
            moreInfo: 'http://www.example.org/activity/moreinfo2',
            type: 'http://www.example.org/activity/type2',
          ),
        ),
      ),
    ]);
    expect(response.success, isTrue);

    final activityParam = Activity(id: 'http://www.example.org/activity');

    final activityProfile = ActivityProfileDocument(
      id: 'http://www.example.org/profiles/1',
      activity: activityParam,
      content: AttachmentContent.fromString('test'),
    );

    // Delete the profile if it's already present
    await lrs.deleteActivityProfile(activityProfile);

    // Save profile data
    final saveResponse = await lrs.saveActivityProfile(activityProfile);
    expect(saveResponse.success, isTrue);

    final profileIdResponse =
        await lrs.retrieveActivityProfileIds(activityParam);
    expect(profileIdResponse.success, isTrue);
    expect(profileIdResponse.data.length, 1);

    final profileResponse = await lrs.retrieveActivityProfile(
      profileIdResponse.data[0],
      activityParam,
    );
    expect(profileResponse.success, isTrue);
    expect(profileResponse.data.content.asString(), 'test');

    // Get activity
    final getResponse = await lrs.retrieveActivity(activityParam);
    expect(getResponse.success, isTrue);
    print(getResponse.data.toJson());
  });

  test("should test agent profiles", () async {
    // http://docs.learninglocker.net/http-xapi-agents/
    // GET - all agents used by a person
    // PUT/POST/GET/DELETE - agent profile

    final agentParam = Agent(mbox: 'mailto:test@example.org');

    // Get a person/agent
    final response = await lrs.retrievePerson(agentParam);
    expect(response.success, isTrue);
    print(response.data.toJson());

    final agentProfile = AgentProfileDocument(
      id: 'example_profile_id',
      agent: agentParam,
    );

    // Delete profile in case it already exists
    await lrs.deleteAgentProfile(agentProfile);

    // Put a profile
    final putResponse = await lrs.saveAgentProfile(agentProfile);
    expect(putResponse.success, isTrue);

    // Get agent profile
    final getResponse =
        await lrs.retrieveAgentProfile('example_profile_id', agentParam);
    expect(getResponse.success, isTrue);
    expect(getResponse.data.etag, isNotNull);

    // Get multiple agent profiles (without since)
    var getManyResponse = await lrs.retrieveAgentProfileIds(agentParam);
    expect(getManyResponse.success, isTrue);

    // Get multiple agent profiles (with since)
    getManyResponse = await lrs.retrieveAgentProfileIds(agentParam,
        since: DateTime.parse('2017-09-04T12:45:31+00:00'));
    expect(getManyResponse.success, isTrue);
  });

  test("should test activity state", () async {
    // http://docs.learninglocker.net/http-xapi-states/
    // PUT/POST/GET/DELETE
    // Big question is if TinCan supports the arbitrary payload

    final contentString = json.encode({
      'key_to_keep': 'value_to_keep',
      'key_to_change': 'value_before_change'
    });
    final agentParam = Agent(mbox: 'mailto:test@example.org');
    final activityParam = Activity(id: 'http://www.example.org/activity');
    final stateDocumentParam = StateDocument(
      agent: agentParam,
      activity: activityParam,
      id: 'example_state_id',
      registration: '361cd8ef-0f6a-40d2-81f2-b988865f640c',
      contentType: 'application/json',
      content: AttachmentContent.fromString(contentString),
    );

    final response = await lrs.saveState(stateDocumentParam);
    expect(response.success, isTrue);

    final updateResponse = await lrs.updateState(stateDocumentParam);
    expect(updateResponse.success, isTrue);

    // Retrieve single state
    final getResponse = await lrs.retrieveState(
        stateDocumentParam.id, activityParam, agentParam,
        registration: stateDocumentParam.registration);
    expect(getResponse.success, isTrue);
    expect(getResponse.data.etag, isNotNull);
    expect(getResponse.data.content.asString(), contentString);

    // Many state IDs
    final getManyResponse = await lrs.retrieveStateIds(
        activityParam, agentParam,
        since: DateTime.parse('2017-09-04T12:45:31+00:00'));
    expect(getManyResponse.success, isTrue);
    expect(getManyResponse.data.length, 1);
    expect(getManyResponse.data[0], 'example_state_id');

    final deleteResponse = await lrs.deleteState(stateDocumentParam);
    expect(deleteResponse.success, isTrue);

    // State ID should no longer be in the list of retrieved state IDs
    final getManyResponseAfterDelete =
        await lrs.retrieveStateIds(activityParam, agentParam);
    expect(getManyResponseAfterDelete.success, isTrue);
    expect(getManyResponseAfterDelete.data.length, 0);
  });
}
