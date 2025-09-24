import 'package:intl/intl.dart';

/// Utilities for working with plan timelines and Year-Month based ranges.
class PlanDateHelper {
  PlanDateHelper._();

  static final DateFormat _yearMonthFormatter = DateFormat('yyyyMM');
  static final DateFormat _yearMonthHyphenFormatter = DateFormat('yyyy-MM');

  /// Returns the [DateTime] representing the first day of the month (in local
  /// time) that the provided [date] belongs to.
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Returns the [DateTime] representing the last day of the month (in local
  /// time) that the provided [date] belongs to.
  static DateTime endOfMonth(DateTime date) {
    final monthStart = startOfMonth(date);
    final nextMonth = DateTime(monthStart.year, monthStart.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }

  /// Returns the total number of days contained in [month].
  static int daysInMonth(DateTime month) {
    final monthStart = startOfMonth(month);
    final nextMonth = DateTime(monthStart.year, monthStart.month + 1, 1);
    return nextMonth.difference(monthStart).inDays;
  }

  /// Iterates the months from [start] to [end] inclusive.
  static Iterable<DateTime> iterateMonths(DateTime start, DateTime end) sync* {
    var current = startOfMonth(start);
    final endMonth = startOfMonth(end);
    while (!isAfterMonth(current, endMonth)) {
      yield current;
      current = DateTime(current.year, current.month + 1, 1);
    }
  }

  /// Returns `true` when [a] represents a month strictly after [b].
  static bool isAfterMonth(DateTime a, DateTime b) {
    if (a.year != b.year) {
      return a.year > b.year;
    }
    return a.month > b.month;
  }

  /// Returns `true` when [a] and [b] are the same Year-Month.
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// Converts [date] to a YYYYMM formatted key (e.g. `202509`).
  static String formatYearMonth(DateTime date) {
    return _yearMonthFormatter.format(startOfMonth(date));
  }

  /// Converts [date] to a YYYY-MM formatted key (e.g. `2025-09`).
  static String formatYearMonthHyphen(DateTime date) {
    return _yearMonthHyphenFormatter.format(startOfMonth(date));
  }

  /// Returns the number of calendar days in the inclusive range from [start]
  /// to [end].
  static int inclusiveDays(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  /// Returns the [DateTime] for [date] at midnight in the Asia/Seoul timezone.
  ///
  /// In this project we rely on local time representations. By constructing a
  /// `DateTime` without passing `isUtc`, Dart will create a local-time instance
  /// that honours the runtime's timezone (Asia/Seoul on our servers).
  static DateTime toSeoulMidnight(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns the [DateTime] that corresponds to the day immediately before
  /// [date].
  static DateTime previousDay(DateTime date) {
    return date.subtract(const Duration(days: 1));
  }

  /// Returns the [DateTime] that corresponds to the day immediately after
  /// [date].
  static DateTime nextDay(DateTime date) {
    return date.add(const Duration(days: 1));
  }
}

/// Half-up rounding implementation used for currency calculations.
int roundHalfUp(num value) {
  if (value.isNaN) {
    return 0;
  }
  if (value >= 0) {
    return (value + 0.5).floor();
  }
  return (value - 0.5).ceil();
}

/// Returns the per-second value rounded to two decimal places.
double roundPerSecond(num value) {
  final scaled = (value * 100).roundToDouble();
  return scaled / 100.0;
}
