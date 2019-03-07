enum _Format {
  parts,
  weeks,
  datetime,
}

class TinCanDuration {
  final _Format _format;

  // P3Y6M4DT12H30M5S
  // P[n]Y[n]M[n]DT[n]H[n]M[n]S
  final String years;
  final String months;
  final String days;

  final String hours;
  final String minutes;
  final String seconds;

  // PYYYYMMDDThhmmss or in the extended format P[YYYY]-[MM]-[DD]T[hh]:[mm]:[ss]
  final String date;
  final String time;

  // P[n]W
  final String weeks;

  /*TinCanDuration({
    this.years,
    this.months,
    this.days,
    this.hours,
    this.minutes,
    this.seconds,
    this.date,
    this.time,
    this.weeks,
  });*/

  TinCanDuration.fromParts({
    this.years,
    this.months,
    this.days,
    this.hours,
    this.minutes,
    this.seconds,
  })  : _format = _Format.parts,
        weeks = null,
        date = null,
        time = null;

  TinCanDuration.fromDateTime({
    this.date,
    this.time,
  })  : _format = _Format.datetime,
        weeks = null,
        years = null,
        months = null,
        days = null,
        hours = null,
        minutes = null,
        seconds = null;

  TinCanDuration.fromWeeks(this.weeks)
      : _format = _Format.weeks,
        date = null,
        time = null,
        years = null,
        months = null,
        days = null,
        hours = null,
        minutes = null,
        seconds = null;

  factory TinCanDuration.fromString(String duration) {
    if (duration == null || duration.isEmpty) {
      return null;
    }

    // Strip off the P
    final String content = duration.substring(1);

    // If ends in W, then use fromWeeks() constructor
    if (content.contains('W')) {
      // Duration is in the format P###W, so remove the P and W, and convert the rest to a number
      return TinCanDuration.fromWeeks(content.replaceAll(RegExp(r'[W]'), ''));
    }

    // If contains : or -, then use fromDateTime
    // OR If does NOT contain WYMDHMS, then use fromDateTime
    if (content.contains(RegExp(':-')) ||
        (!content.contains(RegExp(r'[WYMDHMS]')))) {
      final parts = content.split('T');
      return TinCanDuration.fromDateTime(
        date: parts[0],
        time: parts[1],
      );
    }

    // Else use fromParts
    String years = RegExp(r'([0-9,.]+)Y').firstMatch(duration)?.group(1);
    // Since months and minutes both use 'M', split on the 'T' if present
    String months = (duration.contains('T'))
        ? RegExp(r'([0-9,.]+)M').firstMatch(duration.split('T')[0])?.group(1)
        : RegExp(r'[^T]([0-9,.]+)M').firstMatch(duration)?.group(1);
    String days = RegExp(r'([0-9,.]+)D').firstMatch(duration)?.group(1);
    String hours = RegExp(r'([0-9,.]+)H').firstMatch(duration)?.group(1);
    String minutes = RegExp(r'T.*?([0-9,.]+)M').firstMatch(duration)?.group(1);
    String seconds = RegExp(r'([0-9,.]+)S').firstMatch(duration)?.group(1);

    return TinCanDuration.fromParts(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  factory TinCanDuration.fromDiff(DateTime start, DateTime end) {
    if (start == null || end == null) {
      return null;
    }

    return TinCanDuration.fromDuration(end.difference(start));
  }

  factory TinCanDuration.fromDuration(Duration duration) {
    if (duration == null) {
      return null;
    }

    // 00:00:16.043000
    final pattern = RegExp(r'([0-9]+):([0-9]+):([0-9.]+)');
    final match = pattern.firstMatch(duration.toString());
    int inDays = duration.inDays;
    int days = (inDays > 0) ? inDays : null;
    int hours =
        (inDays > 0) ? (duration.inHours % 24) : int.tryParse(match.group(1));
    if (hours == 0) {
      hours = null;
    }
    int minutes = int.tryParse(match.group(2));
    if (minutes == 0) {
      minutes = null;
    }
    double seconds = double.tryParse(match.group(3));
    // Truncate (round) to only 0.01 second precision
    if (seconds != null) {
      seconds = double.parse(seconds.toStringAsFixed(2));
    }
    final secondsString = (seconds == null)
        ? null
        : ((seconds.toInt() == seconds)
            ? seconds.toInt().toString()
            : seconds.toString());

    return TinCanDuration.fromParts(
      days: days?.toString(),
      hours: hours?.toString(),
      minutes: minutes?.toString(),
      seconds: secondsString,
    );
  }

  @override
  String toString() {
    switch (_format) {
      case _Format.weeks:
        return 'P${weeks}W';
      case _Format.datetime:
        return 'P${date}T$time';
      case _Format.parts:
        String duration = 'P';
        if (years != null) {
          duration += '${years}Y';
        }
        if (months != null) {
          duration += '${months}M';
        }
        if (days != null) {
          duration += '${days}D';
        }
        if (hours != null || minutes != null || seconds != null) {
          duration += 'T';
        }
        if (hours != null) {
          duration += '${hours}H';
        }
        if (minutes != null) {
          duration += '${minutes}M';
        }
        if (seconds != null) {
          duration += '${seconds}S';
        }

        return duration;
    }

    return null;
  }
}
