import 'package:TinCanDart/src/activity.dart';
import 'package:TinCanDart/src/agent.dart';
import 'package:TinCanDart/src/statement_ref.dart';
import 'package:TinCanDart/src/statement_target.dart';
import 'package:TinCanDart/src/substatement.dart';

class ParsingUtils {
  static DateTime parseDate(String date) {
    if (date == null) {
      return null;
    }

    return DateTime.tryParse(date);
  }

  static StatementTarget parseTarget(Map<String, dynamic> json) {
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

  static Uri toUri(String url) {
    if (url == null) {
      return null;
    }

    Uri uri;
    if (url.endsWith('/')) {
      uri = Uri.parse(url);
    } else {
      uri = Uri.parse('$url/');
    }

    // Unless the URI is a absolute throw an exception
    if (!uri.isAbsolute) {
      throw FormatException;
    }

    return uri;
  }
}
