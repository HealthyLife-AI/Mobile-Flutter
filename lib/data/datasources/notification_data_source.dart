import '../../core/config/app_config.dart';
import '../../domain/entities/notification_entities.dart';
import '../mock/notification_mock_data.dart';

/// Notifications feed (mock now, HTTP later).
abstract interface class NotificationDataSource {
  Future<List<NotificationDateGroup>> fetchGroups();
}

class MockNotificationDataSource implements NotificationDataSource {
  const MockNotificationDataSource({this.latency = AppConfig.mockLatency});

  final Duration latency;

  @override
  Future<List<NotificationDateGroup>> fetchGroups() async {
    await Future<void>.delayed(latency);
    // Defensive copies: repositories must never mutate the shared mock feed.
    return NotificationMockData.groups
        .map((g) => NotificationDateGroup(label: g.label, items: List.unmodifiable(g.items)))
        .toList();
  }
}
