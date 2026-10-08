import 'package:flutter/material.dart';

/// The filter chips at the top of the Notifications Center. `all` is never
/// a real notification category — it just means "no filter applied".
enum NotificationCategory { all, meals, measurements, planUpdates, other }

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

class NotificationMockData {
  NotificationMockData._();

  static final List<NotificationDateGroup> groups = [
    const NotificationDateGroup(label: 'اليوم', items: [
      NotificationEntry(
        id: 'n1',
        category: NotificationCategory.meals,
        variant: NotificationVariant.mealPreview,
        emoji: '🥗',
        title: 'حان موعد وجبة الغداء',
        body: 'لا تنسَ تسجيل وجبة الغداء المقررة (سلطة الدجاج والكينوا) للحفاظ على تسلسل التزامك وتحقيق أهداف طاقتك.',
        time: 'منذ 15 دقيقة',
        unread: true,
        mealTitle: 'وجبة الغداء المقترحة: 485 سعرة',
        mealCalories: 485,
        mealProteinG: 38,
        mealCarbsG: 42,
      ),
      NotificationEntry(
        id: 'n2',
        category: NotificationCategory.planUpdates,
        variant: NotificationVariant.specialistNote,
        emoji: '🩺',
        title: 'ملاحظة جديدة من د. خلود العربي',
        body: 'قامت الأخصائية بزيادة حصة الماء اليومية وتحديث تقييمك الأسبوعي استناداً لمعدل حرق الأمس. اضغط للمعاينة.',
        time: 'منذ ساعتين',
        unread: true,
        specialistName: 'د. خلود العربي',
        statLabel: 'الهدف المائي الجديد',
        statValue: '2.8 لتر / يوم',
      ),
    ]),
    const NotificationDateGroup(label: 'أمس', items: [
      NotificationEntry(
        id: 'n3',
        category: NotificationCategory.measurements,
        variant: NotificationVariant.measurementStatus,
        emoji: '⚖️',
        title: 'تذكير بوزن الأسبوع',
        body: 'يرجى أخذ قياس الوزن الصباحي وتسجيله قبل تناول وجبة الفطور للحفاظ على دقة مؤشرات كتلة الجسم.',
        time: 'أمس، 8:00 ص',
        statusLabel: 'تم التسجيل (74.2 كجم)',
        statusDone: true,
      ),
      NotificationEntry(
        id: 'n4',
        category: NotificationCategory.planUpdates,
        variant: NotificationVariant.planSync,
        emoji: '⚡',
        title: 'اكتملت مزامنة خطة الأيض الذكية',
        body: 'تم تحديث توزيع النشويات والبروتين للأيام القادمة وفقاً لنشاطك البدني ومعدل حرق الطاقة.',
        time: 'أمس، 6:30 م',
        statLabel: 'الالتزام بالخطة الأسبوعية',
        statValue: '94% ممتاز',
        syncPercent: 0.94,
      ),
    ]),
  ];
}
