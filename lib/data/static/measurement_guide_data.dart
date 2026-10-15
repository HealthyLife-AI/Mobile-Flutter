import '../../domain/entities/measurement_entities.dart';

/// Static content for the measurement guide screen: the steps for each body
/// part. No readings live here; those come from the API.
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
        GuideStep(
            'قف بشكل مستقيم وازفر الهواء براحة واسترخاء دون حبس النفس داخل البطن.'),
        GuideStep(
            'ضع شريط القياس أفقياً عند أضيق نقطة في الجذع (غالباً أعلى السرة بحوالي 2-3 سم).'),
        GuideStep(
            'تأكد أن الشريط موازٍ لسطح الأرض ولا يضغط على الجلد أو يغوص فيه إطلاقاً.'),
      ],
    ),
    MeasurementGuidePart(
      key: 'hip',
      labelAr: 'محيط الورك',
      labelEn: 'Hips',
      positionBadge: 'القدمين متلاصقتين',
      cornerHint: 'أعرض نقطة في الحوض',
      steps: [
        GuideStep(
            'قف مع ضم القدمين تماماً جنباً إلى جنب وتوزيع وزن الجسم بالتساوي بين القدمين.'),
        GuideStep('لف الشريط حول أعرض نقطة من محيط الحوض والأرداف بعناية.'),
        GuideStep(
            'حافظ على استواء الشريط أفقياً من الأمام والخلف وتفقد بالمرآة إن تطلب الأمر.'),
      ],
    ),
    MeasurementGuidePart(
      key: 'thigh',
      labelAr: 'محيط الفخذ',
      labelEn: 'Thigh',
      positionBadge: 'عضلة مسترخية',
      cornerHint: 'منتصف مسافة الفخذ',
      steps: [
        GuideStep(
            'قف مع إراحة الساق المراد قياسها دون شد العضلات، وثني الركبة قليلاً.'),
        GuideStep(
            'حدد نقطة منتصف المسافة بالضبط بين مفصل الورك وأعلى عظمة صابونة الركبة.'),
        GuideStep(
            'قس نفس الجهة (اليمنى أو اليسرى) دائماً في كل زيارة لضمان دقة المقارنة وتتبع التطور.'),
      ],
    ),
    MeasurementGuidePart(
      key: 'arm',
      labelAr: 'محيط الذراع',
      labelEn: 'Arm',
      positionBadge: 'وضعية الاسترخاء',
      cornerHint: 'منتصف عضلة الذراع',
      steps: [
        GuideStep(
            'اترك الذراع مسترخية تماماً على جانبك (تجنب شد أو قبض عضلة البايسبس).'),
        GuideStep(
            'ضع شريط القياس في منتصف المسافة بين عظمة أعلى الكتف ورأس الكوع.'),
        GuideStep(
            'لف الشريط باعتدال واقرأ الرقم مباشرة دون إمالة الشريط بزاوية مائلة.'),
      ],
    ),
  ];
}
