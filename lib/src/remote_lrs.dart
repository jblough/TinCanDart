import 'dart:convert';

import 'package:TinCanDart/src/about.dart';
import 'package:TinCanDart/src/activity.dart';
import 'package:TinCanDart/src/activity_profile_document.dart';
import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/agent_profile_document.dart';
import 'package:TinCanDart/src/lrs.dart';
import 'package:TinCanDart/src/lrs_response.dart';
import 'package:TinCanDart/src/person.dart';
import 'package:TinCanDart/src/state.dart';
import 'package:TinCanDart/src/state_document.dart';
import 'package:TinCanDart/src/statement.dart';
import 'package:TinCanDart/src/statements_query.dart';
import 'package:TinCanDart/src/statements_result.dart';
import 'package:TinCanDart/src/versions.dart';
import 'package:http/http.dart' as http;
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
  Future<LRSResponse> deleteAgentProfile(AgentProfileDocument profile) {
    return null;
  }

  @override
  Future<LRSResponse> updateAgentProfile(AgentProfileDocument profile) {
    return null;
  }

  @override
  Future<LRSResponse> saveAgentProfile(AgentProfileDocument profile) {
    return null;
  }

  @override
  Future<LRSResponse<AgentProfileDocument>> retrieveAgentProfile(
      String id, Agent agent) {
    return null;
  }

  @override
  Future<LRSResponse<List<String>>> retrieveAgentProfileIds(Agent agent) {
    return null;
  }

  @override
  Future<LRSResponse<Person>> retrievePerson(Agent agent) {
    return null;
  }

  @override
  Future<LRSResponse> deleteActivityProfile(ActivityProfileDocument profile) {
    return null;
  }

  @override
  Future<LRSResponse> updateActivityProfile(ActivityProfileDocument profile) {
    return null;
  }

  @override
  Future<LRSResponse> saveActivityProfile(ActivityProfileDocument profile) {
    return null;
  }

  @override
  Future<LRSResponse<ActivityProfileDocument>> retrieveActivityProfile(
      String id, Activity activity) {
    return null;
  }

  @override
  Future<LRSResponse<List<String>>> retrieveActivityProfileIds(
      Activity activity) {
    return null;
  }

  @override
  Future<LRSResponse<Activity>> retrieveActivity(Activity activity) {
    return null;
  }

  @override
  Future<LRSResponse> clearState(
      Activity activity, Agent agent, Uuid registration) {
    return null;
  }

  @override
  Future<LRSResponse> deleteState(StateDocument state) {
    return null;
  }

  @override
  Future<LRSResponse> updateState(StateDocument state) {
    return null;
  }

  @override
  Future<LRSResponse> saveState(StateDocument state) {
    return null;
  }

  @override
  Future<LRSResponse<State>> retrieveState(
      String id, Activity activity, Agent agent, Uuid registration) {
    return null;
  }

  @override
  Future<LRSResponse<List<String>>> retrieveStateIds(
      Activity activity, Agent agent, Uuid registration) {
    return null;
  }

  @override
  Future<LRSResponse<StatementsResult>> moreStatements(String moreURL) {
    return null;
  }

  @override
  Future<LRSResponse<StatementsResult>> queryStatements(StatementsQuery query) {
    return null;
  }

  @override
  Future<LRSResponse<Statement>> retrieveVoidedStatement(
      String id, bool attachments) {
    return null;
  }

  @override
  Future<LRSResponse<Statement>> retrieveStatement(
      String id, bool attachments) {
    return null;
  }

  @override
  Future<LRSResponse<StatementsResult>> saveStatements(
      List<Statement> statements) async {
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
    print('Sending : $body');

    final response =
        await _makeRequest('statements', verb, queryParams: params, body: body);
    print(response?.statusCode);
    print(response?.body);

    if (response?.statusCode == 200) {
      return LRSResponse<Statement>(
        success: true,
        data: statement.copyWith(
          id: response.body,
        ),
      );
    } else if (response?.statusCode == 204) {
      return LRSResponse<Statement>(
        success: true,
        data: statement,
      );
    } else {
      return LRSResponse<Statement>(success: false, errMsg: response?.body);
    }

    /*
      StatementLRSResponse lrsResponse = new StatementLRSResponse();
        lrsResponse.setRequest(new HTTPRequest());

        lrsResponse.getRequest().setResource("statements");
        lrsResponse.getRequest().setContentType("application/json");

        try {
            lrsResponse.getRequest().setContent(statement.toJSON(this.getVersion(), this.usePrettyJSON()).getBytes("UTF-8"));
        } catch (IOException ex) {
            lrsResponse.setErrMsg("Exception: " + ex.toString());
            return lrsResponse;
        }

        if (statement.hasAttachmentsWithContent()) {
            lrsResponse.getRequest().setPartList(statement.getPartList());
        }

        if (statement.getId() == null) {
            lrsResponse.getRequest().setMethod(HttpMethod.POST.asString());
        }
        else {
            lrsResponse.getRequest().setMethod(HttpMethod.PUT.asString());
            lrsResponse.getRequest().setQueryParams(new HashMap<String, String>());
            lrsResponse.getRequest().getQueryParams().put("statementId", statement.getId().toString());
        }

        lrsResponse.setResponse(makeSyncRequest(lrsResponse.getRequest()));
        int status = lrsResponse.getResponse().getStatus();

        lrsResponse.setContent(statement);

        // TODO: handle 409 conflict, etc.
        if (status == 200) {
            lrsResponse.setSuccess(true);
            String content = lrsResponse.getResponse().getContent();
            try {
                lrsResponse.getContent().setId(UUID.fromString(Mapper.getInstance().readValue(content, ArrayNode.class).get(0).textValue()));
            } catch (Exception ex) {
                lrsResponse.setErrMsg("Exception: " + ex.toString());
                lrsResponse.setSuccess(false);
            }
        }
        else if (status == 204) {
            lrsResponse.setSuccess(true);
        }
        else {
            lrsResponse.setSuccess(false);
        }

        return lrsResponse;
     */
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
  Future<http.Response> _makeRequest(String resource, String verb,
      {Map<String, String> queryParams,
      Map<String, String> additionalHeaders,
      body: dynamic}) async {
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

    //print(url);
    //http.MultipartRequest()
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
}
