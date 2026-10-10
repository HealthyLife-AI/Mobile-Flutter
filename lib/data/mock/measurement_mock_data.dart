import '../../domain/entities/measurement_entities.dart';

/// Mock measurement data shaped like `POST /me/measurements` /
/// `GET /clients/{id}/progress` responses.

class MeasurementMockData {
  MeasurementMockData._();

  static const double currentWeight = 78.4;
  static const double previousWeight = 79.6;

  static final List<WeightPoint> weightTrend = [
    WeightPoint(date: DateTime(2025, 9, 5), kg: 80.8, clinicVerified: false),
    WeightPoint(date: DateTime(2025, 9, 9), kg: 80.1, clinicVerified: false),
    WeightPoint(date: DateTime(2025, 9, 13), kg: 79.6, clinicVerified: true),
    WeightPoint(date: DateTime(2025, 9, 16), kg: 78.9, clinicVerified: false),
    WeightPoint(date: DateTime(2025, 9, 19), kg: 78.4, clinicVerified: true),
  ];

  static const List<CircumferenceStat> circumference = [
    CircumferenceStat(label: 'محيط الخصر', valueCm: 82, deltaCm: -1),
    CircumferenceStat(label: 'محيط الورك', valueCm: 98, deltaCm: null),
    CircumferenceStat(label: 'محيط الفخذ', valueCm: 54, deltaCm: -0.5),
    CircumferenceStat(label: 'محيط الذراع', valueCm: 29, deltaCm: null),
  ];

  static const int daysLoggedThisWeek = 5;
  static const int daysLoggedThisMonth = 22;
}

class MeasurementGuideData {
  MeasurementGuideData._();

  static const List<MeasurementGuidePart> parts = [
    MeasurementGuidePart(
      key: 'waist',
      labelAr: 'محيط الخصر',
      labelEn: 'Waist',
      positionBadge: 'نقطة ارتكاز حيوية',
      cornerHint: 'أعلى السرة بـ 2-3 سم',
      steps: [
        GuideStep('قف بشكل مستقيم وازفر الهواء براحة واسترخاء دون حبس النفس داخل البطن.'),
        GuideStep('ضع شريط القياس أفقياً عند أضيق نقطة في الجذع (غالباً أعلى السرة بحوالي 2-3 سم).'),
        GuideStep('تأكد أن الشريط موازٍ لسطح الأرض ولا يضغط على الجلد أو يغوص فيه إطلاقاً.'),
      ],
    ),
    MeasurementGuidePart(
      key: 'hip',
      labelAr: 'محيط الورك',
      labelEn: 'Hips',
      positionBadge: 'القدمين متلاصقتين',
      cornerHint: 'أعرض نقطة في الحوض',
      steps: [
        GuideStep('قف مع ضم القدمين تماماً جنباً إلى جنب وتوزيع وزن الجسم بالتساوي بين القدمين.'),
        GuideStep('لف الشريط حول أعرض نقطة من محيط الحوض والأرداف بعناية.'),
        GuideStep('حافظ على استواء الشريط أفقياً من الأمام والخلف وتفقد بالمرآة إن تطلب الأمر.'),
      ],
    ),
    MeasurementGuidePart(
      key: 'thigh',
      labelAr: 'محيط الفخذ',
      labelEn: 'Thigh',
      positionBadge: 'عضلة مسترخية',
      cornerHint: 'منتصف مسافة الفخذ',
      steps: [
        GuideStep('قف مع إراحة الساق المراد قياسها دون شد العضلات، وثني الركبة قليلاً.'),
        GuideStep('حدد نقطة منتصف المسافة بالضبط بين مفصل الورك وأعلى عظمة صابونة الركبة.'),
        GuideStep('قس نفس الجهة (اليمنى أو اليسرى) دائماً في كل زيارة لضمان دقة المقارنة وتتبع التطور.'),
      ],
    ),
    MeasurementGuidePart(
      key: 'arm',
      labelAr: 'محيط الذراع',
      labelEn: 'Arm',
      positionBadge: 'وضعية الاسترخاء',
      cornerHint: 'منتصف عضلة الذراع',
      steps: [
        GuideStep('اترك الذراع مسترخية تماماً على جانبك (تجنب شد أو قبض عضلة البايسبس).'),
        GuideStep('ضع شريط القياس في منتصف المسافة بين عظمة أعلى الكتف ورأس الكوع.'),
        GuideStep('لف الشريط باعتدال واقرأ الرقم مباشرة دون إمالة الشريط بزاوية مائلة.'),
      ],
    ),
  ];
}

