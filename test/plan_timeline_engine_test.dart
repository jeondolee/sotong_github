import 'package:flutter_test/flutter_test.dart';

import 'package:sotong_local/model/plan_timeline/plan_engine.dart';
import 'package:sotong_local/model/plan_timeline/plan_helpers.dart';
import 'package:sotong_local/model/plan_timeline/plan_id_generator.dart';
import 'package:sotong_local/model/plan_timeline/plan_models.dart';

void main() {
  group('PlanTimelineEngine', () {
    late PlanTimelineEngine engine;
    late TotalPlan plan;

    setUp(() {
      final idGenerator = PlanIdGenerator();
      final august = DateTime(2025, 8, 1);
      final september = DateTime(2025, 9, 1);
      final october = DateTime(2025, 10, 1);

      final monthlyIncome = MonthlyIncome(
        id: idGenerator.nextMonthlyIncomeId(august),
        yearMonthList: [august, september, october],
        entryList: [MoneyEntry(amount: 1_000_000, description: 'Salary')],
      );
      final monthlyConsume = MonthlyConsume(
        id: idGenerator.nextMonthlyConsumeId(august),
        yearMonthList: [august, september, october],
        entryList: [MoneyEntry(amount: 200_000, description: 'Rent')],
      );
      final dailyConsume = DailyConsume(
        id: idGenerator.nextDailyConsumeId(august),
        startDate: august,
        endDate: DateTime(2025, 10, 31),
        entryList: [MoneyEntry(amount: 30_000, description: 'Daily spend')],
      );

      final createMini = (DateTime month) {
        final docId = idGenerator.nextMiniDocId(month);
        final start = PlanDateHelper.startOfMonth(month);
        final end = PlanDateHelper.endOfMonth(month);
        final mini = MiniPlan(
          docId: docId,
          yearMonth: month,
          startDate: start,
          endDate: end,
          monthlyIncomeRef: monthlyIncome,
          monthlyConsumeRef: monthlyConsume,
          dailyConsumeRef: dailyConsume,
        );
        mini.recalculate();
        return mini;
      };

      final augustPlan = SubPlan(yearMonth: august, head: createMini(august))
        ..recalculate();
      final septemberPlan =
          SubPlan(yearMonth: september, head: createMini(september))
            ..recalculate();
      final octoberPlan = SubPlan(yearMonth: october, head: createMini(october))
        ..recalculate();

      plan = TotalPlan(
        planId: 'plan-1',
        idGenerator: idGenerator,
        startDate: august,
        endDate: DateTime(2025, 10, 31),
        modEndDate: DateTime(2025, 10, 31),
        monthlyIncomes: {monthlyIncome.id: monthlyIncome},
        monthlyConsumes: {monthlyConsume.id: monthlyConsume},
        dailyConsumes: {dailyConsume.id: dailyConsume},
        subPlans: {
          august: augustPlan,
          september: septemberPlan,
          october: octoberPlan,
        },
      )..updateResultForMonths([august, september, october]);

      engine = PlanTimelineEngine(plan);
    });

    test('updates monthly income from apply month onwards', () {
      final result = engine.updateMonthlyIncome(
        applyDate: DateTime(2025, 9, 15),
        modEndDate: DateTime(2025, 10, 31),
        entries: [MoneyEntry(amount: 1_500_000, description: 'Raise')],
      );

      expect(result.ok, isTrue);
      expect(result.affectedMonths, ['2025-09', '2025-10']);

      final augustMonth = PlanDateHelper.startOfMonth(DateTime(2025, 8, 1));
      final septemberMonth = PlanDateHelper.startOfMonth(DateTime(2025, 9, 1));
      final octoberMonth = PlanDateHelper.startOfMonth(DateTime(2025, 10, 1));

      final augustMini = engine.plan.getSubPlanOrThrow(augustMonth).head!;
      final septemberMini = engine.plan.getSubPlanOrThrow(septemberMonth).head!;
      final octoberMini = engine.plan.getSubPlanOrThrow(octoberMonth).head!;

      expect(augustMini.monthlyIncomeRef.totalAmount, 1_000_000);
      expect(septemberMini.monthlyIncomeRef.totalAmount, 1_500_000);
      expect(octoberMini.monthlyIncomeRef.totalAmount, 1_500_000);

      final oldMonthly = engine.plan.monthlyIncomes.values
          .firstWhere((m) => m.totalAmount == 1_000_000);
      expect(oldMonthly.yearMonthList.length, 1);
      expect(
        PlanDateHelper.formatYearMonthHyphen(oldMonthly.yearMonthList.single),
        '2025-08',
      );
    });

    test('splits daily consume and propagates to following months', () {
      final result = engine.updateDailyConsume(
        applyDate: DateTime(2025, 9, 15),
        modEndDate: DateTime(2025, 10, 31),
        entries: [MoneyEntry(amount: 50_000, description: 'New habit')],
      );

      expect(result.ok, isTrue);
      expect(result.splitMonth, '2025-09');
      expect(result.propagatedMonths, ['2025-10']);

      final septemberPlan =
          engine.plan.getSubPlanOrThrow(DateTime(2025, 9, 1));
      final minis = septemberPlan.minis.toList();
      expect(minis.length, 2);
      expect(minis.first.startDate, DateTime(2025, 9, 1));
      expect(minis.first.endDate, DateTime(2025, 9, 14));
      expect(minis.last.startDate, DateTime(2025, 9, 15));
      expect(minis.last.endDate, DateTime(2025, 9, 30));
      expect(minis.last.dailyConsumeRef.totalAmount, 50_000);

      final octoberMini =
          engine.plan.getSubPlanOrThrow(DateTime(2025, 10, 1)).head!;
      expect(octoberMini.dailyConsumeRef.totalAmount, 50_000);

      final oldDaily = engine.plan.dailyConsumes.values
          .firstWhere((daily) => daily.id != minis.last.dailyConsumeId);
      expect(oldDaily.endDate, DateTime(2025, 9, 14));
      expect(oldDaily.isActive, isTrue);
    });
  });
}
