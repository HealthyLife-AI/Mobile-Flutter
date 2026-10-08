import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/clinical_trust_footer.dart';
import 'measurement_guide_screen.dart';
import 'first_measurement_screen.dart';
import '../widgets/app_header_bar.dart';
import '../core/navigation/app_page_route.dart';

/// "تفاصيل القياس" — POST /me/measurements. Weight is required; every
/// circumference field is optional ("سجّلي ما يتوفر لديك فقط دون أي إلزام").
class MeasurementEntryScreen extends StatefulWidget {
  final VoidCallback? onSaved;

  const MeasurementEntryScreen({super.key, this.onSaved});

  @override
  State<MeasurementEntryScreen> createState() => _MeasurementEntryScreenState();
}

class _MeasurementEntryScreenState extends State<MeasurementEntryScreen>
    with SingleTickerProviderStateMixin {
  static const double _previousWeight = 78.4;

  double _weight = 78.4;
  bool _circumferenceExpanded = true;
  late final AnimationController _enter;

  final Map<String, String> _lastValues = const {
    'waist': '82',
    'hip': '98',
    'thigh': '54',
    'arm': '29',
  };

  final Map<String, TextEditingController> _controllers = {
    'waist': TextEditingController(),
    'hip': TextEditingController(),
    'thigh': TextEditingController(),
    'arm': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _changeWeight(double delta) {
    final double next = ((_weight + delta) * 10).round() / 10;
    setState(() => _weight = next.clamp(20.0, 300.0).toDouble());
  }

  /// Staggered entrance: fade + slide up, each section starts a bit later.
  Widget _reveal(int index, Widget child) {
    final double start = (index * 0.12).clamp(0.0, 0.7).toDouble();
    final double end = (start + 0.5).clamp(0.0, 1.0).toDouble();
    final Animation<double> curved = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  void _openGuide() {
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => const MeasurementGuideScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppHeaderBar(title: 'تفاصيل القياس'),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
          children: [
            _reveal(0, _buildGuideCard()),
            const SizedBox(height: 14),
            _reveal(1, _buildDateCard()),
            const SizedBox(height: 14),
            _reveal(2, _buildWeightCard()),
            const SizedBox(height: 14),
            _reveal(3, _buildCircumferenceCard()),
            const SizedBox(height: 14),
            _reveal(4, _buildPrivacyCard()),
            const SizedBox(height: 18),
            _reveal(
              5,
              Column(
                children: [
                  _PressScale(
                    child: GradientCtaButton(
                      label: 'حفظ القياسات',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () {
                        if (widget.onSaved != null) {
                          widget.onSaved!();
                          Navigator.of(context).pop();
                          return;
                        }

                        Navigator.of(context).push(
                          AppPageRoute(
                            builder: (_) => FirstMeasurementScreen(
                              weightKg: double.parse(_weight.toStringAsFixed(1)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء والعودة للتقدّم',
                        style: AppTextStyles.secondary),
                  ),
                  const ClinicalTrustFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Sections ─────────────────────────

  Widget _buildGuideCard() {
    return _SectionCard(
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 310;

          final button = Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _PressScale(
              child: GestureDetector(
                onTap: _openGuide,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('عرض', style: AppTextStyles.pillLabel),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_back_rounded,
                          size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconSquare(
                icon: Icons.lightbulb_outline_rounded,
                circle: true,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('دليل القياس المصوّر',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle),
                    const SizedBox(height: 2),
                    const Text('خطوات بسيطة للحصول على قراءة دقيقة',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption),
                    if (compact) ...[
                      const SizedBox(height: 10),
                      button,
                    ],
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 10),
                button,
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('تاريخ تسجيل القياس', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle),
              ),
              const SizedBox(width: 8),
              Icon(Icons.event_busy_outlined,
                  size: 13,
                  color: AppColors.textSecondary.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              const Flexible(
                child: Text(
                  'لا يمكن تحديد موعد مستقبلي',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
            ),
            child: const Row(
              children: [
                _IconSquare(icon: Icons.calendar_today_rounded, size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اليوم، الأحد 21 سبتمبر 2025',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body),
                      SizedBox(height: 2),
                      Text('توقيت التسجيل المقترح: صباحاً قبل الإفطار',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Icon(Icons.expand_more_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard() {
    final List<_QuickChip> chips = [
      const _QuickChip(label: '78.0', value: 78.0),
      const _QuickChip(label: 'السابق (78.4)', value: _previousWeight),
      const _QuickChip(label: '78.5', value: 78.5),
    ];

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconSquare(
                  icon: Icons.monitor_weight_outlined, size: 36),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('الوزن الحالي', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.sectionHeading),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Text('مطلوب',
                    style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Row(
                children: [
                  Icon(Icons.history_rounded,
                      size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'آخر قياس مسجل: 78.4 كغ (19 سبتمبر)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _RoundStepBtn(
                icon: Icons.remove_rounded,
                filled: true,
                onTap: () => _changeWeight(-0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.85, end: 1.0)
                                .animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          _weight.toStringAsFixed(1),
                          key: ValueKey<String>(_weight.toStringAsFixed(1)),
                          style: AppTextStyles.metricLarge
                              .copyWith(fontSize: 30),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('كغ', style: AppTextStyles.secondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _RoundStepBtn(
                icon: Icons.add_rounded,
                filled: false,
                onTap: () => _changeWeight(0.1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final double spacing = 8;
              final double chipWidth = constraints.maxWidth >= 330
                  ? (constraints.maxWidth - spacing * 2) / 3
                  : (constraints.maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: 8,
                children: chips.map((chip) {
                  final bool selected = (_weight - chip.value).abs() < 0.001;
                  return SizedBox(
                    width: chipWidth,
                    child: _PressScale(
                      child: GestureDetector(
                        onTap: () => setState(() => _weight = chip.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.primaryTint,
                            borderRadius:
                                BorderRadius.circular(AppRadius.cardSmall),
                          ),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: AppTextStyles.caption.copyWith(
                              color:
                                  selected ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            child: Text(chip.label,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
            ),
            child: const Row(
              children: [
                Text('🙂', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يساعد قياس الوزن المنتظم صباحاً بعد الاستيقاظ على تزويد أخصائيتك ببيانات موثوقة تعكس تطورك الحقيقي.',
                    textAlign: TextAlign.start,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircumferenceCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(
                () => _circumferenceExpanded = !_circumferenceExpanded),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _IconSquare(icon: Icons.straighten_rounded, size: 36),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'قياسات المحيط بشريط القياس',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sectionHeading,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text('اختياري',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.primary)),
                    ),
                    AnimatedRotation(
                      turns: _circumferenceExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: const Icon(Icons.expand_more_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text('سجّلي ما يتوفر لديك فقط دون أي إلزام',
              style: AppTextStyles.caption),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: _circumferenceExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _openGuide,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.cardSmall),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final detailsWidth =
                                    (constraints.maxWidth - 180)
                                        .clamp(90.0, double.infinity)
                                        .toDouble();

                                return Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    const Icon(Icons.open_in_new_rounded,
                                        size: 14, color: AppColors.primary),
                                     ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 120),
                                      child: Text(
                                        'كيف أقيس بدقة؟',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.pillLabel,
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: detailsWidth),
                                      child: const Text(
                                        'القياسات بالسنتيمتر (سم)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                        style: AppTextStyles.caption,
                                      ),
                                    ),
                                    const Icon(Icons.straighten_rounded,
                                        size: 14, color: AppColors.primary),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CircField(
                            label: 'محيط الخصر',
                            hint: 'عند أضيق نقطة فوق السرة',
                            controller: _controllers['waist']!,
                            lastValue: _lastValues['waist']!),
                        _CircField(
                            label: 'محيط الورك',
                            hint: 'عند أعرض نقطة في الحوض',
                            controller: _controllers['hip']!,
                            lastValue: _lastValues['hip']!),
                        _CircField(
                            label: 'محيط الفخذ',
                            hint: 'منتصف المسافة بين الورك والركبة',
                            controller: _controllers['thigh']!,
                            lastValue: _lastValues['thigh']!),
                        _CircField(
                            label: 'محيط الذراع',
                            hint: 'منتصف العضد مع استرخاء اليد',
                            controller: _controllers['arm']!,
                            lastValue: _lastValues['arm']!,
                            isLast: true),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return const _SectionCard(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconSquare(icon: Icons.verified_user_outlined, size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خصوصيتك الصحية أمانة', style: AppTextStyles.cardTitle),
                SizedBox(height: 4),
                Text(
                  'جميع بياناتك محمية وتصل بأمان لملفك الطبي المباشر لدى أ. خلود العربي دون أي أحكام أو تقييمات مسبقة، لتعديل خطتك بما يناسبك.',
                  textAlign: TextAlign.start,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Helpers ─────────────────────────

class _QuickChip {
  final String label;
  final double value;
  const _QuickChip({required this.label, required this.value});
}

/// White rounded card with a soft border and shadow.
class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Tinted icon container used in section headers.
class _IconSquare extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool circle;

  const _IconSquare({
    required this.icon,
    this.size = 36,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary, size: size * 0.5),
    );
  }
}

/// Wraps any child with a subtle "press down" scale animation without
/// stealing the child's own tap handling.
class _PressScale extends StatefulWidget {
  final Widget child;
  const _PressScale({required this.child});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _RoundStepBtn extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _RoundStepBtn({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primary : AppColors.surface,
            border: filled
                ? null
                : Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Icon(
            icon,
            color: filled ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _CircField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String lastValue;
  final bool isLast;

  const _CircField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.lastValue,
    this.isLast = false,
  });

  @override
  State<_CircField> createState() => _CircFieldState();
}

class _CircFieldState extends State<_CircField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.label, style: AppTextStyles.cardTitle),
          const SizedBox(height: 2),
          Text(widget.hint, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
              border: Border.all(
                color: _focus.hasFocus
                    ? AppColors.primary
                    : Colors.transparent,
                width: 1.4,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              textAlign: TextAlign.start,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'آخر قياس: ${widget.lastValue}',
                suffixText: 'سم',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
