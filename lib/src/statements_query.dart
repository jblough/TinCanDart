import 'dart:convert';

import './agent.dart';
import './statement_target.dart';
import './validated_uri.dart';
import './versions.dart';

// ignore_for_file: constant_identifier_names
enum QueryResultFormat {
  /// Only return IDs
  IDS,

  /// Return the statements exactly as they were received by the LRS
  EXACT,

  /// Return internal definitions of objects not those provided in the statement
  CANONICAL,
}

class StatementsQuery {
  ///  ID to query on
  final ValidatedUri? verbID;

  /// (Removed in 1.0.0, use 'activityID' or 'agent' instead) Activity, Agent, or Statement matches 'object'
  final StatementTarget? object;

  /// Registration UUID
  final String? registration; // UUID
  /// (Removed in 1.0.0, use [activityID] instead) When filtering on target, include statements with matching context
  final bool? context;

  /// (Removed in 1.0.0, use 'agent' instead) Agent matches 'actor'
  final Agent? actor;

  /// Match statements stored since specified timestamp
  final DateTime? since;

  /// Match statements stored at or before specified timestamp
  final DateTime? until;

  /// Number of results to retrieve
  final int? limit;

  /// (Removed in 1.0.0) Get authoritative results
  final bool? authoritative;

  /// (Removed in 1.0.0, use 'format' instead) Get sparse results
  final bool? sparse;

  /// (Removed in 1.0.0, use 'agent' + 'related_agents' instead) Agent matches 'context:instructor'
  final Agent? instructor;

  /// Return results in ascending order of stored time
  final bool? ascending;

  /// Agent matches 'actor' or 'object'
  final Agent? agent;

  /// Activity ID to query on
  final ValidatedUri? activityID;

  /// Match related activities
  final bool? relatedActivities;

  /// Match related agents
  final bool? relatedAgents;

  /// One of "IDS", "EXACT", "CANONICAL" (default: "EXACT")
  final QueryResultFormat? format;

  /// Include attachments in multipart response (default: false)
  final bool? attachments;

  /// https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Communication.md#213-get-statements
  StatementsQuery({
    dynamic verbID,
    this.object,
    this.registration,
    this.context,
    this.actor,
    this.since,
    this.until,
    this.limit,
    this.authoritative,
    this.sparse,
    this.instructor,
    this.ascending,
    this.agent,
    dynamic activityID,
    this.relatedActivities,
    this.relatedAgents,
    this.format,
    this.attachments,
  })  : verbID = ValidatedUri.fromString(verbID?.toString()),
        activityID = ValidatedUri.fromString(activityID?.toString());

  Map<String, String?> toParameterMap(Version version) {
    switch (version) {
      case Version.V09:
      case Version.V095:
        return _toParameterMapVersion095(version);
      default:
        return _toParameterMapVersion10x(version);
    }
  }

  Map<String, String?> _toParameterMapVersion095(Version version) {
    final Map<String, String?> params = {};

    if (verbID != null) {
      params['verb'] = verbID.toString();
    }

    if (object != null) {
      params['object'] = json.encode(object!.toJson(version));
    }

    if (registration != null) {
      params['registration'] = registration;
    }

    if (context != null) {
      params['context'] = context.toString();
    }

    if (actor != null) {
      params['actor'] = json.encode(actor!.toJson(version));
    }

    if (since != null) {
      params['since'] = since!.toUtc().toIso8601String();
    }

    if (until != null) {
      params['until'] = until!.toUtc().toIso8601String();
    }

    if (limit != null) {
      params['limit'] = limit.toString();
    }

    if (authoritative != null) {
      params['authoritative'] = authoritative.toString();
    }

    if (sparse != null) {
      params['sparse'] = sparse.toString();
    }

    if (instructor != null) {
      params['instructor'] = json.encode(instructor!.toJson(version));
    }

    if (ascending != null) {
      params['ascending'] = ascending.toString();
    }

    return params;
  }

  Map<String, String?> _toParameterMapVersion10x(Version version) {
    final Map<String, String?> params = {};

    if (agent != null) {
      params['agent'] = json.encode(agent!.toJson(version));
    }

    if (verbID != null) {
      params['verb'] = verbID.toString();
    }

    if (activityID != null) {
      params['activity'] = activityID.toString();
    }

    if (registration != null) {
      params['registration'] = registration;
    }

    if (relatedActivities != null) {
      params['related_activities'] = relatedActivities.toString();
    }

    if (relatedAgents != null) {
      params['related_agents'] = relatedAgents.toString();
    }

    if (since != null) {
      params['since'] = since!.toUtc().toIso8601String();
    }

    if (until != null) {
      params['until'] = until!.toUtc().toIso8601String();
    }

    if (limit != null) {
      params['limit'] = limit.toString();
    }

    if (format != null) {
      params['format'] = format?.toString().split('.')[1].toLowerCase();
    }

    if (ascending != null) {
      params['ascending'] = ascending.toString();
    }

    if (attachments != null) {
      params['attachments'] = attachments.toString();
    }

    return params;
  }
}
