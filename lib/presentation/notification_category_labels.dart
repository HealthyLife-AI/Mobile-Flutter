import 'package:flutter/material.dart';

import '../../domain/entities/notification_entities.dart';

/// Presentation helpers for [NotificationCategory]: icon + Arabic label.
/// (Locale-aware label extraction happens in the localization layer.)

extension NotificationCategoryLabel on NotificationCategory {
  String get label {
    switch (this) {
      case NotificationCategory.all:
        return 'الكل';
      case NotificationCategory.meals:
        return 'الوجبات';
      case NotificationCategory.measurements:
        return 'القياسات';
      case NotificationCategory.planUpdates:
        return 'تحديثات الخطة';
      case NotificationCategory.other:
        return 'الأخرى';
    }
  }

  IconData? get icon {
    switch (this) {
      case NotificationCategory.all:
        return null;
      case NotificationCategory.meals:
        return Icons.restaurant_rounded;
      case NotificationCategory.measurements:
        return Icons.balance_rounded;
      case NotificationCategory.planUpdates:
        return Icons.event_note_rounded;
      case NotificationCategory.other:
        return Icons.more_horiz_rounded;
    }
  }
}

