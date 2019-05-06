import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import './about.dart';
import './activity.dart';
import './activity_profile_document.dart';
import './agent.dart';
import './agent_profile_document.dart';
import './attachment.dart';
import './attachment_content.dart';
import './document.dart';
import './lrs.dart';
import './lrs_response.dart';
import './multipart_mixed_request.dart';
import './person.dart';
import './state_document.dart';
import './statement.dart';
import './statements_query.dart';
import './statements_result.dart';
import './validated_uri.dart';
import './versions.dart';

const contentTypeHeader = 'content-type';
const etagHeader = 'etag';
const lastModifiedHeader = 'last-modified';

/// Class used to communicate with a TinCan API endpoint
class RemoteLRS extends LRS {
  final ValidatedUri endpoint;
  final Version _version;

  final String auth;
  final Map extended;
  final bool prettyJson;

  final http.Client _client;

  RemoteLRS({
    dynamic endpoint,
    String username,
    String password,
    Version version,
    this.extended,
    this.prettyJson = false,
    http.Client client,
  })  : this.endpoint = ValidatedUri.fromString(endpoint?.toString(),
            appendTrailingSlash: true),
        _client = client ?? http.Client(),
        auth = generateAuth(username, password),
        _version = version ?? TinCanVersion.latest();

  @override
  Future<LRSResponse> deleteAgentProfile(AgentProfileDocument profile) async {
    final params = {
      'profileId': profile.id,
      'agent': _agentToString(profile.agent),
    };

    return await _deleteDocument('agents/profile', params);
  }

  @override
  Future<LRSResponse> updateAgentProfile(AgentProfileDocument profile) async {
    final params = {
      'profileId': profile.id,
      'agent': _agentToString(profile.agent),
    };

    return await _updateDocument('agents/profile', params, profile);
  }

  @override
  Future<LRSResponse> saveAgentProfile(AgentProfileDocument profile) async {
    final params = {
      'profileId': profile.id,
      'agent': _agentToString(profile.agent),
    };

    return await _saveDocument('agents/profile', params, profile);
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
  }

  @override
  Future<LRSResponse<List<String>>> retrieveAgentProfileIds(Agent agent,
      {DateTime since}) async {
    final params = {
      'agent': _agentToString(agent),
    };
    if (since != null) {
      params['since'] = since.toIso8601String();
    }
    return _getProfileKeys('agents/profile', params);
  }

  @override
  Future<LRSResponse<Person>> retrievePerson(Agent agent) async {
    final params = {
      'agent': _agentToString(agent),
    };
    final response = await _makeRequest('agents', 'GET', queryParams: params);
    if (response?.statusCode == 200) {
      //print(response.body);
      return LRSResponse<Person>(
          success: true, data: Person.fromJson(json.decode(response.body)));
    } else {
      return LRSResponse(success: false, errMsg: response?.body);
    }
  }

  @override
  Future<LRSResponse> deleteActivityProfile(ActivityProfileDocument profile) {
    final params = {
      'profileId': profile.id,
      'activityId': profile.activity.id.toString(),
    };
    return _deleteDocument('activities/profile', params);
  }

  @override
  Future<LRSResponse> updateActivityProfile(ActivityProfileDocument profile) {
    final params = {
      'profileId': profile.id,
      'activityId': profile.activity.id.toString(),
    };

    return _updateDocument('activities/profile', params, profile);
  }

  @override
  Future<LRSResponse> saveActivityProfile(ActivityProfileDocument profile) {
    final params = {
      'profileId': profile.id,
      'activityId': profile.activity.id.toString(),
    };
    return _saveDocument('activities/profile', params, profile);
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
        'activities/profile', params, profileDocument);
  }

  @override
  Future<LRSResponse<List<String>>> retrieveActivityProfileIds(
      Activity activity) async {
    final params = {
      'activityId': activity.id.toString(),
    };
    return _getProfileKeys('activities/profile', params);
  }

  @override
  Future<LRSResponse<Activity>> retrieveActivity(String id) async {
    final params = {
      'activityId': id,
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
  }

  @override
  Future<LRSResponse> clearState(Activity activity, Agent agent,
      {String registration}) async {
    final params = {
      'activityId': activity.id.toString(),
      'agent': _agentToString(agent),
    };
    if (registration != null) {
      params['registration'] = registration;
    }
    return await _deleteDocument('activities/state', params);
  }

  @override
  Future<LRSResponse> deleteState(StateDocument state) async {
    final params = {
      'stateId': state.id,
      'activityId': state.activity.id.toString(),
      'agent': _agentToString(state.agent),
    };
    if (state.registration != null) {
      params['registration'] = state.registration;
    }
    return await _deleteDocument('activities/state', params);
  }

  @override
  Future<LRSResponse> updateState(StateDocument state) {
    final params = {
      'stateId': state.id,
      'activityId': state.activity.id.toString(),
      'agent': _agentToString(state.agent),
    };
    if (state.registration != null) {
      params['registration'] = state.registration;
    }

    return _updateDocument('activities/state', params, state);
  }

  @override
  Future<LRSResponse> saveState(StateDocument state) async {
    final params = {
      'stateId': state.id,
      'activityId': state.activity.id.toString(),
      'agent': _agentToString(state.agent),
    };
    if (state.registration != null) {
      params['registration'] = state.registration;
    }

    return await _saveDocument('activities/state', params, state);
  }

  @override
  Future<LRSResponse<StateDocument>> retrieveState(
      String id, Activity activity, Agent agent,
      {String registration}) async {
    final params = {
      'stateId': id,
      'activityId': activity.id.toString(),
      'agent': _agentToString(agent),
    };
    if (registration != null) {
      params['registration'] = registration;
    }

    final document = StateDocument(
      id: id,
      activity: activity,
      agent: agent,
      registration: registration,
    );

    return await _getStateDocument('activities/state', params, document);
  }

  @override
  Future<LRSResponse<List<String>>> retrieveStateIds(
      Activity activity, Agent agent,
      {String registration, DateTime since}) async {
    final params = {
      'activityId': activity.id.toString(),
      'agent': _agentToString(agent),
    };
    if (registration != null) {
      params['registration'] = registration;
    }
    if (since != null) {
      params['since'] = since.toIso8601String();
    }

    return await _getProfileKeys('activities/state', params);
  }

  @override
  Future<LRSResponse<StatementsResult>> moreStatements(String moreURL) async {
    if (moreURL == null) {
      return null;
    }

    final port = (endpoint.asUri.port == -1) ? '' : ':${endpoint.asUri.port}';
    final resource =
        '${endpoint.asUri.scheme}://${endpoint.asUri.host}$port$moreURL';
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

    dynamic responseBody;
    if (response.runtimeType.toString() == 'StreamedResponse') {
      http.StreamedResponse streamedResponse = response;
      final data = await streamedResponse.stream.bytesToString();
      responseBody = data;
    } else {
      responseBody = response?.body;
    }
    //print('Response : $responseBody');

    if (response?.statusCode == 200) {
      if (response.headers[contentTypeHeader]?.startsWith('multipart/mixed;') ==
          true) {
        // Parse mixed data
        final contentType = response.headers[contentTypeHeader];
        //print(contentType);
        //print(response.body);
        final boundary = contentType.split('boundary=')[1];
        //print('boundary - $boundary');
        final statement =
            Statement.fromMixedMultipart(boundary, response.bodyBytes);
        return LRSResponse<StatementsResult>(
          success: true,
          data: StatementsResult(
            statements: statement,
          ),
        );
      } else {
        final decoded = json.decode(responseBody);
        return LRSResponse<StatementsResult>(
          success: true,
          data: StatementsResult.fromJson(decoded),
        );
      }
    } else {
      return LRSResponse<StatementsResult>(
          success: false, errMsg: response?.body);
    }
  }

  @override
  Future<LRSResponse<Statement>> retrieveVoidedStatement(String id,
      [bool attachments = false]) {
    final paramName =
        (_version == Version.V095) ? 'statementId' : 'voidedStatementId';
    final params = {
      paramName: id,
      'attachments': attachments.toString(),
    };

    return _getStatement(params);
  }

  @override
  Future<LRSResponse<Statement>> retrieveStatement(String id,
      [bool attachments = false]) async {
    final params = {
      'statementId': id,
      'attachments': attachments.toString(),
    };

    return _getStatement(params);
  }

  @override
  Future<LRSResponse<StatementsResult>> saveStatements(
      List<Statement> statements) async {
    if (statements.isEmpty) {
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
        additionalHeaders: {contentTypeHeader: 'application/json'},
        body: body,
        attachments: (attachments.isEmpty) ? null : attachments);
    //print('Response status : ${response?.statusCode}');
    //print('headers: ${response?.headers}');

    dynamic responseBody;
    if (response.runtimeType.toString() == 'StreamedResponse') {
      http.StreamedResponse streamedResponse = response;
      final data = await streamedResponse.stream.bytesToString();
      responseBody = data;
    } else {
      responseBody = response?.body;
    }
    //print('Response : $responseBody');

    if (response?.statusCode == 200) {
      final List ids = json.decode(responseBody);
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
  }

  @override
  Future<LRSResponse<Statement>> saveStatement(Statement statement) async {
    final verb = (statement.id == null) ? 'POST' : 'PUT';
    final params =
        (statement.id == null) ? null : {'statementId': statement.id};

    final body = json.encode(statement.toJson(_version));

    final response = await _makeRequest('statements', verb,
        queryParams: params, body: body, attachments: statement.attachments);
    //print(response?.statusCode);
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
    //print(response?.statusCode);
    //print(response?.body);

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

  Future _makeRequest(
    String resource,
    String verb, {
    Map<String, String> queryParams,
    Map<String, String> additionalHeaders,
    dynamic body,
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
    //print('verb - $verb');
    //print('url - $url');

    Map<String, String> headers = {};
    if (additionalHeaders?.isNotEmpty == true) {
      headers.addAll(additionalHeaders);
    }

    if (!headers.containsKey(contentTypeHeader)) {
      headers[contentTypeHeader] = 'application/json';
    }

    final version = TinCanVersion.toJsonString(_version);
    headers['X-Experience-API-Version'] = version;
    if (this.auth != null) {
      headers['Authorization'] = this.auth;
    }

    //print(url);

    if (attachments?.isNotEmpty == true) {
      final request =
          MultipartMixedRequest(verb.toUpperCase(), Uri.parse(url), body);
      request.headers.addAll(headers);
      request.attachments.addAll(attachments);
      return await request.send();
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
    final map = agent.toJson(_version);
    map.remove('objectType');
    return json.encode(map);
  }

  Future<LRSResponse<List<String>>> _getProfileKeys(
      String resource, Map<String, String> params) async {
    final response = await _makeRequest(resource, 'GET', queryParams: params);
    //print('Response : ${response?.body}');
    //print('headers : ${response?.headers}');
    if (response?.statusCode == 200) {
      final List<dynamic> data = json.decode(response?.body);
      return LRSResponse<List<String>>(
          success: true, data: data.cast<String>());
    } else {
      return LRSResponse<List<String>>(success: false, errMsg: response?.body);
    }
  }

  Future<LRSResponse> _deleteDocument(
      String resource, Map<String, String> params) async {
    final response =
        await _makeRequest(resource, 'DELETE', queryParams: params);
    if (response?.statusCode == 204) {
      return LRSResponse(success: true);
    } else {
      return LRSResponse(success: false, errMsg: response?.body);
    }
  }

  Future<LRSResponse> _saveDocument(
      String resource, Map<String, String> params, Document document) async {
    final headers = {
      contentTypeHeader: document.contentType ?? 'application/octet-stream',
    };
    if (document.etag != null) {
      headers['If-Match'] = document.etag;
    } else {
      headers['If-None-Match'] = '*';
    }

    final response = await _makeRequest(resource, 'PUT',
        queryParams: params,
        additionalHeaders: headers,
        body: document.content?.asList());

    //print('Response : ${response?.statusCode}');
    //print('Response : ${response?.body}');
    //print('headers: ${response?.headers}');

    if (response?.statusCode == 204) {
      return LRSResponse(success: true);
    } else {
      if ((response?.body != null && response?.body != 'null') ||
          response?.statusCode != 412) {
        return LRSResponse(success: false, errMsg: response?.body);
      } else {
        return LRSResponse(success: false, errMsg: 'Conflict');
      }
    }
  }

  Future<LRSResponse<StateDocument>> _getStateDocument(String resource,
      Map<String, String> params, StateDocument document) async {
    final response = await _makeRequest(resource, 'GET', queryParams: params);
    if (response?.statusCode == 200) {
      final data = StateDocument(
        id: document.id,
        agent: document.agent,
        activity: document.activity,
        contentType: response.headers[contentTypeHeader],
        content: AttachmentContent.fromUint8List(response.bodyBytes),
        registration: document.registration,
        etag: (response.headers[etagHeader] as String)?.replaceAll('"', ''),
        timestamp: response.headers[lastModifiedHeader] == null
            ? null
            : DateTime.tryParse(response.headers[lastModifiedHeader]),
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
        contentType: response.headers[contentTypeHeader],
        content: AttachmentContent.fromUint8List(response.bodyBytes),
        etag: (response.headers[etagHeader] as String)?.replaceAll('"', ''),
        timestamp: response.headers[lastModifiedHeader] == null
            ? null
            : DateTime.tryParse(response.headers[lastModifiedHeader]),
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
        contentType: response.headers[contentTypeHeader],
        content: AttachmentContent.fromUint8List(response.bodyBytes),
        etag: (response.headers[etagHeader] as String)?.replaceAll('"', ''),
        timestamp: response.headers[lastModifiedHeader] == null
            ? null
            : DateTime.tryParse(response.headers[lastModifiedHeader]),
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

    if (document.contentType != null) {
      if (headers == null) {
        headers = {contentTypeHeader: document.contentType};
      } else {
        headers[contentTypeHeader] = document.contentType;
      }
    }

    final response = await _makeRequest(resource, 'POST',
        queryParams: params,
        additionalHeaders: headers,
        body: document.content?.asList());

    //print('Response code : ${response?.statusCode}');
    //print('Response body : ${response?.body}');
    //print('headers: ${response?.headers}');

    if (response?.statusCode == 204) {
      return LRSResponse(success: true);
    } else {
      return LRSResponse(success: false, errMsg: response?.body);
    }
  }

  Future<LRSResponse<Statement>> _getStatement(
    Map<String, String> params,
  ) async {
    final http.Response response =
        await _makeRequest('statements', 'GET', queryParams: params);

    if (response?.statusCode == 200) {
      if (response.headers[contentTypeHeader]?.startsWith('multipart/mixed;') ==
          true) {
        // Parse mixed data
        final contentType = response.headers[contentTypeHeader];
        //print(contentType);
        final boundary = contentType.split('boundary=')[1];
        final statement =
            Statement.fromMixedMultipart(boundary, response.bodyBytes);
        return LRSResponse<Statement>(
          success: true,
          data: statement[0],
        );
      } else {
        final statement = Statement.fromJson(json.decode(response.body));
        return LRSResponse<Statement>(
          success: true,
          data: statement,
        );
      }
    } else {
      return LRSResponse<Statement>(success: false, errMsg: response?.body);
    }
  }
}
