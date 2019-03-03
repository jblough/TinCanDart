import 'dart:async';

import 'package:uuid/uuid.dart';

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

// TODO - Add documentation for each method

abstract class LRS {
  Future<LRSResponse<About>> about();

  Future<LRSResponse<Statement>> saveStatement(Statement statement);

  Future<LRSResponse<StatementsResult>> saveStatements(
      List<Statement> statements);

  Future<LRSResponse<Statement>> retrieveStatement(String id,
      [bool attachments = false]);

  Future<LRSResponse<Statement>> retrieveVoidedStatement(String id,
      [bool attachments = false]);

  Future<LRSResponse<StatementsResult>> queryStatements(StatementsQuery query);

  Future<LRSResponse<StatementsResult>> moreStatements(String moreURL);

  Future<LRSResponse<List<String>>> retrieveStateIds(
      Activity activity, Agent agent, Uuid registration);

  Future<LRSResponse<StateDocument>> retrieveState(
      String id, Activity activity, Agent agent, Uuid registration);

  Future<LRSResponse> saveState(StateDocument state);

  Future<LRSResponse> updateState(StateDocument state);

  Future<LRSResponse> deleteState(StateDocument state);

  Future<LRSResponse> clearState(
      Activity activity, Agent agent, Uuid registration);

  Future<LRSResponse<Activity>> retrieveActivity(Activity activity);

  Future<LRSResponse<List<String>>> retrieveActivityProfileIds(
      Activity activity);

  Future<LRSResponse<ActivityProfileDocument>> retrieveActivityProfile(
      String id, Activity activity);

  Future<LRSResponse> saveActivityProfile(ActivityProfileDocument profile);

  Future<LRSResponse> updateActivityProfile(ActivityProfileDocument profile);

  Future<LRSResponse> deleteActivityProfile(ActivityProfileDocument profile);

  Future<LRSResponse<Person>> retrievePerson(Agent agent);

  Future<LRSResponse<List<String>>> retrieveAgentProfileIds(Agent agent);

  Future<LRSResponse<AgentProfileDocument>> retrieveAgentProfile(
      String id, Agent agent);

  Future<LRSResponse> saveAgentProfile(AgentProfileDocument profile);

  Future<LRSResponse> updateAgentProfile(AgentProfileDocument profile);

  Future<LRSResponse> deleteAgentProfile(AgentProfileDocument profile);
}
