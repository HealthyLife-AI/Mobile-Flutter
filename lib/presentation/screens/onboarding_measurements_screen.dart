import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/onboarding_reveal.dart';
import '../widgets/onboarding_step_header.dart';
import 'measurement_guide_screen.dart';
import 'onboarding_health_screen.dart';
import '../../core/navigation/app_page_route.dart';

/// Onboarding step 1/3 — "القياسات الأولية": the mandatory baseline weight
/// plus optional body-circumference fields the specialist uses to gauge
/// fat distribution. This is the very first data point ever recorded for
/// the patient, distinct from [MeasurementEntryScreen] which is used for
/// every later re-measurement once a plan is already active.
class OnboardingMeasurementsScreen extends StatefulWidget {
  const OnboardingMeasurementsScreen({super.key});

  @override
  State<OnboardingMeasurementsScreen> createState() => _OnboardingMeasurementsScreenState();
}

class _OnboardingMeasurementsScreenState extends State<OnboardingMeasurementsScreen> {
  static const double _minWeight = 20.0;
  static const double _maxWeight = 300.0;

  double _weight = 70.5;
  late final List<double> _weightOptions = List<double>.generate(
    ((_maxWeight - _minWeight) * 10).round() + 1,
    (index) => _minWeight + (index / 10),
  );
  final Map<String, TextEditingController> _circumference = {
    'waist': TextEditingController(text: '82'),
    'hip': TextEditingController(text: '98'),
    'thigh': TextEditingController(text: '54'),
  };

  @override
  void dispose() {
    for (final c in _circumference.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _changeWeight(double delta) => setState(() => _weight = (_weight + delta).clamp(_minWeight, _maxWeight));

  Future<void> _openWeightPicker() async {
    final initialIndex = (_weight - _minWeight) * 10;
    final controller = FixedExtentScrollController(initialItem: initialIndex.round().clamp(0, _weightOptions.length - 1));
    double selectedWeight = _weight;

    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        const Spacer(),
                        const Text('اختر وزنك', style: AppTextStyles.sectionHeading),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(selectedWeight),
                          child: const Text('تأكيد', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 220,
                      child: ListWheelScrollView.useDelegate(
                        controller: controller,
                        itemExtent: 52,
                        perspective: 0.01,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setSheetState(() => selectedWeight = _weightOptions[index]);
                        },
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: _weightOptions
                              .map(
                                (value) => Center(
                                  child: Text(
                                    '${value.toStringAsFixed(1)} كجم',
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: value == selectedWeight ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      setState(() => _weight = result);
    }
  }

  void _continue() {
    Navigator.of(context).push(AppPageRoute(builder: (_) => const OnboardingHealthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const OnboardingReveal(
                dy: -0.08,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: OnboardingStepHeader(title: 'القياسات الأولية', step: 1),
                ),
              ),
              Expanded(
                child: OnboardingReveal(
                  delay: const Duration(milliseconds: 120),
                  child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text('قياساتك الأولية', style: AppTextStyles.sectionHeading),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'أدخل وزنك وقياساتك اليوم لنبدأ بتتبع رحلتك الصحية مع الأخصائي بدقة واحترافية.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.monitor_weight_outlined, color: AppColors.primary, size: 16),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text('الوزن الحالي', textAlign: TextAlign.right, style: AppTextStyles.sectionHeading),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.pill)),
                                child: const Text('إلزامي', style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _RoundStepBtn(icon: Icons.add_rounded, onTap: () => _changeWeight(0.1)),
                              Expanded(
                                child: GestureDetector(
                                  key: const ValueKey('weight_selector_trigger'),
                                  onTap: _openWeightPicker,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(_weight.toStringAsFixed(1), style: AppTextStyles.metricLarge.copyWith(fontSize: 34)),
                                            const SizedBox(width: 6),
                                            const Padding(
                                              padding: EdgeInsets.only(bottom: 8),
                                              child: Text('كجم', style: AppTextStyles.secondary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        const Text('اضغط للاختيار', style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              _RoundStepBtn(icon: Icons.remove_rounded, onTap: () => _changeWeight(-0.1)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: ((_weight - 40) / (160 - 40)).clamp(0, 1),
                              minHeight: 6,
                              backgroundColor: AppColors.neutralTrack,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              Text('160 كجم', style: AppTextStyles.caption),
                              Spacer(),
                              Text('المثالي التقديري: 65-72', style: AppTextStyles.caption),
                              Spacer(),
                              Text('40 كجم', style: AppTextStyles.caption),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
                            child: const Row(
                              children: [
                                Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.primary),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'نصيحة الأخصائي: يُفضل أخذ القياس صباحاً بعد الاستيقاظ مباشرة، بملابس خفيفة وقبل تناول الإفطار.',
                                    style: AppTextStyles.caption,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(AppPageRoute(builder: (_) => const MeasurementGuideScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                        child: const Row(
                          children: [
                            Icon(Icons.image_outlined, color: AppColors.primary, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'كيف آخذ قياساتي بشكل دقيق؟',
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('دليل مصور', style: AppTextStyles.pillLabel),
                            Icon(Icons.expand_more_rounded, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Icon(Icons.straighten_rounded, color: AppColors.textPrimary, size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('محيط الجسم', textAlign: TextAlign.right, style: AppTextStyles.sectionHeading)),
                        Text('اختياري', style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'قياسات إضافية تدعم دقة متابعة الأخصائي لمحيط الجسم ونسب توزيع الدهون بدقة.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CircumferenceField(index: 1, label: 'محيط الخصر', hint: 'عند أضيق نقطة', controller: _circumference['waist']!),
                    _CircumferenceField(index: 2, label: 'محيط الورك', hint: 'المنطقة الأكبر حجماً', controller: _circumference['hip']!),
                    _CircumferenceField(index: 3, label: 'محيط الفخذ', hint: 'أعلى الفخذ الأيمن', controller: _circumference['thigh']!),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'بياناتك وقياساتك مشفرة بالكامل بمعايير أمان صحية معتمدة، وتُعرض حصرياً لأخصائيتك المعتمدة لتصميم خطتك الغذائية الفردية.',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
              ),
              OnboardingReveal(
                dy: 0.18,
                delay: const Duration(milliseconds: 260),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: GradientCtaButton(label: 'حفظ والمتابعة', onPressed: _continue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundStepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundStepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class _CircumferenceField extends StatelessWidget {
  final int index;
  final String label;
  final String hint;
  final TextEditingController controller;

  const _CircumferenceField({required this.index, required this.label, required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
            child: Text('$index', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, textAlign: TextAlign.right, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                Text(hint, textAlign: TextAlign.right, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.cardTitle,
              decoration: const InputDecoration(isDense: true, border: InputBorder.none, suffixText: 'سم', suffixStyle: AppTextStyles.caption),
            ),
          ),
        ],
      ),
    );
  }
}
