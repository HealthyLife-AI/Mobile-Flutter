import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/domain/entities/notification_entities.dart';
import 'package:healthylife_ai/domain/repositories/notification_repository.dart';
import 'package:healthylife_ai/presentation/bloc/notifications/notifications_cubit.dart';
import 'package:healthylife_ai/presentation/screens/notifications_center_screen.dart';

import '../../helpers/localized_app.dart';

NotificationEntry _entry(String id,
        {bool unread = true, String title = 'خبر'}) =>
    NotificationEntry(
      id: id,
      category: NotificationCategory.other,
      variant: NotificationVariant.plain,
      title: title,
      body: 'نص',
      time: 'الآن',
      emoji: '⭐',
      unread: unread,
    );

class _FakeRepository implements NotificationRepository {
  _FakeRepository(this.groups);

  final List<NotificationDateGroup> groups;
  final List<List<String>> bulk = [];
  final List<String> marked = [];

  @override
  Future<Result<NotificationPage>> getPage(int page) async =>
      Success(NotificationPage(groups));

  @override
  Future<Result<void>> markRead(String id) async {
    marked.add(id);
    return const Success(null);
  }

  @override
  Future<Result<void>> markAllRead(List<String> ids) async {
    bulk.add(ids);
    return const Success(null);
  }
}

void main() {
  testWidgets('the inbox renders the feed the cubit loaded, not the mock',
      (tester) async {
    final cubit = NotificationsCubit(_FakeRepository([
      NotificationDateGroup(label: 'اليوم', items: [
        _entry('a', title: 'تنبيه-فريد'),
      ]),
    ]));

    await tester.pumpWidget(BlocProvider<NotificationsCubit>.value(
      value: cubit,
      child: localizedApp(home: const NotificationsCenterScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('تنبيه-فريد'), findsOneWidget);

    // The infinite hero/pulse animations never settle; drain the ticker.
    cubit.close();
  });

  testWidgets('tapping "read all" asks the cubit which will persist it',
      (tester) async {
    final repository = _FakeRepository([
      NotificationDateGroup(label: 'اليوم', items: [
        _entry('a'),
        _entry('b'),
      ]),
    ]);
    final cubit = NotificationsCubit(repository);

    await tester.pumpWidget(BlocProvider<NotificationsCubit>.value(
      value: cubit,
      child: localizedApp(home: const NotificationsCenterScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final markAll = find.byType(TextButton);
    expect(markAll, findsOneWidget);
    await tester.tap(markAll);
    await tester.pump();

    expect(repository.bulk.single, ['a', 'b']);

    cubit.close();
  });

  testWidgets(
      'server rows are worded from their time, and a tap marks the row read',
      (tester) async {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1, 12);
    NotificationEntry fromServer(String id, String title, DateTime at) =>
        NotificationEntry(
          id: id,
          category: NotificationCategory.other,
          variant: NotificationVariant.plain,
          title: title,
          body: 'نص',
          time: '',
          emoji: '🔔',
          unread: true,
          createdAt: at,
        );
    final repository = _FakeRepository([
      NotificationDateGroup(
        label: '',
        day: DateTime(now.year, now.month, now.day),
        items: [
          fromServer('new', 'جديد', now.subtract(const Duration(minutes: 5))),
        ],
      ),
      NotificationDateGroup(
        label: '',
        day: yesterday,
        items: [fromServer('old', 'قديم', yesterday)],
      ),
    ]);
    final cubit = NotificationsCubit(repository);

    await tester.pumpWidget(BlocProvider<NotificationsCubit>.value(
      value: cubit,
      child: localizedApp(home: const NotificationsCenterScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('منذ ٥ دقائق'), findsOneWidget);
    expect(find.text('أمس'), findsOneWidget);

    await tester.tap(find.text('جديد'));
    await tester.pump();

    expect(repository.marked, ['new']);

    cubit.close();
  });
}
