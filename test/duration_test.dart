import 'package:test/test.dart';
import 'package:tin_can/tin_can.dart' show TinCanDuration;

void main() {
  test("should import date time string", () {
    // PYYYYMMDDThhmmss
    var duration = TinCanDuration.fromString('P20120521T041311');
    expect(duration.date, '20120521');
    expect(duration.time, '041311');
    expect(duration.toString(), 'P20120521T041311');

    // extended format P[YYYY]-[MM]-[DD]T[hh]:[mm]:[ss]
    duration = TinCanDuration.fromString('P0003-06-04T12:30:05');
    expect(duration.date, '0003-06-04');
    expect(duration.time, '12:30:05');
    expect(duration.toString(), 'P0003-06-04T12:30:05');
  });

  test("should import weeks string", () {
    // P[n]W
    final duration = TinCanDuration.fromString('P23W');
    expect(duration.weeks, '23');
    expect(duration.toString(), 'P23W');
  });

  test("should import parts string", () {
    // P3Y6M4DT12H30M5S
    var duration = TinCanDuration.fromString('P3Y6M4DT12H30M5S');
    expect(duration.years, '3');
    expect(duration.months, '6');
    expect(duration.days, '4');
    expect(duration.hours, '12');
    expect(duration.minutes, '30');
    expect(duration.seconds, '5');
    expect(duration.toString(), 'P3Y6M4DT12H30M5S');

    // P23DT23H
    duration = TinCanDuration.fromString('P23DT23H');
    expect(duration.days, '23');
    expect(duration.hours, '23');
    expect(duration.toString(), 'P23DT23H');

    // P4Y
    duration = TinCanDuration.fromString('P4Y');
    expect(duration.years, '4');
    expect(duration.toString(), 'P4Y');

    // PT0S
    duration = TinCanDuration.fromString('PT0S');
    expect(duration.seconds, '0');
    expect(duration.toString(), 'PT0S');

    // P0D
    duration = TinCanDuration.fromString('P0D');
    expect(duration.days, '0');
    expect(duration.toString(), 'P0D');

    // P1M - one month
    duration = TinCanDuration.fromString('P1M');
    expect(duration.months, '1');
    expect(duration.toString(), 'P1M');

    // PT1M - one minute
    duration = TinCanDuration.fromString('PT1M');
    expect(duration.minutes, '1');
    expect(duration.toString(), 'PT1M');

    // P1MT2M - one month, two minutes
    duration = TinCanDuration.fromString('P1MT2M');
    expect(duration.months, '1');
    expect(duration.minutes, '2');
    expect(duration.toString(), 'P1MT2M');

    // P0.5Y - half a year
    duration = TinCanDuration.fromString('P0.5Y');
    expect(duration.years, '0.5');
    expect(duration.toString(), 'P0.5Y');

    // P0,5Y - half a year (same as above)
    duration = TinCanDuration.fromString('P0,5Y');
    expect(duration.years, '0,5');
    expect(duration.toString(), 'P0,5Y');

    // PT36H
    duration = TinCanDuration.fromString('PT36H');
    expect(duration.hours, '36');
    expect(duration.toString(), 'PT36H');

    // P1DT12H
    duration = TinCanDuration.fromString('P1DT12H');
    expect(duration.days, '1');
    expect(duration.hours, '12');
    expect(duration.toString(), 'P1DT12H');

    // PT36H
    duration = TinCanDuration.fromString('PT36H');
    expect(duration.hours, '36');
    expect(duration.toString(), 'PT36H');
  });

  test("should import parts string - 2", () {
    // PT1H0M0S
    final duration = TinCanDuration.fromString('PT1H0M0S');
    expect(duration.hours, '1');
    expect(duration.minutes, '0');
    expect(duration.seconds, '0');
    expect(duration.toString(), 'PT1H0M0S');
  });

  test("should import duration", () {
    // 1, 2, 16, 43
    final source = Duration(
      hours: 1,
      minutes: 2,
      seconds: 16,
      milliseconds: 43,
    );

    final duration = TinCanDuration.fromDuration(source);
    expect(duration.hours, '1');
    expect(duration.minutes, '2');
    expect(duration.seconds, '16.043');
    expect(duration.toString(), 'PT1H2M16.043S');
  });
}
