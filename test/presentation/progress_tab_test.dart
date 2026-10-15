import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';
import 'package:healthylife_ai/domain/repositories/measurement_repository.dart';
import 'package:healthylife_ai/presentation/app_shell.dart';
import 'package:healthylife_ai/presentation/bloc/measurements/measurements_cubit.dart';
import 'package:healthylife_ai/presentation/screens/first_measurement_screen.dart';
import 'package:healthylife_ai/presentation/screens/progress_screen.dart';

import '../helpers/app_providers.dart';

class _Repository implements MeasurementRepository {
  _Repository(this.readings);

  final List<MeasurementEntry> readings;

  @override
  Future<Result<MeasurementSnapshot>> getSnapshot() async =>
      Success(MeasurementSnapshot(
        currentWeight: readings.isEmpty ? null : readings.last.weightKg,
        previousWeight: null,
        weightTrend: [
          for (final r in readings)
            WeightPoint(date: r.recordedAt, kg: r.weightKg!),
        ],
        circumference: const [],
        daysLoggedThisWeek: 0,
        daysLoggedThisMonth: 0,
        savedEntries: readings,
      ));

  @override
  Future<Result<MeasurementSnapshot>> saveEntry(MeasurementEntry entry) =>
      throw UnimplementedError();
}

MeasurementEntry _reading(String id, DateTime day) =>
    MeasurementEntry(id: id, recordedAt: day, weightKg: 81.3);

void main() {
  // Today is Thursday 15 October.
  final now = DateTime(2026, 10, 15, 10);

  Future<void> openProgressTab(
      WidgetTester tester, List<MeasurementEntry> readings) async {
    final cubit = MeasurementsCubit(_Repository(readings), clock: () => now);
    await cubit.load();
    await tester.pumpWidget(appProviders(BlocProvider.value(
      value: cubit,
      child: const AppShell(),
    )));
    await tester.tap(find.byIcon(Icons.insights_rounded));
    await tester.pump();
    // The tab switch, then the prompt's entrance.
    await tester.pump(const Duration(seconds: 3));
  }

  Finder inPrompt(Finder finder) => find.descendant(
      of: find.byType(FirstMeasurementScreen), matching: finder);

  testWidgets('a reading from this week shows the progress dashboard',
      (tester) async {
    await openProgressTab(tester, [_reading('a', DateTime(2026, 10, 12))]);

    expect(find.byType(FirstMeasurementScreen), findsNothing);
    expect(find.byType(ProgressScreen), findsOneWidget);
  });

  testWidgets('a week after the latest reading, the weekly prompt shows',
      (tester) async {
    await openProgressTab(tester, [
      _reading('a', DateTime(2026, 9, 30)),
      _reading('b', DateTime(2026, 10, 8)),
    ]);

    expect(find.byType(ProgressScreen), findsNothing);
    expect(inPrompt(find.text('حان موعد قياسك الأسبوعي')), findsOneWidget);
    expect(inPrompt(find.text('آخر قياس مسجل')), findsOneWidget);
    // The real reading, not the design's sample.
    expect(inPrompt(find.textContaining('١٩ سبتمبر ٢٠٢٥')), findsNothing);
    expect(inPrompt(find.textContaining('أكتوبر')), findsOneWidget);
  });

  testWidgets('"view my progress" opens the dashboard while a reading is due',
      (tester) async {
    await openProgressTab(tester, [_reading('a', DateTime(2026, 10, 8))]);
    // With a single reading, the prompt asks for the second one.
    expect(inPrompt(find.text('بانتظار القياس الثاني')), findsOneWidget);

    final viewProgress = inPrompt(find.text('عرض تقدّمي الآن'));
    await tester.scrollUntilVisible(viewProgress, 200,
        scrollable: inPrompt(find.byType(Scrollable)).first);
    await tester.tap(viewProgress);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FirstMeasurementScreen), findsNothing);
    expect(find.byType(ProgressScreen), findsOneWidget);
  });

  testWidgets(
      'with no reading, the first one is asked for and nothing skips it',
      (tester) async {
    await openProgressTab(tester, const []);

    expect(inPrompt(find.text('سجّل قياسك الأول لنحدد نقطة انطلاقك')),
        findsOneWidget);
    // No reading: no card claiming one was saved.
    expect(inPrompt(find.text('القياس الأولي المسجل')), findsNothing);
    expect(inPrompt(find.text('عرض تقدّمي الآن')), findsNothing);
  });
}
