import 'package:TinCanDart/src/about.dart';
import 'package:TinCanDart/src/activity.dart';
import 'package:TinCanDart/src/activity_profile_document.dart';
import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/agent_profile_document.dart';
import 'package:TinCanDart/src/lrs_response.dart';
import 'package:TinCanDart/src/person.dart';
import 'package:TinCanDart/src/state.dart';
import 'package:TinCanDart/src/state_document.dart';
import 'package:TinCanDart/src/statement.dart';
import 'package:TinCanDart/src/statements_query.dart';
import 'package:TinCanDart/src/statements_result.dart';
import 'package:uuid/uuid.dart';

abstract class LRS {
  Future<LRSResponse<About>> about();

  Future<LRSResponse<Statement>> saveStatement(Statement statement);

  Future<LRSResponse<StatementsResult>> saveStatements(
      List<Statement> statements);

  //Future<LRSResponse<Statement>> retrieveStatement(String id);

  //Future<LRSResponse<Statement>> retrieveVoidedStatement(String id);

  Future<LRSResponse<Statement>> retrieveStatement(String id, bool attachments);

  Future<LRSResponse<Statement>> retrieveVoidedStatement(
      String id, bool attachments);

  Future<LRSResponse<StatementsResult>> queryStatements(StatementsQuery query);

  Future<LRSResponse<StatementsResult>> moreStatements(String moreURL);

  Future<LRSResponse<List<String>>> retrieveStateIds(
      Activity activity, Agent agent, Uuid registration);

  Future<LRSResponse<State>> retrieveState(
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
