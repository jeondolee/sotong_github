import 'plan_helpers.dart';

/// Generates identifiers for monthly and daily documents following the S1
/// specification (YYYYMM-SEQ).
class PlanIdGenerator {
  PlanIdGenerator({
    Map<String, int>? miniCounters,
    Map<String, int>? monthlyIncomeCounters,
    Map<String, int>? monthlyConsumeCounters,
    Map<String, int>? dailyCounters,
  })  : _miniCounters = Map<String, int>.from(miniCounters ?? const {}),
        _monthlyIncomeCounters =
            Map<String, int>.from(monthlyIncomeCounters ?? const {}),
        _monthlyConsumeCounters =
            Map<String, int>.from(monthlyConsumeCounters ?? const {}),
        _dailyCounters = Map<String, int>.from(dailyCounters ?? const {});

  final Map<String, int> _miniCounters;
  final Map<String, int> _monthlyIncomeCounters;
  final Map<String, int> _monthlyConsumeCounters;
  final Map<String, int> _dailyCounters;

  PlanIdGenerator clone() {
    return PlanIdGenerator(
      miniCounters: _miniCounters,
      monthlyIncomeCounters: _monthlyIncomeCounters,
      monthlyConsumeCounters: _monthlyConsumeCounters,
      dailyCounters: _dailyCounters,
    );
  }

  String nextMiniDocId(DateTime month) {
    final key = PlanDateHelper.formatYearMonth(month);
    final seq = (_miniCounters[key] ?? 0) + 1;
    _miniCounters[key] = seq;
    return '${key}-${_pad(seq)}';
  }

  String nextMonthlyIncomeId(DateTime month) {
    final key = PlanDateHelper.formatYearMonth(month);
    final seq = (_monthlyIncomeCounters[key] ?? 0) + 1;
    _monthlyIncomeCounters[key] = seq;
    return 'inc-${key}-${_pad(seq)}';
  }

  String nextMonthlyConsumeId(DateTime month) {
    final key = PlanDateHelper.formatYearMonth(month);
    final seq = (_monthlyConsumeCounters[key] ?? 0) + 1;
    _monthlyConsumeCounters[key] = seq;
    return 'con-${key}-${_pad(seq)}';
  }

  String nextDailyConsumeId(DateTime month) {
    final key = PlanDateHelper.formatYearMonth(month);
    final seq = (_dailyCounters[key] ?? 0) + 1;
    _dailyCounters[key] = seq;
    return 'day-${key}-${_pad(seq)}';
  }

  String _pad(int seq) => seq.toString().padLeft(3, '0');
}
