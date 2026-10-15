/// Domain entities for the notifications center.
/// Pure Dart — no Flutter imports, no mock data.
library;

/// The filter chips at the top of the Notifications Center. `all` is never
/// a real notification category — it just means "no filter applied".
/// The others follow the inbox categories (API guide 10.2): `meals`,
/// `measurements`, `nutritionist`, `plan` ([planUpdates]) and `system`
/// ([other]).
enum NotificationCategory {
  all,
  meals,
  measurements,
  planUpdates,
  nutritionist,
  other,
}

/// How a notification's body renders beyond the shared title/subtitle —
/// each variant mirrors one of the confirmed card layouts (a meal-preview
/// card with a "Log now" CTA, a specialist note with a live stat, a
/// measurement status, or a plan-sync progress readout). Inbox rows from the
/// server are [plain]: a title and a body.
enum NotificationVariant {
  mealPreview,
  specialistNote,
  measurementStatus,
  planSync,
  plain
}

class NotificationEntry {
  final String id;
  final NotificationCategory category;
  final NotificationVariant variant;
  final String title;
  final String body;

  /// A ready-made time label. Rows from the server leave it empty and carry
  /// [createdAt] instead, which the screen words in the app's language.
  final String time;
  final bool unread;
  final String emoji;

  /// When the server created the row (API guide 10.2), in local time.
  final DateTime? createdAt;

  /// The row's `type` (10.3), which decides the screen it opens.
  final String? type;

  /// The note a `review_new` / `review_updated` row points to.
  final String? reviewId;

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
    this.createdAt,
    this.type,
    this.reviewId,
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

  /// The local day the group covers. When set, the screen words the header
  /// itself ("today", "yesterday", a date) and [label] is unused.
  final DateTime? day;
  final List<NotificationEntry> items;
  const NotificationDateGroup(
      {required this.label, required this.items, this.day});
}

/// One page of the inbox, grouped by day (API guide 10.2: 20 rows a page,
/// newest first).
class NotificationPage {
  const NotificationPage(this.groups, {this.hasMore = false});

  final List<NotificationDateGroup> groups;

  /// A later page holds older rows.
  final bool hasMore;
}

/// [older] added after [shown]. A row already shown is dropped (rows move to
/// the next page as new ones arrive), and a day split across the page break
/// stays one group.
List<NotificationDateGroup> appendOlderNotifications(
  List<NotificationDateGroup> shown,
  List<NotificationDateGroup> older,
) {
  final seen = {
    for (final g in shown)
      for (final e in g.items) e.id,
  };
  final merged = [...shown];
  for (final group in older) {
    final items = [
      for (final e in group.items)
        if (seen.add(e.id)) e,
    ];
    if (items.isEmpty) continue;
    final last = merged.isEmpty ? null : merged.last;
    final sameDay = last != null &&
        (last.day != null
            ? last.day == group.day
            : group.day == null && last.label == group.label);
    if (sameDay) {
      merged[merged.length - 1] = NotificationDateGroup(
          label: last.label, day: last.day, items: [...last.items, ...items]);
    } else {
      merged.add(NotificationDateGroup(
          label: group.label, day: group.day, items: items));
    }
  }
  return merged;
}

extension NotificationEntryReadState on NotificationEntry {
  /// Returns a copy with the unread flag cleared (used when the persisted
  /// read state says this notification was already seen).
  NotificationEntry markRead() => copyWith(unread: false);

  /// A copy with the given fields replaced. [clearSpecialistName] drops the
  /// name instead of keeping it.
  NotificationEntry copyWith({
    String? title,
    String? body,
    bool? unread,
    String? specialistName,
    bool clearSpecialistName = false,
  }) =>
      NotificationEntry(
        id: id,
        category: category,
        variant: variant,
        title: title ?? this.title,
        body: body ?? this.body,
        time: time,
        emoji: emoji,
        unread: unread ?? this.unread,
        createdAt: createdAt,
        type: type,
        reviewId: reviewId,
        mealTitle: mealTitle,
        mealCalories: mealCalories,
        mealProteinG: mealProteinG,
        mealCarbsG: mealCarbsG,
        specialistName: clearSpecialistName
            ? null
            : (specialistName ?? this.specialistName),
        statLabel: statLabel,
        statValue: statValue,
        statusLabel: statusLabel,
        statusDone: statusDone,
        syncPercent: syncPercent,
      );
}
