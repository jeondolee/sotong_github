import 'plan_helpers.dart';
import 'plan_models.dart';

class PlanTimelineEngine {
  PlanTimelineEngine(this._plan);

  TotalPlan _plan;

  TotalPlan get plan => _plan;

  MonthlyUpdateResult updateMonthlyIncome({
    required DateTime applyDate,
    required DateTime modEndDate,
    required List<MoneyEntry> entries,
  }) {
    return _updateMonthly(
      applyDate: applyDate,
      modEndDate: modEndDate,
      entries: entries,
      isIncome: true,
    );
  }

  MonthlyUpdateResult updateMonthlyConsume({
    required DateTime applyDate,
    required DateTime modEndDate,
    required List<MoneyEntry> entries,
  }) {
    return _updateMonthly(
      applyDate: applyDate,
      modEndDate: modEndDate,
      entries: entries,
      isIncome: false,
    );
  }

  MonthlyUpdateResult _updateMonthly({
    required DateTime applyDate,
    required DateTime modEndDate,
    required List<MoneyEntry> entries,
    required bool isIncome,
  }) {
    _validateApplyDate(applyDate);
    final startMonth = PlanDateHelper.startOfMonth(applyDate);
    final endMonth = PlanDateHelper.startOfMonth(modEndDate);
    final working = _plan.clone();
    final generator = working.idGenerator;

    final newId = isIncome
        ? generator.nextMonthlyIncomeId(startMonth)
        : generator.nextMonthlyConsumeId(startMonth);

    final months = PlanDateHelper.iterateMonths(startMonth, endMonth).toList();
    final monthlyObjects = <MonthlyBase>{};
    for (final month in months) {
      final subPlan = working.getSubPlanOrThrow(month);
      for (final mini in subPlan.minis) {
        if (isIncome) {
          monthlyObjects.add(mini.monthlyIncomeRef);
        } else {
          monthlyObjects.add(mini.monthlyConsumeRef);
        }
      }
    }

    MonthlyBase newMonthly;
    if (isIncome) {
      newMonthly = MonthlyIncome(
        id: newId,
        yearMonthList: months,
        entryList: entries,
      );
      working.monthlyIncomes[newMonthly.id] = newMonthly as MonthlyIncome;
    } else {
      newMonthly = MonthlyConsume(
        id: newId,
        yearMonthList: months,
        entryList: entries,
      );
      working.monthlyConsumes[newMonthly.id] = newMonthly as MonthlyConsume;
    }

    for (final month in months) {
      final subPlan = working.getSubPlanOrThrow(month);
      for (final mini in subPlan.minis) {
        if (isIncome) {
          mini.monthlyIncomeRef = newMonthly as MonthlyIncome;
          mini.monthlyIncomeId = newMonthly.id;
        } else {
          mini.monthlyConsumeRef = newMonthly as MonthlyConsume;
          mini.monthlyConsumeId = newMonthly.id;
        }
      }
      subPlan.recalculate();
    }

    for (final old in monthlyObjects) {
      old.yearMonthList.removeWhere(
        (element) => months.contains(PlanDateHelper.startOfMonth(element)),
      );
      if (old.yearMonthList.isEmpty) {
        old.isActive = false;
      }
    }

    working.updateResultForMonths(months);
    working.validate();

    _plan = working;

    return MonthlyUpdateResult(
      ok: true,
      affectedMonths:
          months.map(PlanDateHelper.formatYearMonthHyphen).toList(),
    );
  }

  DailyUpdateResult updateDailyConsume({
    required DateTime applyDate,
    required DateTime modEndDate,
    required List<MoneyEntry> entries,
  }) {
    _validateApplyDate(applyDate);
    final applyMonth = PlanDateHelper.startOfMonth(applyDate);
    final endMonth = PlanDateHelper.startOfMonth(modEndDate);
    final working = _plan.clone();
    final generator = working.idGenerator;

    final applySubPlan = working.getSubPlanOrThrow(applyMonth);
    final targetMini = applySubPlan.findMiniContaining(applyDate);
    if (targetMini == null) {
      throw PlanValidationException('No mini plan contains the apply date.');
    }
    final originalDaily = targetMini.dailyConsumeRef;

    final newDaily = DailyConsume(
      id: generator.nextDailyConsumeId(applyMonth),
      startDate: applyDate,
      endDate: modEndDate,
      entryList: entries,
    );
    working.dailyConsumes[newDaily.id] = newDaily;

    if (!applyDate.isAtSameMomentAs(targetMini.startDate)) {
      final newDocId = generator.nextMiniDocId(applyMonth);
      final right = targetMini.split(newDocId, applyDate);
      right.dailyConsumeRef = newDaily;
      right.dailyConsumeId = newDaily.id;
    } else {
      targetMini.dailyConsumeRef = newDaily;
      targetMini.dailyConsumeId = newDaily.id;
    }

    for (final mini in applySubPlan.minis) {
      if (!mini.startDate.isBefore(PlanDateHelper.toSeoulMidnight(applyDate))) {
        mini.dailyConsumeRef = newDaily;
        mini.dailyConsumeId = newDaily.id;
      }
    }
    applySubPlan.recalculate();

    final months = PlanDateHelper.iterateMonths(applyMonth, endMonth).toList();
    final propagated = <String>[];
    for (final month in months.skip(1)) {
      final subPlan = working.getSubPlanOrThrow(month);
      for (final mini in subPlan.minis) {
        mini.dailyConsumeRef = newDaily;
        mini.dailyConsumeId = newDaily.id;
      }
      subPlan.recalculate();
      propagated.add(PlanDateHelper.formatYearMonthHyphen(month));
    }

    originalDaily.endDate = PlanDateHelper.previousDay(applyDate);
    originalDaily.endedAt = originalDaily.endDate;
    if (originalDaily.endDate.isBefore(originalDaily.startDate)) {
      originalDaily.isActive = false;
    }

    working.updateResultForMonths(months);
    working.validate();

    _plan = working;

    return DailyUpdateResult(
      ok: true,
      splitMonth: PlanDateHelper.formatYearMonthHyphen(applyMonth),
      propagatedMonths: propagated,
    );
  }

  void _validateApplyDate(DateTime applyDate) {
    final start = _plan.startDate;
    final end = _plan.modEndDate ?? _plan.endDate;
    if (start != null && applyDate.isBefore(start)) {
      throw PlanValidationException('APPLY_DATE_OUT_OF_RANGE');
    }
    if (end != null && applyDate.isAfter(end)) {
      throw PlanValidationException('APPLY_DATE_OUT_OF_RANGE');
    }
  }
}
