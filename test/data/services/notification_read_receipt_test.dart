import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/data/services/notification_read_receipt.dart';
import 'package:healthylife_ai/domain/entities/notification_entities.dart';
import 'package:healthylife_ai/domain/repositories/notification_repository.dart';

class _Inbox implements NotificationRepository {
  _Inbox({this.fail = false});

  final bool fail;
  final List<String> read = [];

  @override
  Future<Result<NotificationPage>> getPage(int page) async =>
      const Success(NotificationPage([]));

  @override
  Future<Result<void>> markRead(String id) async {
    read.add(id);
    return fail
        ? const Failed<void>(CacheFailure(debugMessage: 'disk full'))
        : const Success<void>(null);
  }

  @override
  Future<Result<void>> markAllRead(List<String> ids) async =>
      const Success<void>(null);
}

void main() {
  test('marks the row through the inbox, which also tells the server once',
      () async {
    final inbox = _Inbox();

    await NotificationReadReceipt(inbox: inbox).send('12');

    expect(inbox.read, ['12']);
  });

  test('an inbox failure is logged and nothing throws', () async {
    final inbox = _Inbox(fail: true);

    await expectLater(
        NotificationReadReceipt(inbox: inbox).send('12'), completes);
    expect(inbox.read, ['12']);
  });
}
