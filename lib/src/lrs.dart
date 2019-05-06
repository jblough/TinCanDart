import 'dart:async';

import './about.dart';
import './activity.dart';
import './activity_profile_document.dart';
import './agent.dart';
import './agent_profile_document.dart';
import './lrs_response.dart';
import './person.dart';
import './state_document.dart';
import './statement.dart';
import './statements_query.dart';
import './statements_result.dart';

abstract class LRS {
  /// Method used to determine the LRS version
  Future<LRSResponse<About>> about();

  /// Save a statement to the LRS
  Future<LRSResponse<Statement>> saveStatement(Statement statement);

  /// Save a set of statements to the LRS
  Future<LRSResponse<StatementsResult>> saveStatements(
      List<Statement> statements);

  /// Retrieve a statement by [id]
  /// optionally include [attachments] in multipart response (default: false)
  Future<LRSResponse<Statement>> retrieveStatement(String id,
      [bool attachments = false]);

  /// Retrieve a voided statement by [id]
  /// optionally include [attachments] in multipart response (default: false)
  Future<LRSResponse<Statement>> retrieveVoidedStatement(String id,
      [bool attachments = false]);

  /// Fetch a set of statements
  Future<LRSResponse<StatementsResult>> queryStatements(StatementsQuery query);

  /// Fetch more statements from a previous query
  Future<LRSResponse<StatementsResult>> moreStatements(String moreURL);

  /// Retrieve the list of IDs for a state
  /// optionally limit retrieved states to those associated with a [registration]
  /// and/or those states stored [since] a specified time
  Future<LRSResponse<List<String>>> retrieveStateIds(
      Activity activity, Agent agent,
      {String registration, DateTime since});

  /// Retrieve a state value by [id] with [activity] in document identifier and [agent] in document identifier
  Future<LRSResponse<StateDocument>> retrieveState(
      String id, Activity activity, Agent agent,
      {String registration});

  /// Save a state value
  Future<LRSResponse> saveState(StateDocument state);

  /// Update an existing state value
  Future<LRSResponse> updateState(StateDocument state);

  /// Remove a state value
  Future<LRSResponse> deleteState(StateDocument state);

  /// Remove all state values
  Future<LRSResponse> clearState(Activity activity, Agent agent,
      {String registration});

  /// Retrieve a full description of an Activity from the LRS
  Future<LRSResponse<Activity>> retrieveActivity(String id);

  /// Retrieve the list of IDs for an activity profile
  Future<LRSResponse<List<String>>> retrieveActivityProfileIds(
      Activity activity);

  /// Retrieve an activity profile value
  Future<LRSResponse<ActivityProfileDocument>> retrieveActivityProfile(
      String id, Activity activity);

  /// Save an activity profile
  Future<LRSResponse> saveActivityProfile(ActivityProfileDocument profile);

  /// Update an existing activity profile
  Future<LRSResponse> updateActivityProfile(ActivityProfileDocument profile);

  /// Remove an activity profile
  Future<LRSResponse> deleteActivityProfile(ActivityProfileDocument profile);

  /// Retrieve an agent
  Future<LRSResponse<Person>> retrievePerson(Agent agent);

  /// Retrieve the list of profileIds for an agent profile
  Future<LRSResponse<List<String>>> retrieveAgentProfileIds(Agent agent,
      {DateTime since});

  /// Retrieve an agent profile by [id] and [agent] in document identifier
  Future<LRSResponse<AgentProfileDocument>> retrieveAgentProfile(
      String id, Agent agent);

  /// Save an agent profile
  Future<LRSResponse> saveAgentProfile(AgentProfileDocument profile);

  /// Update an existing agent profile
  Future<LRSResponse> updateAgentProfile(AgentProfileDocument profile);

  /// Remove an agent profile
  Future<LRSResponse> deleteAgentProfile(AgentProfileDocument profile);
}
