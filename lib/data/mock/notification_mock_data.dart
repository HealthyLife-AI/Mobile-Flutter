import '../../domain/entities/notification_entities.dart';

/// Mock notification feed. Category labels/icons live in
/// `lib/presentation/notification_category_labels.dart`.

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
        body:
            'لا تنسَ تسجيل وجبة الغداء المقررة (سلطة الدجاج والكينوا) للحفاظ على تسلسل التزامك وتحقيق أهداف طاقتك.',
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
        // The nutritionist's name is not baked in: the repository fills the
        // {specialist} placeholder from the patient's real profile, and the
        // generic wording stays until one is known.
        title: 'ملاحظة جديدة من {specialist}',
        body:
            'قامت الأخصائية بزيادة حصة الماء اليومية وتحديث تقييمك الأسبوعي استناداً لمعدل حرق الأمس. اضغط للمعاينة.',
        time: 'منذ ساعتين',
        unread: true,
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
        body:
            'يرجى أخذ قياس الوزن الصباحي وتسجيله قبل تناول وجبة الفطور للحفاظ على دقة مؤشرات كتلة الجسم.',
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
        body:
            'تم تحديث توزيع النشويات والبروتين للأيام القادمة وفقاً لنشاطك البدني ومعدل حرق الطاقة.',
        time: 'أمس، 6:30 م',
        statLabel: 'الالتزام بالخطة الأسبوعية',
        statValue: '94% ممتاز',
        syncPercent: 0.94,
      ),
    ]),
  ];
}
