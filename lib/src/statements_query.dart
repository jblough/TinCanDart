import 'dart:convert';

import './agent.dart';
import './statement_target.dart';
import './validated_uri.dart';
import './versions.dart';

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
  final ValidatedUri verbID;

  /// (Removed in 1.0.0, use 'activityID' or 'agent' instead) Activity, Agent, or Statement matches 'object'
  final StatementTarget object;

  /// Registration UUID
  final String registration; // UUID
  /// (Removed in 1.0.0, use [activityID] instead) When filtering on target, include statements with matching context
  final bool context;

  /// (Removed in 1.0.0, use 'agent' instead) Agent matches 'actor'
  final Agent actor;

  /// Match statements stored since specified timestamp
  final DateTime since;

  /// Match statements stored at or before specified timestamp
  final DateTime until;

  /// Number of results to retrieve
  final int limit;

  /// (Removed in 1.0.0) Get authoritative results
  final bool authoritative;

  /// (Removed in 1.0.0, use 'format' instead) Get sparse results
  final bool sparse;

  /// (Removed in 1.0.0, use 'agent' + 'related_agents' instead) Agent matches 'context:instructor'
  final Agent instructor;

  /// Return results in ascending order of stored time
  final bool ascending;

  /// Agent matches 'actor' or 'object'
  final Agent agent;

  /// Activity ID to query on
  final ValidatedUri activityID;

  /// Match related activities
  final bool relatedActivities;

  /// Match related agents
  final bool relatedAgents;

  /// One of "IDS", "EXACT", "CANONICAL" (default: "EXACT")
  final QueryResultFormat format;

  /// Include attachments in multipart response (default: false)
  final bool attachments;

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
  })  : this.verbID = ValidatedUri.fromString(verbID?.toString()),
        this.activityID = ValidatedUri.fromString(activityID?.toString());

  Map<String, String> toParameterMap(Version version) {
    switch (version) {
      case Version.V09:
      case Version.V095:
        return _toParameterMapVersion095(version);
      default:
        return _toParameterMapVersion10x(version);
    }
  }

  Map<String, String> _toParameterMapVersion095(Version version) {
    final Map<String, String> params = {};

    if (this.verbID != null) {
      params['verb'] = this.verbID.toString();
    }

    if (this.object != null) {
      params['object'] = json.encode(this.object.toJson(version));
    }

    if (this.registration != null) {
      params['registration'] = this.registration;
    }

    if (this.context != null) {
      params['context'] = this.context.toString();
    }

    if (this.actor != null) {
      params['actor'] = json.encode(this.actor.toJson(version));
    }

    if (this.since != null) {
      params['since'] = this.since.toUtc().toIso8601String();
    }

    if (this.until != null) {
      params['until'] = this.until.toUtc().toIso8601String();
    }

    if (this.limit != null) {
      params['limit'] = this.limit.toString();
    }

    if (this.authoritative != null) {
      params['authoritative'] = this.authoritative.toString();
    }

    if (this.sparse != null) {
      params['sparse'] = this.sparse.toString();
    }

    if (this.instructor != null) {
      params['instructor'] = json.encode(this.instructor.toJson(version));
    }

    if (this.ascending != null) {
      params['ascending'] = this.ascending.toString();
    }

    return params;
  }

  Map<String, String> _toParameterMapVersion10x(Version version) {
    Map<String, String> params = {};

    if (this.agent != null) {
      params['agent'] = json.encode(this.agent.toJson(version));
    }

    if (this.verbID != null) {
      params['verb'] = this.verbID.toString();
    }

    if (this.activityID != null) {
      params['activity'] = this.activityID.toString();
    }

    if (this.registration != null) {
      params['registration'] = this.registration;
    }

    if (this.relatedActivities != null) {
      params['related_activities'] = this.relatedActivities.toString();
    }

    if (this.relatedAgents != null) {
      params['related_agents'] = this.relatedAgents.toString();
    }

    if (this.since != null) {
      params['since'] = this.since.toUtc().toIso8601String();
    }

    if (this.until != null) {
      params['until'] = this.until.toUtc().toIso8601String();
    }

    if (this.limit != null) {
      params['limit'] = this.limit.toString();
    }

    if (this.format != null) {
      params['format'] = this.format?.toString()?.split('.')[1]?.toLowerCase();
    }

    if (this.ascending != null) {
      params['ascending'] = this.ascending.toString();
    }

    if (this.attachments != null) {
      params['attachments'] = this.attachments.toString();
    }

    return params;
  }
}
