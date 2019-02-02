import 'package:TinCanDart/src/versions.dart';

abstract class StatementTarget {
  Map<String, dynamic> toJson(Version version);
}
