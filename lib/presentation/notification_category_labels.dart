import 'package:flutter/material.dart';

import '../domain/entities/notification_entities.dart';
import '../l10n/l10n.dart';

/// Presentation helpers for [NotificationCategory]: icon + localized label.

extension NotificationCategoryLabel on NotificationCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case NotificationCategory.all:
        return l10n.notificationCategoryAll;
      case NotificationCategory.meals:
        return l10n.notificationCategoryMeals;
      case NotificationCategory.measurements:
        return l10n.notificationCategoryMeasurements;
      case NotificationCategory.planUpdates:
        return l10n.notificationCategoryPlanUpdates;
      case NotificationCategory.nutritionist:
        return l10n.notificationCategoryNutritionist;
      case NotificationCategory.other:
        return l10n.notificationCategoryOther;
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
      case NotificationCategory.nutritionist:
        return Icons.medical_services_outlined;
      case NotificationCategory.other:
        return Icons.more_horiz_rounded;
    }
  }
}
