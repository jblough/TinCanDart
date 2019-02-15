import './activity.dart';
import './agent.dart';
import './statement_ref.dart';
import './substatement.dart';
import './versions.dart';

abstract class StatementTarget {
  Map<String, dynamic> toJson(Version version);

  static StatementTarget toTarget(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    final type = json['objectType'];
    switch (type) {
      case 'Group':
      case 'Agent':
        return Agent.fromJson(json);
      case 'StatementRef':
        return StatementRef.fromJson(json);
      case 'SubStatement':
        return SubStatement.fromJson(json);
      default:
        return Activity.fromJson(json);
    }
  }
}
