/// Domain entities for the notifications center.
/// Pure Dart â€” no Flutter imports, no mock data.

/// The filter chips at the top of the Notifications Center. `all` is never
/// a real notification category — it just means "no filter applied".
enum NotificationCategory { all, meals, measurements, planUpdates, other }

/// How a notification's body renders beyond the shared title/subtitle —
/// each variant mirrors one of the confirmed card layouts (a meal-preview
/// card with a "Log now" CTA, a specialist note with a live stat, a
/// measurement status, or a plan-sync progress readout).
enum NotificationVariant { mealPreview, specialistNote, measurementStatus, planSync, plain }

class NotificationEntry {
  final String id;
  final NotificationCategory category;
  final NotificationVariant variant;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final String emoji;

  // Variant-specific payloads — only the ones relevant to [variant] are set.
  final String? mealTitle;
  final int? mealCalories;
  final int? mealProteinG;
  final int? mealCarbsG;
  final String? specialistName;
  final String? statLabel;
  final String? statValue;
  final String? statusLabel;
  final bool? statusDone;
  final double? syncPercent;

  const NotificationEntry({
    required this.id,
    required this.category,
    required this.variant,
    required this.title,
    required this.body,
    required this.time,
    required this.emoji,
    this.unread = false,
    this.mealTitle,
    this.mealCalories,
    this.mealProteinG,
    this.mealCarbsG,
    this.specialistName,
    this.statLabel,
    this.statValue,
    this.statusLabel,
    this.statusDone,
    this.syncPercent,
  });
}

class NotificationDateGroup {
  final String label;
  final List<NotificationEntry> items;
  const NotificationDateGroup({required this.label, required this.items});
}


extension NotificationEntryReadState on NotificationEntry {
  /// Returns a copy with the unread flag cleared (used when the persisted
  /// read state says this notification was already seen).
  NotificationEntry markRead() => NotificationEntry(
        id: id,
        category: category,
        variant: variant,
        title: title,
        body: body,
        time: time,
        emoji: emoji,
        unread: false,
        mealTitle: mealTitle,
        mealCalories: mealCalories,
        mealProteinG: mealProteinG,
        mealCarbsG: mealCarbsG,
        specialistName: specialistName,
        statLabel: statLabel,
        statValue: statValue,
        statusLabel: statusLabel,
        statusDone: statusDone,
        syncPercent: syncPercent,
      );
}
