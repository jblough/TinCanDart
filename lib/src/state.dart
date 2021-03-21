import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import './agent.dart';

class State {
  final String? id;
  final DateTime? updated;
  final ByteBuffer? contents;
  final Agent? agent;
  final Uri? activityId;
  final Uuid? registration;

  State({
    this.id,
    this.updated,
    this.contents,
    this.agent,
    this.activityId,
    this.registration,
  });

// TODO - Check if this need a fromJSON method
}
