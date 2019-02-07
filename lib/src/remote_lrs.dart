import 'dart:convert';
import 'dart:io';

import 'package:TinCanDart/src/about.dart';
import 'package:TinCanDart/src/activity.dart';
import 'package:TinCanDart/src/activity_profile_document.dart';
import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/agent_profile_document.dart';
import 'package:TinCanDart/src/attachment.dart';
import 'package:TinCanDart/src/document.dart';
import 'package:TinCanDart/src/lrs.dart';
import 'package:TinCanDart/src/lrs_response.dart';
import 'package:TinCanDart/src/multipart_helper.dart';
import 'package:TinCanDart/src/person.dart';
import 'package:TinCanDart/src/state_document.dart';
import 'package:TinCanDart/src/statement.dart';
import 'package:TinCanDart/src/statements_query.dart';
import 'package:TinCanDart/src/statements_result.dart';
import 'package:TinCanDart/src/versions.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';

/// Class used to communicate with a TinCan API endpoint
class RemoteLRS extends LRS {
  final Uri endpoint;
  final Version _version;

  //final String basicAuth;
  final String auth;
  final Map extended;
  final bool prettyJson;

  final http.Client _client;

  RemoteLRS({
    this.endpoint,
    Version version,
    String username,
    String password,
    //this.auth,
    this.extended,
    this.prettyJson = false,
    http.Client client,
  })  : _client = client ?? http.Client(),
        auth = generateAuth(username, password),
        _version = version ?? TinCanVersion.latest();

  /*
  final String version;
  final String url;
  final String method;
  final Map<String, dynamic> params;
  final dynamic data;
  final Map<String, dynamic> headers;
  final Function callback;
  final bool ignore404;
  final bool expectMultipart;

  RemoteLRS({
    this.version,
    this.url,
    this.method,
    this.params,
    this.data,
    this.headers,
    this.callback,
    this.ignore404,
    this.expectMultipart,
  });
  */

  @override
  Future<LRSResponse> deleteAgentProfile(AgentProfileDocument profile) async {
    final params = {
      'profileId': profile.id,
      'agent': _agentToString(profile.agent),
    };

    return await _deleteDocument("agents/profile", params);
  }

  @override
  Future<LRSResponse> updateAgentProfile(AgentProfileDocument profile) async {
    final params = {
      'profileId': profile.id,
      'agent': _agentToString(profile.agent),
    };

    return await _updateDocument("agents/profile", params, profile);
  }

  @override
  Future<LRSResponse> saveAgentProfile(AgentProfileDocument profile) async {
    final params = {
      'profileId': profile.id,
      'agent': _agentToString(profile.agent),
    };

    return await _saveDocument("agents/profile", params, profile);
  }

  @override
  Future<LRSResponse<AgentProfileDocument>> retrieveAgentProfile(
      String id, Agent agent) async {
    final params = {
      'profileId': id,
      'agent': _agentToString(agent),
    };

    final document = AgentProfileDocument(
      id: id,
      agent: agent,
    );
    return await _getAgentProfileDocument('agents/profile', params, document);
    /*
        HashMap<String, String> queryParams = new HashMap<String, String>();
        queryParams.put("profileId", id);
        queryParams.put("agent", agent.toJSON(this.getVersion(), this.usePrettyJSON()));

        AgentProfileDocument profileDocument = new AgentProfileDocument();
        profileDocument.setId(id);
        profileDocument.setAgent(agent);

        LRSResponse lrsResp = getDocument("agents/profile", queryParams, profileDocument);

        AgentProfileLRSResponse lrsResponse = new AgentProfileLRSResponse(lrsResp.getRequest(), lrsResp.getResponse());
        lrsResponse.setSuccess(lrsResp.getSuccess());

        if (lrsResponse.getResponse().getStatus() == 200) {
            lrsResponse.setContent(profileDocument);
        }

        return lrsResponse;
     */
  }

  @override
  Future<LRSResponse<List<String>>> retrieveAgentProfileIds(Agent agent) async {
    final params = {
      'agent': _agentToString(agent),
    };
    return _getProfileKeys("agents/profile", params);
  }

  @override
  Future<LRSResponse<Person>> retrievePerson(Agent agent) async {
    final params = {
      'agent': _agentToString(agent),
    };
    final response = await _makeRequest('agents', 'GET', queryParams: params);
    if (response?.statusCode == 200) {
      print(response.body);
      return LRSResponse<Person>(
          success: true, data: Person.fromJson(json.decode(response.body)));
    } else {
      return LRSResponse(success: false, errMsg: response?.body);
    }
    /*
      HTTPRequest request = new HTTPRequest();
        request.setMethod(HttpMethod.GET.asString());
        request.setResource("agents");
        request.setQueryParams(new HashMap<String, String>());
        request.getQueryParams().put("agent", agent.toJSON(this.getVersion(), this.usePrettyJSON()));

        HTTPResponse response = makeSyncRequest(request);
        int status = response.getStatus();

        PersonLRSResponse lrsResponse = new PersonLRSResponse(request, response);

        if (status == 200) {
            lrsResponse.setSuccess(true);
            try {
                lrsResponse.setContent(new Person(new StringOfJSON(response.getContent())));
            } catch (Exception ex) {
                lrsResponse.setErrMsg("Exception: " + ex.toString());
                lrsResponse.setSuccess(false);
            }
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;
     */
  }

  @override
  Future<LRSResponse> deleteActivityProfile(ActivityProfileDocument profile) {
    final params = {
      'profileId': profile.id,
      'activityId': profile.activity.id.toString(),
    };
    return _deleteDocument("activities/profile", params);
  }

  @override
  Future<LRSResponse> updateActivityProfile(ActivityProfileDocument profile) {
    return null;
  }

  @override
  Future<LRSResponse> saveActivityProfile(ActivityProfileDocument profile) {
    final params = {
      'profileId': profile.id,
      'activityId': profile.activity.id.toString(),
    };
    return _saveDocument("activities/profile", params, profile);
  }

  @override
  Future<LRSResponse<ActivityProfileDocument>> retrieveActivityProfile(
      String id, Activity activity) async {
    final params = {
      'profileId': id,
      'activityId': activity.id.toString(),
    };

    final profileDocument = ActivityProfileDocument(
      id: id,
      activity: activity,
    );

    return await _getActivityProfileDocument(
        "activities/profile", params, profileDocument);

    /*
      HashMap<String, String> queryParams = new HashMap<String, String>();
        queryParams.put("profileId", id);
        queryParams.put("activityId", activity.getId().toString());

        ActivityProfileDocument profileDocument = new ActivityProfileDocument();
        profileDocument.setId(id);
        profileDocument.setActivity(activity);

        LRSResponse lrsResp = getDocument("activities/profile", queryParams, profileDocument);

        ActivityProfileLRSResponse lrsResponse = new ActivityProfileLRSResponse(lrsResp.getRequest(), lrsResp.getResponse());
        lrsResponse.setSuccess(lrsResp.getSuccess());

        if (lrsResponse.getResponse().getStatus() == 200) {
            lrsResponse.setContent(profileDocument);
        }

        return lrsResponse;
     */
  }

  @override
  Future<LRSResponse<List<String>>> retrieveActivityProfileIds(
      Activity activity) async {
    final params = {
      'activityId': activity.id.toString(),
    };
    return _getProfileKeys("activities/profile", params);
  }

  @override
  Future<LRSResponse<Activity>> retrieveActivity(Activity activity) async {
    final params = {
      'activityId': activity.id.toString(),
    };
    final response =
        await _makeRequest('activities', 'GET', queryParams: params);

    if (response?.statusCode == 200) {
      return LRSResponse<Activity>(
        success: true,
        data: Activity.fromJson(json.decode(response.body)),
      );
    } else {
      return LRSResponse(
        success: false,
        errMsg: response?.body,
      );
    }
    /*
       HTTPRequest request = new HTTPRequest();
        request.setMethod(HttpMethod.GET.asString());
        request.setResource("activities");
        request.setQueryParams(new HashMap<String, String>());
        request.getQueryParams().put("activityId", activity.getId().toString());

        HTTPResponse response = makeSyncRequest(request);
        int status = response.getStatus();

        ActivityLRSResponse lrsResponse = new ActivityLRSResponse(request, response);

        if (status == 200) {
            lrsResponse.setSuccess(true);
            try {
                lrsResponse.setContent(new Activity(new StringOfJSON(response.getContent())));
            } catch (Exception ex) {
                lrsResponse.setErrMsg("Exception: " + ex.toString());
                lrsResponse.setSuccess(false);
            }
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;
     */
  }

  @override
  Future<LRSResponse> clearState(Activity activity, Agent agent,
      [Uuid registration]) async {
    final params = {
      'activityId': activity.id.toString(),
      'agent': _agentToString(agent),
    };
    if (registration != null) {
      params['registration'] = registration.toString();
    }
    return await _deleteDocument('activities/state', params);
    /*
          HashMap<String, String> queryParams = new HashMap<String, String>();

        queryParams.put("activityId", activity.getId().toString());
        queryParams.put("agent", agent.toJSON(this.getVersion(), this.usePrettyJSON()));
        if (registration != null) {
            queryParams.put("registration", registration.toString());
        }
        return deleteDocument("activities/state", queryParams);

     */
  }

  @override
  Future<LRSResponse> deleteState(StateDocument state) async {
    final params = {
      'stateId': state.id,
      'activityId': state.activity.id.toString(),
      'agent': _agentToString(state.agent),
    };
    if (state.registration != null) {
      params['registration'] = state.registration.toString();
    }
    return await _deleteDocument('activities/state', params);
  }

  @override
  Future<LRSResponse> updateState(StateDocument state) {
    return null;
  }

  @override
  Future<LRSResponse> saveState(StateDocument state) async {
    final params = {
      'stateId': state.id,
      'activityId': state.activity.id.toString(),
      'agent': _agentToString(state.agent),
    };

    return await _saveDocument('activities/state', params, state);
    /*
      HashMap<String,String> queryParams = new HashMap<String,String>();

        queryParams.put("stateId", state.getId());
        queryParams.put("activityId", state.getActivity().getId().toString());
        queryParams.put("agent", state.getAgent().toJSON(this.getVersion(), this.usePrettyJSON()));

        return saveDocument("activities/state", queryParams, state);
       */
  }

  @override
  Future<LRSResponse<StateDocument>> retrieveState(
      String id, Activity activity, Agent agent, Uuid registration) async {
    final params = {
      'stateId': id,
      'activityId': activity.id.toString(),
      'agent': _agentToString(agent),
    };

    final document = StateDocument(
      id: id,
      activity: activity,
      agent: agent,
    );

    return await _getStateDocument('activities/state', params, document);
    /*
      HashMap<String, String> queryParams = new HashMap<String, String>();
        queryParams.put("stateId", id);
        queryParams.put("activityId", activity.getId().toString());
        queryParams.put("agent", agent.toJSON(this.getVersion(), this.usePrettyJSON()));

        StateDocument stateDocument = new StateDocument();
        stateDocument.setId(id);
        stateDocument.setActivity(activity);
        stateDocument.setAgent(agent);

        LRSResponse lrsResp = getDocument("activities/state", queryParams, stateDocument);

        StateLRSResponse lrsResponse = new StateLRSResponse(lrsResp.getRequest(), lrsResp.getResponse());
        lrsResponse.setSuccess(lrsResp.getSuccess());

        if (lrsResponse.getResponse().getStatus() == 200) {
            lrsResponse.setContent(stateDocument);
        }

        return lrsResponse;
     */
  }

  @override
  Future<LRSResponse<List<String>>> retrieveStateIds(
      Activity activity, Agent agent,
      [Uuid registration]) async {
    final params = {
      'activityId': activity.id.toString(),
      'agent': _agentToString(agent),
    };
    if (registration != null) {
      params['registration'] = registration.toString();
    }
    return await _getProfileKeys('activities/state', params);
  }

  @override
  Future<LRSResponse<StatementsResult>> moreStatements(String moreURL) async {
    if (moreURL == null) {
      return null;
    }

    final port = (endpoint.port == -1) ? '' : ':${endpoint.port}';
    final resource = '${endpoint.scheme}://${endpoint.host}$port$moreURL';
    final response = await _makeRequest(resource, 'GET');

    if (response?.statusCode == 200) {
      final results = StatementsResult.fromJson(json.decode(response?.body));
      return LRSResponse<StatementsResult>(success: true, data: results);
    } else {
      return LRSResponse<StatementsResult>(
          success: false, errMsg: response?.body);
    }
  }

  @override
  Future<LRSResponse<StatementsResult>> queryStatements(
      StatementsQuery query) async {
    final response = await _makeRequest('statements', 'GET',
        queryParams: query.toParameterMap(_version));

    print(response?.statusCode);
    print(response?.body);

    if (response?.statusCode == 200) {
      final result = StatementsResult.fromJson(json.decode(response.body));
      return LRSResponse<StatementsResult>(success: true, data: result);
    } else {
      return LRSResponse<StatementsResult>(
          success: false, errMsg: response?.body);
    }
    /*
        StatementsResultLRSResponse lrsResponse = new StatementsResultLRSResponse();

        lrsResponse.setRequest(new HTTPRequest());
        lrsResponse.getRequest().setMethod(HttpMethod.GET.asString());
        lrsResponse.getRequest().setResource("statements");

        try {
            lrsResponse.getRequest().setQueryParams(query.toParameterMap());
        } catch (IOException ex) {
            lrsResponse.setErrMsg("Exception: " + ex.toString());
            return lrsResponse;
        }

        HTTPResponse response = makeSyncRequest(lrsResponse.getRequest());

        lrsResponse.setResponse(response);
     */
    return null;
  }

  @override
  Future<LRSResponse<Statement>> retrieveVoidedStatement(
      String id, bool attachments) {
    return null;
  }

  @override
  Future<LRSResponse<Statement>> retrieveStatement(String id,
      [bool attachments = false]) async {
    final params = {'statement': id, 'attachments': attachments.toString()};

    final response =
        await _makeRequest('statements', 'GET', queryParams: params);

    if (response?.statusCode == 200) {
      final statement = Statement.fromJson(json.decode(response.body));
      return LRSResponse<Statement>(
        success: true,
        data: statement,
      );
    } else {
      return LRSResponse<Statement>(success: false, errMsg: response?.body);
    }
    /*
        HTTPRequest request = new HTTPRequest();
        request.setMethod(HttpMethod.GET.asString());
        request.setResource("statements");
        request.setQueryParams(params);

        HTTPResponse response = makeSyncRequest(request);
        int status = response.getStatus();

        StatementLRSResponse lrsResponse = new StatementLRSResponse(request, response);

        if (status == 200) {
            lrsResponse.setSuccess(true);
            try {
                JsonNode contentNode = (new StringOfJSON(response.getContent())).toJSONNode();
                if (! (contentNode.findPath("statements").isMissingNode())) {
                    contentNode = contentNode.findPath("statements").get(0);
                }

                Statement stmt = new Statement (contentNode);
                for (Map.Entry<String, byte[]> entry : response.getAttachments().entrySet()) {
                    for (Attachment a : stmt.getAttachments()) {
                        if (entry.getKey().equals(a.getSha2())) {
                            a.setContent(entry.getValue());
                        }
                    }
                }

                lrsResponse.setContent(stmt);
            } catch (Exception ex) {
                lrsResponse.setErrMsg("Exception: " + ex.toString());
                lrsResponse.setSuccess(false);
            }
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;
     */
  }

  @override
  Future<LRSResponse<StatementsResult>> saveStatements(
      List<Statement> statements) async {
    if (statements.length == 0) {
      return LRSResponse<StatementsResult>(success: true);
    }

    final body = json.encode(
        statements.map((statement) => statement.toJson(_version)).toList());
    final attachments = <Attachment>[];
    statements?.forEach((statement) {
      if (statement.attachments?.isNotEmpty == true) {
        attachments.addAll(statement.attachments);
      }
    });
    final response = await _makeRequest('statements', 'POST',
        additionalHeaders: {'content-type': 'application/json'},
        body: body,
        attachments: (attachments.isEmpty) ? null : attachments);
    print('Response status : ${response?.statusCode}');
    print('Response : ${response?.body}');

    if (response?.statusCode == 200) {
      final List ids = json.decode(response.body);
      List<Statement> saved = [];
      for (var ctr = 0; ctr < ids.length; ctr++) {
        saved.add(statements[ctr].copyWith(id: ids[ctr]));
      }
      return LRSResponse<StatementsResult>(
          success: true,
          data: StatementsResult(
            statements: saved,
          ));
    } else {
      return LRSResponse<StatementsResult>(success: false);
    }
    /*
    StatementsResultLRSResponse lrsResponse = new StatementsResultLRSResponse();
        if (statements.size() == 0) {
            lrsResponse.setSuccess(true);
            return lrsResponse;
        }

        ArrayNode rootNode = Mapper.getInstance().createArrayNode();
        for (Statement statement : statements) {
            rootNode.add(statement.toJSONNode(version));
        }

        lrsResponse.setRequest(new HTTPRequest());
        lrsResponse.getRequest().setResource("statements");
        lrsResponse.getRequest().setMethod(HttpMethod.POST.asString());
        lrsResponse.getRequest().setContentType("application/json");
        try {
            lrsResponse.getRequest().setContent(Mapper.getWriter(this.usePrettyJSON()).writeValueAsBytes(rootNode));
        } catch (JsonProcessingException ex) {
            lrsResponse.setErrMsg("Exception: " + ex.toString());
            return lrsResponse;
        }

        lrsResponse.getRequest().setPartList(new ArrayList<HTTPPart>());
        for (Statement statement: statements) {
            if (statement.hasAttachmentsWithContent()) {
                lrsResponse.getRequest().getPartList().addAll(statement.getPartList());
            }
        }

        HTTPResponse response = makeSyncRequest(lrsResponse.getRequest());
        int status = response.getStatus();

        lrsResponse.setResponse(response);

        if (status == 200) {
            lrsResponse.setSuccess(true);
            lrsResponse.setContent(new StatementsResult());
            try {
                Iterator it = Mapper.getInstance().readValue(response.getContent(), ArrayNode.class).elements();
                for (int i = 0; it.hasNext(); ++i) {
                    lrsResponse.getContent().getStatements().add(statements.get(i));
                    lrsResponse.getContent().getStatements().get(i).setId(UUID.fromString(((JsonNode) it.next()).textValue()));
                }
            } catch (Exception ex) {
                lrsResponse.setErrMsg("Exception: " + ex.toString());
                lrsResponse.setSuccess(false);
            }
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;
     */
    return null;
  }

  @override
  Future<LRSResponse<Statement>> saveStatement(Statement statement) async {
    final verb = (statement.id == null) ? 'POST' : 'PUT';
    final params =
        (statement.id == null) ? null : {'statementId': statement.id};

    final body = json.encode(statement.toJson(_version));

    final response = await _makeRequest('statements', verb,
        queryParams: params, body: body, attachments: statement.attachments);
    print(response?.statusCode);
    dynamic responseBody;
    if (response.runtimeType.toString() == 'StreamedResponse') {
      http.StreamedResponse streamedResponse = response;
      final data = await streamedResponse.stream.bytesToString();
      responseBody = data;
    } else {
      responseBody = response?.body;
    }

    if (response?.statusCode == 200) {
      return LRSResponse<Statement>(
        success: true,
        data: statement.copyWith(
          id: json.decode(responseBody)[0],
        ),
      );
    } else if (response?.statusCode == 204) {
      return LRSResponse<Statement>(
        success: true,
        data: statement,
      );
    } else {
      return LRSResponse<Statement>(success: false, errMsg: responseBody);
    }
  }

  @override
  Future<LRSResponse<About>> about() async {
    final response = await _makeRequest('about', 'GET');
    print(response?.statusCode);
    print(response?.body);

    if (response?.statusCode == 200) {
      return LRSResponse<About>(
        success: true,
        data: About.fromJson(
          json.decode(response?.body),
        ),
      );
    } else {
      return LRSResponse<About>(success: false, errMsg: response?.body);
    }
  }

  static String generateAuth(String username, String password) {
    if (username?.isNotEmpty == true && password?.isNotEmpty == true) {
      final token = base64Encode(utf8.encode('$username:$password'));
      return 'Basic $token';
    } else {
      return null;
    }
  }

// Make request (probably async)
  Future _makeRequest(
    String resource,
    String verb, {
    Map<String, String> queryParams,
    Map<String, String> additionalHeaders,
    body: dynamic,
    List<Attachment> attachments,
  }) async {
    // resource, endpoint (from this), query parameters, headers
    String url = (resource.startsWith('http'))
        ? resource
        : '${this.endpoint}${resource}';

    if (queryParams?.isNotEmpty == true) {
      url += '?' +
          queryParams.entries
              .map((entry) =>
                  '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
              .join('&');
    }

    Map<String, String> headers = {};
    if (additionalHeaders?.isNotEmpty == true) {
      headers.addAll(additionalHeaders);
    }

    if (!headers.containsKey('content-type')) {
      headers['content-type'] = 'application/json';
    }

    final version = TinCanVersion.toJsonString(_version);
    headers['X-Experience-API-Version'] = version;
    if (this.auth != null) {
      headers['Authorization'] = this.auth;
    }

    print(url);

    if (attachments?.isNotEmpty == true) {
      final boundary = MultipartHelper.generateBoundaryString();
      headers.remove('content-type');
      headers['Content-Type'] = 'multipart/mixed; boundary=$boundary';
      final streamedRequest =
          http.StreamedRequest(verb.toUpperCase(), Uri.parse(url))
            ..headers.addAll(headers);

      streamedRequest.sink.add(utf8.encode('--$boundary\r\n'));
      streamedRequest.sink
          .add(utf8.encode('Content-Type: application/json\r\n\r\n'));
      streamedRequest.sink.add(utf8.encode('$body\r\n'));

      attachments?.forEach((attachment) {
        final contentType = MediaType.parse(
            attachment.contentType ?? 'application/octet-stream');

        // Write boundary
        streamedRequest.sink.add(utf8.encode('--$boundary\r\n'));
        // Write headers
        final hash = 'X-Experience-API-Hash: ${attachment.sha2}';
        var header =
            'Content-Type: $contentType\r\nContent-Transfer-Encoding: binary;\r\n$hash';

        streamedRequest.sink.add(utf8.encode('$header\r\n\r\n'));
        streamedRequest.sink.add(attachment.content.asInt8List());
      });

      // Closing boundary line
      streamedRequest.sink.add(utf8.encode('\r\n--$boundary--\r\n'));
      streamedRequest.sink.close();

      return await streamedRequest.send();
    } else {
      var response;
      switch (verb.toUpperCase()) {
        case 'GET':
          response = _client.get(url, headers: headers);
          break;
        case 'POST':
          response = _client.post(url, headers: headers, body: body);
          break;
        case 'PUT':
          response = _client.put(url, headers: headers, body: body);
          break;
        case 'DELETE':
          response = _client.delete(url, headers: headers);
          break;
        case 'PATCH':
          response = _client.patch(url, headers: headers, body: body);
          break;
      }

      return response;
    }
  }

  String _agentToString(Agent agent) {
    return json.encode(agent.toJson(_version));
  }

  Future<LRSResponse<List<String>>> _getProfileKeys(
      String resource, Map<String, String> params) async {
    final response = await _makeRequest(resource, 'GET', queryParams: params);
    //print('Response : ${response?.body}');
    if (response?.statusCode == 200) {
      final List<dynamic> data = json.decode(response?.body);
      return LRSResponse<List<String>>(
          success: true, data: data.cast<String>());
    } else {
      return LRSResponse<List<String>>(success: false, errMsg: response?.body);
    }
    /*
          HTTPRequest request = new HTTPRequest();
        request.setMethod(HttpMethod.GET.asString());
        request.setResource(resource);
        request.setQueryParams(queryParams);

        HTTPResponse response = makeSyncRequest(request);

        ProfileKeysLRSResponse lrsResponse = new ProfileKeysLRSResponse(request, response);

        if (response.getStatus() == 200) {
            lrsResponse.setSuccess(true);
            try {
                Iterator it = Mapper.getInstance().readValue(response.getContent(), ArrayNode.class).elements();

                lrsResponse.setContent(new ArrayList<String>());
                while (it.hasNext()) {
                    lrsResponse.getContent().add(it.next().toString());
                }
            } catch (Exception ex) {
                lrsResponse.setErrMsg("Exception: " + ex.toString());
                lrsResponse.setSuccess(false);
            }
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;
     */
  }

  Future<LRSResponse> _deleteDocument(
      String resource, Map<String, String> params) async {
    final response =
        await _makeRequest(resource, 'DELETE', queryParams: params);
    return LRSResponse(success: (response?.statusCode == 204));
    /*
      HTTPRequest request = new HTTPRequest();

        request.setMethod(HttpMethod.DELETE.asString());
        request.setResource(resource);
        request.setQueryParams(queryParams);

        HTTPResponse response = makeSyncRequest(request);

        LRSResponse lrsResponse = new LRSResponse(request, response);

        if (response.getStatus() == 204) {
            lrsResponse.setSuccess(true);
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;
     */
  }

  Future<LRSResponse> _saveDocument(
      String resource, Map<String, String> params, Document document) async {
    final headers = {
      'content-type': document.contentType ?? 'application/octet-stream',
    };
    if (document.etag != null) {
      headers['If-Match'] = document.etag;
    }
    final response = await _makeRequest(resource, 'PUT',
        queryParams: params,
        additionalHeaders: headers,
        body: document.content?.asInt8List());

    print("Response : ${response?.body}");
    return LRSResponse(success: response?.statusCode == 204);
    /*
         HTTPRequest request = new HTTPRequest();
        request.setMethod(HttpMethod.PUT.asString());
        request.setResource(resource);
        request.setQueryParams(queryParams);
        request.setContentType(document.getContentType());
        request.setContent(document.getContent());
        if (document.getEtag() != null) {
            request.setHeaders(new HashMap<String, String>());
            request.getHeaders().put("If-Match", document.getEtag());
        }

        HTTPResponse response = makeSyncRequest(request);

        LRSResponse lrsResponse = new LRSResponse(request, response);

        if (response.getStatus() == 204) {
            lrsResponse.setSuccess(true);
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;

     */
  }

  Future<LRSResponse<StateDocument>> _getStateDocument(String resource,
      Map<String, String> params, StateDocument document) async {
    final response = await _makeRequest(resource, 'GET', queryParams: params);
    if (response?.statusCode == 200) {
      final data = StateDocument(
        id: document.id,
        agent: document.agent,
        activity: document.activity,
        contentType: response.headers[HttpHeaders.contentTypeHeader],
        content: response.bodyBytes.buffer,
        registration: document.registration,
        etag: response.headers[HttpHeaders.etagHeader],
        timestamp:
            DateTime.tryParse(response.headers[HttpHeaders.lastModifiedHeader]),
      );
      return LRSResponse<StateDocument>(success: true, data: data);
    } else if (response?.statusCode == 404) {
      return LRSResponse<StateDocument>(success: true, data: document);
    } else {
      return LRSResponse<StateDocument>(success: false, errMsg: response?.body);
    }
  }

  Future<LRSResponse<AgentProfileDocument>> _getAgentProfileDocument(
      String resource,
      Map<String, String> params,
      AgentProfileDocument document) async {
    final response = await _makeRequest(resource, 'GET', queryParams: params);
    if (response?.statusCode == 200) {
      final data = AgentProfileDocument(
        id: document.id,
        agent: document.agent,
        contentType: response.headers[HttpHeaders.contentTypeHeader],
        content: response.bodyBytes.buffer,
        etag: response.headers[HttpHeaders.etagHeader],
        timestamp:
            DateTime.tryParse(response.headers[HttpHeaders.lastModifiedHeader]),
      );
      return LRSResponse<AgentProfileDocument>(success: true, data: data);
    } else {
      return LRSResponse(success: false, errMsg: response?.body);
    }
  }

  Future<LRSResponse<ActivityProfileDocument>> _getActivityProfileDocument(
      String resource,
      Map<String, String> params,
      ActivityProfileDocument document) async {
    final response = await _makeRequest(resource, 'GET', queryParams: params);
    if (response?.statusCode == 200) {
      final data = ActivityProfileDocument(
        id: document.id,
        activity: document.activity,
        contentType: response.headers[HttpHeaders.contentTypeHeader],
        content: response.bodyBytes.buffer,
        etag: response.headers[HttpHeaders.etagHeader],
        timestamp:
            DateTime.tryParse(response.headers[HttpHeaders.lastModifiedHeader]),
      );
      return LRSResponse<ActivityProfileDocument>(success: true, data: data);
    } else {
      return LRSResponse(success: false, errMsg: response?.body);
    }
  }

  Future<LRSResponse> _updateDocument(
      String resource, Map<String, String> params, Document document) async {
    Map<String, String> headers;
    if (document.etag != null) {
      headers = {'If-Match': document.etag};
    }
    final response = await _makeRequest(resource, 'POST',
        queryParams: params, additionalHeaders: headers);
    if (response?.statusCode == 204) {
      return LRSResponse(success: true);
    } else {
      return LRSResponse(success: false, errMsg: response?.body);
    }
    /*
      HTTPRequest request = new HTTPRequest();
        request.setMethod(HttpMethod.POST.asString());
        request.setResource(resource);
        request.setQueryParams(queryParams);
        request.setContentType(document.getContentType());
        request.setContent(document.getContent());
        if (document.getEtag() != null) {
            request.setHeaders(new HashMap<String, String>());
            request.getHeaders().put("If-Match", document.getEtag());
        }

        HTTPResponse response = makeSyncRequest(request);

        LRSResponse lrsResponse = new LRSResponse(request, response);

        if (response.getStatus() == 204) {
            lrsResponse.setSuccess(true);
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;
     */
  }
/*
      HTTPRequest request = new HTTPRequest();
        request.setMethod(HttpMethod.GET.asString());
        request.setResource(resource);
        request.setQueryParams(queryParams);

        HTTPResponse response = makeSyncRequest(request);

        LRSResponse lrsResponse = new LRSResponse(request, response);

        if (response.getStatus() == 200) {
            document.setContent(response.getContentBytes());
            document.setContentType(response.getContentType());
            document.setTimestamp(response.getLastModified());
            document.setEtag(response.getEtag());
            lrsResponse.setSuccess(true);
        }
        else if (response.getStatus() == 404) {
            lrsResponse.setSuccess(true);
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;    
 */
}

/*

    private HTTPResponse makeSyncRequest(HTTPRequest req) {
        String url;

        if (req.getResource().toLowerCase().startsWith("http")) {
            url = req.getResource();
        }
        else {
            url = this.endpoint.toString();
            if (! url.endsWith("/") && ! req.getResource().startsWith("/")) {
                url += "/";
            }
            url += req.getResource();
        }

        if (req.getQueryParams() != null) {
            String qs = "";
            Iterator it = req.getQueryParams().entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry entry = (Map.Entry) it.next();
                if (qs != "") {
                    qs += "&";
                }
                try {
                    qs += URLEncoder.encode(entry.getKey().toString(), "UTF-8") + "=" + URLEncoder.encode(entry.getValue().toString(), "UTF-8");
                } catch (UnsupportedEncodingException ex) {}
            }
            if (qs != "") {
                url += "?" + qs;
            }
        }


        final HTTPResponse response = new HTTPResponse();

        try {
            final Request webReq = httpClient().
                newRequest(url).
                method(HttpMethod.fromString(req.getMethod())).
                header("X-Experience-API-Version", this.version.toString());

            if (this.auth != null) {
                webReq.header("Authorization", this.auth);
            }
            if (req.getHeaders() != null) {
                Iterator it = req.getHeaders().entrySet().iterator();
                while (it.hasNext()) {
                    Map.Entry entry = (Map.Entry) it.next();
                    webReq.header(entry.getKey().toString(), entry.getValue().toString());
                }
            }

            OutputStreamContentProvider content = new OutputStreamContentProvider();
            FutureResponseListener listener = new FutureResponseListener(webReq);

            try (OutputStream output = content.getOutputStream()) {
                if (req.getPartList() == null || req.getPartList().size() <= 0) {
                    if (req.getContentType() != null) {
                        webReq.header("Content-Type", req.getContentType());
                    }
                    else if (req.getMethod() != "GET") {
                        webReq.header("Content-Type", "application/octet-stream");
                    }

                    webReq.content(content).send(listener);

                    if (req.getContent() != null) {
                        output.write(req.getContent());
                    }

                    output.close();
                }
                else {
                    MultiPartOutputStream multiout = new MultiPartOutputStream(output);

                    webReq.header("Content-Type", "multipart/mixed; boundary=" + multiout.getBoundary());
                    webReq.content(content).send(listener);

                    if (req.getContentType() != null) {
                        multiout.startPart(req.getContentType());
                    }
                    else {
                        multiout.startPart("application/octet-stream");
                    }

                    if (req.getContent() != null) {
                        multiout.write(req.getContent());
                    }

                    for (HTTPPart part : req.getPartList()) {
                        multiout.startPart(part.getContentType(), new String[]{
                            "Content-Transfer-Encoding: binary",
                            "X-Experience-API-Hash: " + part.getSha2()
                        });
                        multiout.write(part.getContent());
                    }
                    multiout.close();
                }
            }

            ContentResponse httpResponse = listener.get();

            response.setStatus(httpResponse.getStatus());
            response.setStatusMsg(httpResponse.getReason());
            for (HttpField header : httpResponse.getHeaders()) {
                response.setHeader(header.getName(), header.getValue());
            }

            if (response.getContentType() != null && response.getContentType().contains("multipart/mixed")) {
                String boundary = response.getContentType().split("boundary=")[1];

                MultipartParser responseHandler = new MultipartParser(listener.getContent(), boundary);
                ArrayList<Statement> statements = new ArrayList<Statement>();

                for (int i = 1; i < responseHandler.getSections().size(); i++) {
                    responseHandler.parsePart(i);

                    if (i == 1) {
                        if (responseHandler.getHeaders().get("Content-Type").contains("application/json")) {
                            JsonNode statementsNode = (new StringOfJSON(new String(responseHandler.getContent())).toJSONNode());
                            if (statementsNode.findPath("statements").isMissingNode()) {
                                statements.add(new Statement(statementsNode));
                            } else {
                                statementsNode = statementsNode.findPath("statements");
                                for (JsonNode obj : statementsNode) {
                                    statements.add(new Statement(obj));
                                }
                            }
                        } else {
                            throw new Exception("The first part of this response had a Content-Type other than \"application/json\"");
                        }
                    }
                    else {
                        response.setAttachment(responseHandler.getHeaders().get("X-Experience-API-Hash"), responseHandler.getContent());
                    }
                }
                StatementsResult responseStatements = new StatementsResult();
                responseStatements.setStatements(statements);
                response.setContentBytes(responseStatements.toJSONNode(TCAPIVersion.V101).toString().getBytes());
            }
            else {
                response.setContentBytes(listener.getContent());
            }
        } catch (Exception ex) {
            response.setStatus(400);
            response.setStatusMsg("Exception in RemoteLRS.makeSyncRequest(): " + ex);
        }

        return response;
    }
   */
