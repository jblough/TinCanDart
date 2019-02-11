import 'dart:convert';

import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/statement_target.dart';
import 'package:TinCanDart/src/validated_uri.dart';
import 'package:TinCanDart/src/versions.dart';

enum QueryResultFormat { IDS, EXACT, CANONICAL }

class StatementsQuery {
  final ValidatedUri verbID;
  final StatementTarget object;
  final String registration; // UUID
  final bool context;
  final Agent actor;
  final DateTime since;
  final DateTime until;
  final int limit;
  final bool authoritative;
  final bool sparse;
  final Agent instructor;
  final bool ascending;

  final Agent agent;
  final ValidatedUri activityID;
  final bool relatedActivities;
  final bool relatedAgents;
  final QueryResultFormat format;
  final bool attachments;

  StatementsQuery({
    this.verbID,
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
    this.activityID,
    this.relatedActivities,
    this.relatedAgents,
    this.format,
    this.attachments,
  });

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
