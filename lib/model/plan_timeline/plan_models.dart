import 'dart:collection';

import 'plan_helpers.dart';
import 'plan_id_generator.dart';

class MoneyEntry {
  MoneyEntry({
    required this.amount,
    required this.description,
    this.note,
  });

  final int amount;
  final String description;
  final String? note;

  MoneyEntry copyWith({
    int? amount,
    String? description,
    String? note,
  }) {
    return MoneyEntry(
      amount: amount ?? this.amount,
      description: description ?? this.description,
      note: note ?? this.note,
    );
  }
}

abstract class MonthlyBase {
  MonthlyBase({
    required this.id,
    required List<DateTime> yearMonthList,
    required List<MoneyEntry> entryList,
    this.isActive = true,
  })  : yearMonthList =
            yearMonthList.map(PlanDateHelper.startOfMonth).toList(),
        entryList = List<MoneyEntry>.from(entryList);

  String id;
  List<DateTime> yearMonthList;
  List<MoneyEntry> entryList;
  bool isActive;

  int get totalAmount => entryList.fold(0, (sum, e) => sum + e.amount);

  MonthlyBase copyWith({
    String? id,
    List<DateTime>? yearMonthList,
    List<MoneyEntry>? entryList,
    bool? isActive,
  });
}

class MonthlyIncome extends MonthlyBase {
  MonthlyIncome({
    required super.id,
    required super.yearMonthList,
    required super.entryList,
    super.isActive,
  });

  @override
  MonthlyIncome copyWith({
    String? id,
    List<DateTime>? yearMonthList,
    List<MoneyEntry>? entryList,
    bool? isActive,
  }) {
    return MonthlyIncome(
      id: id ?? this.id,
      yearMonthList:
          (yearMonthList ?? this.yearMonthList).map(PlanDateHelper.startOfMonth).toList(),
      entryList: List<MoneyEntry>.from(entryList ?? this.entryList),
      isActive: isActive ?? this.isActive,
    );
  }
}

class MonthlyConsume extends MonthlyBase {
  MonthlyConsume({
    required super.id,
    required super.yearMonthList,
    required super.entryList,
    super.isActive,
  });

  @override
  MonthlyConsume copyWith({
    String? id,
    List<DateTime>? yearMonthList,
    List<MoneyEntry>? entryList,
    bool? isActive,
  }) {
    return MonthlyConsume(
      id: id ?? this.id,
      yearMonthList:
          (yearMonthList ?? this.yearMonthList).map(PlanDateHelper.startOfMonth).toList(),
      entryList: List<MoneyEntry>.from(entryList ?? this.entryList),
      isActive: isActive ?? this.isActive,
    );
  }
}

class DailyConsume {
  DailyConsume({
    required this.id,
    required DateTime startDate,
    required DateTime endDate,
    required List<MoneyEntry> entryList,
    this.isActive = true,
    this.endedAt,
  })  : startDate = PlanDateHelper.toSeoulMidnight(startDate),
        endDate = PlanDateHelper.toSeoulMidnight(endDate),
        entryList = List<MoneyEntry>.from(entryList);

  String id;
  DateTime startDate;
  DateTime endDate;
  List<MoneyEntry> entryList;
  bool isActive;
  DateTime? endedAt;

  int get totalAmount => entryList.fold(0, (sum, e) => sum + e.amount);

  DailyConsume copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    List<MoneyEntry>? entryList,
    bool? isActive,
    DateTime? endedAt,
  }) {
    return DailyConsume(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      entryList: List<MoneyEntry>.from(entryList ?? this.entryList),
      isActive: isActive ?? this.isActive,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}

class PlanMetrics {
  PlanMetrics({
    required this.startDate,
    required this.endDate,
    required this.kDays,
    required this.sumMonthlyIncome,
    required this.sumMonthlyConsume,
    required this.sumDailyConsume,
    required this.dailyNetSaving,
    int? monthlyNetSaving,
    double? perSecondSaving,
  })  : monthlyNetSaving = monthlyNetSaving ?? dailyNetSaving * kDays,
        perSecondSaving =
            perSecondSaving ?? roundPerSecond(dailyNetSaving / (24 * 60 * 60));

  final DateTime startDate;
  final DateTime endDate;
  final int kDays;
  final int sumMonthlyIncome;
  final int sumMonthlyConsume;
  final int sumDailyConsume;
  final int dailyNetSaving;
  final int monthlyNetSaving;
  final double perSecondSaving;

  PlanMetrics copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? kDays,
    int? sumMonthlyIncome,
    int? sumMonthlyConsume,
    int? sumDailyConsume,
    int? dailyNetSaving,
    int? monthlyNetSaving,
    double? perSecondSaving,
  }) {
    return PlanMetrics(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      kDays: kDays ?? this.kDays,
      sumMonthlyIncome: sumMonthlyIncome ?? this.sumMonthlyIncome,
      sumMonthlyConsume: sumMonthlyConsume ?? this.sumMonthlyConsume,
      sumDailyConsume: sumDailyConsume ?? this.sumDailyConsume,
      dailyNetSaving: dailyNetSaving ?? this.dailyNetSaving,
      monthlyNetSaving: monthlyNetSaving ?? this.monthlyNetSaving,
      perSecondSaving: perSecondSaving ?? this.perSecondSaving,
    );
  }
}

class MiniPlan {
  MiniPlan({
    required this.docId,
    this.prev,
    this.next,
    required DateTime yearMonth,
    required DateTime startDate,
    required DateTime endDate,
    required this.monthlyIncomeRef,
    required this.monthlyConsumeRef,
    required this.dailyConsumeRef,
  })  : yearMonth = PlanDateHelper.startOfMonth(yearMonth),
        startDate = PlanDateHelper.toSeoulMidnight(startDate),
        endDate = PlanDateHelper.toSeoulMidnight(endDate),
        monthlyIncomeId = monthlyIncomeRef.id,
        monthlyConsumeId = monthlyConsumeRef.id,
        dailyConsumeId = dailyConsumeRef.id;

  String docId;
  MiniPlan? prev;
  MiniPlan? next;
  DateTime yearMonth;
  DateTime startDate;
  DateTime endDate;
  MonthlyIncome monthlyIncomeRef;
  MonthlyConsume monthlyConsumeRef;
  DailyConsume dailyConsumeRef;
  String monthlyIncomeId;
  String monthlyConsumeId;
  String dailyConsumeId;
  int sumMonthlyIncome = 0;
  int sumMonthlyConsume = 0;
  int sumDailyConsume = 0;
  PlanMetrics? metrics;

  MiniPlan cloneUsing({
    required Map<String, MonthlyIncome> monthlyIncomes,
    required Map<String, MonthlyConsume> monthlyConsumes,
    required Map<String, DailyConsume> dailyConsumes,
  }) {
    final clone = MiniPlan(
      docId: docId,
      yearMonth: yearMonth,
      startDate: startDate,
      endDate: endDate,
      monthlyIncomeRef: monthlyIncomes[monthlyIncomeId]!,
      monthlyConsumeRef: monthlyConsumes[monthlyConsumeId]!,
      dailyConsumeRef: dailyConsumes[dailyConsumeId]!,
    );
    clone.sumMonthlyIncome = sumMonthlyIncome;
    clone.sumMonthlyConsume = sumMonthlyConsume;
    clone.sumDailyConsume = sumDailyConsume;
    clone.metrics = metrics == null
        ? null
        : metrics!.copyWith();
    return clone;
  }

  void recalculate() {
    sumMonthlyIncome = monthlyIncomeRef.totalAmount;
    sumMonthlyConsume = monthlyConsumeRef.totalAmount;
    sumDailyConsume = dailyConsumeRef.totalAmount;
    final kDays = PlanDateHelper.inclusiveDays(startDate, endDate);
    final dailyNet = roundHalfUp(
      (sumMonthlyIncome - sumMonthlyConsume - sumDailyConsume * kDays) /
          kDays,
    );
    metrics = PlanMetrics(
      startDate: startDate,
      endDate: endDate,
      kDays: kDays,
      sumMonthlyIncome: sumMonthlyIncome,
      sumMonthlyConsume: sumMonthlyConsume,
      sumDailyConsume: sumDailyConsume,
      dailyNetSaving: dailyNet,
    );
  }

  MiniPlan split(String newDocId, DateTime splitStart) {
    final splitDate = PlanDateHelper.toSeoulMidnight(splitStart);
    if (splitDate.isBefore(startDate) || splitDate.isAfter(endDate)) {
      throw StateError('Split date must be within the mini plan range.');
    }
    if (splitDate.isAtSameMomentAs(startDate)) {
      return this;
    }

    final right = MiniPlan(
      docId: newDocId,
      yearMonth: yearMonth,
      startDate: splitDate,
      endDate: endDate,
      monthlyIncomeRef: monthlyIncomeRef,
      monthlyConsumeRef: monthlyConsumeRef,
      dailyConsumeRef: dailyConsumeRef,
    );

    right.next = next;
    if (next != null) {
      next!.prev = right;
    }
    next = right;
    right.prev = this;

    endDate = PlanDateHelper.previousDay(splitDate);
    recalculate();
    right.recalculate();
    return right;
  }
}

class MiniPlanResult {
  MiniPlanResult({
    required this.headDocId,
    required List<PlanMetrics> miniMetrics,
  }) : miniMetrics = List<PlanMetrics>.from(miniMetrics);

  String headDocId;
  List<PlanMetrics> miniMetrics;

  MiniPlanResult copyWith({
    String? headDocId,
    List<PlanMetrics>? miniMetrics,
  }) {
    return MiniPlanResult(
      headDocId: headDocId ?? this.headDocId,
      miniMetrics: miniMetrics ?? this.miniMetrics,
    );
  }
}

class SubPlan {
  SubPlan({
    required DateTime yearMonth,
    this.head,
    MiniPlanResult? miniResult,
  })  : yearMonth = PlanDateHelper.startOfMonth(yearMonth),
        miniResult = miniResult ??
            MiniPlanResult(headDocId: head?.docId ?? '', miniMetrics: const []);

  DateTime yearMonth;
  MiniPlan? head;
  MiniPlanResult miniResult;

  Iterable<MiniPlan> get minis sync* {
    var node = head;
    while (node != null) {
      yield node;
      node = node.next;
    }
  }

  MiniPlan? findMiniContaining(DateTime date) {
    final target = PlanDateHelper.toSeoulMidnight(date);
    for (final mini in minis) {
      if (!PlanDateHelper.isSameMonth(mini.yearMonth, yearMonth)) {
        continue;
      }
      if (mini.startDate.isAfter(target) || mini.endDate.isBefore(target)) {
        continue;
      }
      return mini;
    }
    return null;
  }

  void recalculate() {
    final metrics = <PlanMetrics>[];
    for (final mini in minis) {
      mini.recalculate();
      if (metrics.isEmpty) {
        miniResult.headDocId = mini.docId;
      }
      metrics.add(mini.metrics!);
    }
    miniResult = miniResult.copyWith(
      headDocId: head?.docId ?? '',
      miniMetrics: metrics,
    );
  }

  PlanMetrics aggregateMonthly() {
    final monthDays = PlanDateHelper.daysInMonth(yearMonth);
    if (head == null) {
      return PlanMetrics(
        startDate: yearMonth,
        endDate: PlanDateHelper.endOfMonth(yearMonth),
        kDays: monthDays,
        sumMonthlyIncome: 0,
        sumMonthlyConsume: 0,
        sumDailyConsume: 0,
        dailyNetSaving: 0,
      );
    }

    int? monthlyIncome;
    int? monthlyConsume;
    var weightedDaily = 0;
    var weightedNet = 0;
    var visitedDays = 0;

    for (final mini in minis) {
      final metric = mini.metrics ?? (mini.recalculate(), mini.metrics!);
      monthlyIncome ??= metric.sumMonthlyIncome;
      monthlyConsume ??= metric.sumMonthlyConsume;
      weightedDaily += metric.sumDailyConsume * metric.kDays;
      weightedNet += metric.dailyNetSaving * metric.kDays;
      visitedDays += metric.kDays;
    }

    if (visitedDays != monthDays) {
      throw StateError('Mini plans do not cover the entire month.');
    }

    final avgDaily = roundHalfUp(weightedDaily / monthDays);
    final avgNet = roundHalfUp(weightedNet / monthDays);

    return PlanMetrics(
      startDate: yearMonth,
      endDate: PlanDateHelper.endOfMonth(yearMonth),
      kDays: monthDays,
      sumMonthlyIncome: monthlyIncome ?? 0,
      sumMonthlyConsume: monthlyConsume ?? 0,
      sumDailyConsume: avgDaily,
      dailyNetSaving: avgNet,
    );
  }

  SubPlan cloneUsing({
    required Map<String, MonthlyIncome> monthlyIncomes,
    required Map<String, MonthlyConsume> monthlyConsumes,
    required Map<String, DailyConsume> dailyConsumes,
  }) {
    final newHead = head == null
        ? null
        : head!.cloneUsing(
            monthlyIncomes: monthlyIncomes,
            monthlyConsumes: monthlyConsumes,
            dailyConsumes: dailyConsumes,
          );

    MiniPlan? prev;
    MiniPlan? original = head?.next;
    MiniPlan? copyCursor = newHead;
    while (original != null && copyCursor != null) {
      final cloned = original.cloneUsing(
        monthlyIncomes: monthlyIncomes,
        monthlyConsumes: monthlyConsumes,
        dailyConsumes: dailyConsumes,
      );
      copyCursor.next = cloned;
      cloned.prev = copyCursor;
      prev = copyCursor;
      copyCursor = cloned;
      original = original.next;
    }

    final clonedResult = MiniPlanResult(
      headDocId: miniResult.headDocId,
      miniMetrics: miniResult.miniMetrics.map((e) => e.copyWith()).toList(),
    );

    return SubPlan(
      yearMonth: yearMonth,
      head: newHead,
      miniResult: clonedResult,
    );
  }

  void validate() {
    if (head == null) {
      return;
    }
    final firstExpected = PlanDateHelper.startOfMonth(yearMonth);
    final lastExpected = PlanDateHelper.endOfMonth(yearMonth);
    var expectedStart = firstExpected;
    MiniPlan? node = head;
    MiniPlan? previous;
    while (node != null) {
      if (!PlanDateHelper.isSameMonth(node.yearMonth, yearMonth)) {
        throw StateError('Mini plan month mismatch: ${node.yearMonth}');
      }
      if (node.prev != previous) {
        throw StateError('Broken prev link for mini ${node.docId}.');
      }
      if (node.startDate != expectedStart) {
        throw StateError('Mini plan continuity broken at ${node.docId}.');
      }
      if (node.startDate.isAfter(node.endDate)) {
        throw StateError('Mini plan has invalid range: ${node.docId}.');
      }
      previous = node;
      expectedStart = PlanDateHelper.nextDay(node.endDate);
      node = node.next;
    }
    if (!expectedStart.isAfter(lastExpected)) {
      throw StateError('Mini plans do not cover the entire month.');
    }
  }
}

class SubPlanResult {
  SubPlanResult({
    required List<PlanMetrics> subMetrics,
    required List<SubPlan> subPlanList,
  })  : subMetrics = List<PlanMetrics>.from(subMetrics),
        subPlanList = List<SubPlan>.from(subPlanList);

  List<PlanMetrics> subMetrics;
  List<SubPlan> subPlanList;

  SubPlanResult copyWith({
    List<PlanMetrics>? subMetrics,
    List<SubPlan>? subPlanList,
  }) {
    return SubPlanResult(
      subMetrics: subMetrics ?? this.subMetrics,
      subPlanList: subPlanList ?? this.subPlanList,
    );
  }
}

class TotalResult {
  TotalResult({
    required this.totalMetrics,
    required this.subResult,
  });

  PlanMetrics totalMetrics;
  SubPlanResult subResult;

  TotalResult copyWith({
    PlanMetrics? totalMetrics,
    SubPlanResult? subResult,
  }) {
    return TotalResult(
      totalMetrics: totalMetrics ?? this.totalMetrics,
      subResult: subResult ?? this.subResult,
    );
  }
}

class TotalPlan {
  TotalPlan({
    required this.planId,
    required this.idGenerator,
    this.planName,
    this.targetAmount,
    this.currentAmount = 0,
    this.currentAsset = 0,
    this.startDate,
    this.endDate,
    this.modEndDate,
    this.creationDate,
    this.autoService,
    Map<DateTime, SubPlan>? subPlans,
    Map<String, MonthlyIncome>? monthlyIncomes,
    Map<String, MonthlyConsume>? monthlyConsumes,
    Map<String, DailyConsume>? dailyConsumes,
    TotalResult? result,
  })  : subPlans = LinkedHashMap<DateTime, SubPlan>.from(subPlans ?? {}),
        monthlyIncomes = Map<String, MonthlyIncome>.from(monthlyIncomes ?? {}),
        monthlyConsumes = Map<String, MonthlyConsume>.from(monthlyConsumes ?? {}),
        dailyConsumes = Map<String, DailyConsume>.from(dailyConsumes ?? {}),
        result = result ??
            TotalResult(
              totalMetrics: PlanMetrics(
                startDate: startDate ?? DateTime.now(),
                endDate: endDate ?? DateTime.now(),
                kDays: 1,
                sumMonthlyIncome: 0,
                sumMonthlyConsume: 0,
                sumDailyConsume: 0,
                dailyNetSaving: 0,
              ),
              subResult: SubPlanResult(subMetrics: const [], subPlanList: const []),
            );

  String planId;
  PlanIdGenerator idGenerator;
  String? planName;
  int? targetAmount;
  int currentAmount;
  int currentAsset;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? modEndDate;
  DateTime? creationDate;
  bool? autoService;
  Map<DateTime, SubPlan> subPlans;
  Map<String, MonthlyIncome> monthlyIncomes;
  Map<String, MonthlyConsume> monthlyConsumes;
  Map<String, DailyConsume> dailyConsumes;
  TotalResult result;

  TotalPlan clone() {
    final clonedGenerator = idGenerator.clone();
    final clonedMonthlyIncomes = monthlyIncomes.map(
      (key, value) => MapEntry(key, value.copyWith()),
    );
    final clonedMonthlyConsumes = monthlyConsumes.map(
      (key, value) => MapEntry(key, value.copyWith()),
    );
    final clonedDailyConsumes = dailyConsumes.map(
      (key, value) => MapEntry(key, value.copyWith()),
    );

    final newSubPlans = <DateTime, SubPlan>{};
    subPlans.forEach((key, value) {
      newSubPlans[key] = value.cloneUsing(
        monthlyIncomes: clonedMonthlyIncomes,
        monthlyConsumes: clonedMonthlyConsumes,
        dailyConsumes: clonedDailyConsumes,
      );
    });

    final sortedSubPlans = newSubPlans.values.toList()
      ..sort((a, b) => a.yearMonth.compareTo(b.yearMonth));
    final newResult = TotalResult(
      totalMetrics: result.totalMetrics.copyWith(),
      subResult: SubPlanResult(
        subMetrics: result.subResult.subMetrics
            .map((e) => e.copyWith())
            .toList(),
        subPlanList: sortedSubPlans,
      ),
    );

    return TotalPlan(
      planId: planId,
      idGenerator: clonedGenerator,
      planName: planName,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      currentAsset: currentAsset,
      startDate: startDate,
      endDate: endDate,
      modEndDate: modEndDate,
      creationDate: creationDate,
      autoService: autoService,
      subPlans: newSubPlans,
      monthlyIncomes: clonedMonthlyIncomes,
      monthlyConsumes: clonedMonthlyConsumes,
      dailyConsumes: clonedDailyConsumes,
      result: newResult,
    );
  }

  SubPlan getSubPlanOrThrow(DateTime month) {
    final key = PlanDateHelper.startOfMonth(month);
    final plan = subPlans[key];
    if (plan == null) {
      throw StateError('SubPlan for ${PlanDateHelper.formatYearMonthHyphen(key)} missing');
    }
    return plan;
  }

  void updateResultForMonths(Iterable<DateTime> months) {
    final affected = months
        .map(PlanDateHelper.startOfMonth)
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));
    final affectedSet = affected.toSet();

    final metrics = <PlanMetrics>[];
    for (final month in affected) {
      final subPlan = getSubPlanOrThrow(month);
      subPlan.recalculate();
      metrics.add(subPlan.aggregateMonthly());
    }

    final existing = result.subResult.subMetrics
        .where((metric) =>
            !affectedSet.contains(PlanDateHelper.startOfMonth(metric.startDate)))
        .toList();
    final combined = [...existing, ...metrics];
    combined.sort((a, b) => a.startDate.compareTo(b.startDate));

    final subPlanList = subPlans.values.toList()
      ..sort((a, b) => a.yearMonth.compareTo(b.yearMonth));

    result = result.copyWith(
      subResult: SubPlanResult(
        subMetrics: combined,
        subPlanList: subPlanList,
      ),
    );

    _recalculateTotal();
  }

  void _recalculateTotal() {
    final monthlyMetrics = result.subResult.subMetrics;
    if (monthlyMetrics.isEmpty) {
      return;
    }
    final totalDays = monthlyMetrics.fold<int>(0, (sum, metric) => sum + metric.kDays);
    final sumMonthlyIncome =
        monthlyMetrics.fold<int>(0, (sum, metric) => sum + metric.sumMonthlyIncome);
    final sumMonthlyConsume =
        monthlyMetrics.fold<int>(0, (sum, metric) => sum + metric.sumMonthlyConsume);
    final weightedDaily = monthlyMetrics.fold<int>(
      0,
      (sum, metric) => sum + metric.sumDailyConsume * metric.kDays,
    );
    final weightedNet = monthlyMetrics.fold<int>(
      0,
      (sum, metric) => sum + metric.dailyNetSaving * metric.kDays,
    );

    final avgDaily = roundHalfUp(weightedDaily / totalDays);
    final avgNet = roundHalfUp(weightedNet / totalDays);

    final start = monthlyMetrics.first.startDate;
    final end = monthlyMetrics.last.endDate;

    result = result.copyWith(
      totalMetrics: PlanMetrics(
        startDate: start,
        endDate: end,
        kDays: totalDays,
        sumMonthlyIncome: sumMonthlyIncome,
        sumMonthlyConsume: sumMonthlyConsume,
        sumDailyConsume: avgDaily,
        dailyNetSaving: avgNet,
      ),
    );
  }

  void validate() {
    final months = subPlans.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    for (final key in months) {
      final plan = subPlans[key];
      plan?.validate();
    }
  }
}

class MonthlyUpdateResult {
  MonthlyUpdateResult({
    required this.ok,
    required this.affectedMonths,
  });

  final bool ok;
  final List<String> affectedMonths;
}

class DailyUpdateResult {
  DailyUpdateResult({
    required this.ok,
    required this.splitMonth,
    required this.propagatedMonths,
  });

  final bool ok;
  final String splitMonth;
  final List<String> propagatedMonths;
}

class PlanValidationException implements Exception {
  PlanValidationException(this.message);
  final String message;
  @override
  String toString() => 'PlanValidationException: $message';
}
