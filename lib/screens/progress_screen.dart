import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../core/navigation/app_page_route.dart';
import 'measurement_guide_screen.dart';
import 'new_measurement_screen.dart';

/// متابعة التقدم والتقييم — specialist header, weight progress, weight
/// trend chart, vital measurements, weekly evaluation, encouragement note
/// with voice message, next-week tasks and WhatsApp CTA.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // ألوان مقدّرة من اللقطة؛ استبدلها برموز الثيم إن وُجد ما يقابلها.
  static const Color _teal = Color(0xFF0E7C86);
  static const Color _lavender = Color(0xFFF2F4FC);
  static const Color _mint = Color(0xFF6FF0CF);

  int _tab = 0;
  int _chartRange = 0; // 0 = 30 يوماً، 1 = 90 يوماً
  final Set<int> _doneTasks = {0, 1};
  final GlobalKey _progressKey = GlobalKey();
  final GlobalKey _notesKey = GlobalKey();

  void _selectTab(int i) {
    setState(() => _tab = i);
    final ctx = (i == 0 ? _progressKey : _notesKey).currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _headerCard(),
              const SizedBox(height: 16),
              _tabs(),
              const SizedBox(height: 16),
              KeyedSubtree(key: _progressKey, child: _weightCard()),
              const SizedBox(height: 16),
              _chartCard(),
              const SizedBox(height: 20),
              _vitalsSection(),
              const SizedBox(height: 12),
              _guideLink(),
              const SizedBox(height: 16),
              KeyedSubtree(key: _notesKey, child: _evaluationCard()),
              const SizedBox(height: 16),
              _encouragementCard(),
              const SizedBox(height: 16),
              _tasksCard(),
              const SizedBox(height: 16),
              _whatsappButton(),
              const SizedBox(height: 12),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Flexible(
                  child: Text('الموعد الاستشاري القادم: الأحد القادم، الساعة 5:00 مساءً',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1) بطاقة العنوان والأخصائية ────────────────────────────────────────
  Widget _headerCard() {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text('متابعة التقدم والتقييم',
                style: AppTextStyles.sectionHeading.copyWith(fontSize: 16)),
          ),
          const _Pill(
            color: _lavender,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified_outlined, size: 15, color: _teal),
              SizedBox(width: 4),
              Text('ملف نشط', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ]),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('مزامنة مباشرة مع العيادة',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontSize: 11)),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _lavender, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const _SpecialistAvatar(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('د. خلود العربي', style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                const Text('أخصائية التغذية العلاجية', style: AppTextStyles.caption),
              ]),
            ),
            const _Pill(
              color: AppColors.surface,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.forum_outlined, size: 14, color: _teal),
                SizedBox(width: 4),
                Text('متصلة الآن', style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── 2) التبويبات ──────────────────────────────────────────────────────
  Widget _tabs() {
    Widget item(int i, IconData icon, String label, {String? badge}) {
      final selected = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => _selectTab(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 44,
            decoration: BoxDecoration(
              color: selected ? _teal : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 17, color: selected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.textSecondary)),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                _Pill(
                  color: _mint,
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  child: Text(badge,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0B4F44))),
                ),
              ],
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _lavender,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(children: [
        item(0, Icons.trending_down_rounded, 'التقدّم والقياسات'),
        item(1, Icons.assignment_ind_outlined, 'ملاحظات الأخصائي', badge: 'جديد'),
      ]),
    );
  }

  // ── 3) بطاقة الوزن ────────────────────────────────────────────────────
  Widget _weightCard() {
    return _Card(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('الوزن الحالي المسجل', style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text('68.5',
                  style: AppTextStyles.metricMedium.copyWith(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              Text('كجم', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ]),
          const Spacer(),
          _Pill(
            color: _lavender,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.arrow_downward_rounded, size: 14, color: _teal),
              const SizedBox(width: 4),
              Text('-2.3 كجم هذا الشهر',
                  style: AppTextStyles.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Text('الأساس: 70.8 كجم', style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
          const Spacer(),
          Text('الهدف المرحلي: 65 كجم', style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(children: [
            Container(height: 10, color: const Color(0xFFE6EBFA)),
            FractionallySizedBox(
              widthFactor: 0.62,
              alignment: AlignmentDirectional.centerStart,
              child: Container(height: 10, color: AppColors.primary),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Text('تم إنجاز 62% من الخطة',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          const Spacer(),
          const Text('المتبقي: 3.5 كجم', style: AppTextStyles.caption),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            onPressed: () => Navigator.of(context).push(
              AppPageRoute(
                builder: (_) => MeasurementEntryScreen(
                  onSaved: () => setState(() {}),
                ),
              ),
            ),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_circle_outline_rounded, size: 20),
              SizedBox(width: 8),
              Text('تسجيل وزن جديد اليوم'),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── 4) مسار الوزن ─────────────────────────────────────────────────────
  Widget _chartCard() {
    Widget rangeItem(int i, String label) {
      final sel = _chartRange == i;
      return GestureDetector(
        onTap: () => setState(() => _chartRange = i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: sel ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? AppColors.textPrimary : AppColors.textSecondary)),
        ),
      );
    }

    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('مسار نزول الوزن', style: AppTextStyles.sectionHeading.copyWith(fontSize: 15)),
            const SizedBox(height: 3),
            const Text('مقارنة بين قياس العيادة والمنزل', style: AppTextStyles.caption),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: _lavender, borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              rangeItem(0, '30 يوماً'),
              rangeItem(1, '90 يوماً'),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        const SizedBox(
          height: 170,
          child: CustomPaint(size: Size.infinite, painter: _WeightChartPainter()),
        ),
        const SizedBox(height: 6),
        // محور التاريخ: "اليوم" يساراً كما في التصميم.
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.only(left: 34, right: 34),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('اليوم', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text('20 سبتمبر', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              Text('10 سبتمبر', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              Text('1 سبتمبر', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(color: _lavender, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                  color: _mint, shape: BoxShape.circle, border: Border.all(color: _teal, width: 2)),
            ),
            const SizedBox(width: 6),
            Text('قياس العيادة المعتمد',
                style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 11)),
            const SizedBox(width: 22),
            Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: Color(0xFF0E6F78), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('قياس بيتي دوري',
                style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 11)),
          ]),
        ),
      ]),
    );
  }

  // ── 5) القياسات الحيوية ───────────────────────────────────────────────
  Widget _vitalsSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text('محيط القياسات الحيوية', style: AppTextStyles.sectionHeading.copyWith(fontSize: 15)),
        const Spacer(),
        const Text('آخر تحديث قبل يومين', style: AppTextStyles.caption),
      ]),
      const SizedBox(height: 12),
      const Row(children: [
        Expanded(child: _VitalCard(label: 'الخصر', value: '78', delta: '-4 سم', icon: Icons.accessibility_new_rounded)),
        SizedBox(width: 12),
        Expanded(child: _VitalCard(label: 'الورك', value: '98', delta: '-2 سم', icon: Icons.straighten_rounded)),
      ]),
      const SizedBox(height: 12),
      const Row(children: [
        Expanded(child: _VitalCard(label: 'الفخذ', value: '54', delta: '-1 سم', icon: Icons.directions_run_rounded)),
        SizedBox(width: 12),
        Expanded(child: _VitalCard(label: 'الذراع', value: '28', delta: '-1 سم', icon: Icons.open_in_full_rounded)),
      ]),
    ]);
  }

  Widget _guideLink() {
    return Material(
      color: _lavender,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          AppPageRoute(builder: (_) => const MeasurementGuideScreen()),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            Icon(Icons.square_foot_rounded, size: 18, color: _teal),
            SizedBox(width: 8),
            Expanded(
              child: Text('دليل القياس المصور المعتمد (P-32)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _teal)),
            ),
            Icon(Icons.arrow_back_rounded, size: 18, color: _teal),
          ]),
        ),
      ),
    );
  }

  // ── 6) تقييم الأسبوع ──────────────────────────────────────────────────
  Widget _evaluationCard() {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text('تقييم الأسبوع الحالي', style: AppTextStyles.sectionHeading.copyWith(fontSize: 15)),
          const Spacer(),
          const _Pill(
            color: _mint,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle_outline_rounded, size: 15, color: Color(0xFF0B4F44)),
              SizedBox(width: 4),
              Text('التزام 92%',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0B4F44))),
            ]),
          ),
        ]),
        const SizedBox(height: 4),
        const Text('تمت المراجعة من د. أمل العفيفي', style: AppTextStyles.caption),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: _lavender, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF5A623)),
            const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF5A623)),
            const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF5A623)),
            const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF5A623)),
            const Icon(Icons.star_half_rounded, size: 20, color: Color(0xFFF5A623)),
            const SizedBox(width: 8),
            Text('4.5 / 5.0', style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
            const Spacer(),
            Text('أداء ممتاز',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 12),
        Text(
          'استجابة ممتازة لمقاومة الإنسولين، مع تحسن ملموس في توازن الطاقة الحيوية أثناء ساعات الصباح وثبات ملحوظ في قياسات الخصر.',
          textAlign: TextAlign.right,
          style: AppTextStyles.caption.copyWith(height: 2.0, color: AppColors.textPrimary),
        ),
      ]),
    );
  }

  // ── 7) الرسالة التشجيعية + الملاحظة الصوتية ───────────────────────────
  Widget _encouragementCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _lavender, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Row(children: [
          Icon(Icons.format_quote_rounded, size: 22, color: _teal),
          SizedBox(width: 6),
          Text('رسالة تشجيعية خاصة',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _teal)),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
          child: Text(
            '“فخورة جداً بوعيك والتزامك هذا الأسبوع يا سارة! النزول تدريجي وصحي ومحيط الخصر تحسن بشكل ملحوظ. حافظي على نمط النوم الحالي وسنصل لهدف الشهر بكل سهولة”',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(height: 2.0, fontSize: 12.5, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  const Text('ملاحظة صوتية من الدكتورة', style: AppTextStyles.caption),
                  const Spacer(),
                  Text('0:48', style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 6),
                const SizedBox(height: 26, child: CustomPaint(painter: _WaveformPainter())),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── 8) توجيهات الأسبوع القادم ─────────────────────────────────────────
  Widget _tasksCard() {
    const tasks = [
      (Icons.water_drop_outlined, 'زيادة شرب الماء لـ 2.5 لتر يومياً',
          'توزيع منتظم بمعدل كوب كل ساعتين بين الوجبات لتعزيز الأيض.'),
      (Icons.restaurant_rounded, 'بديل جبنة القريش مع زيت الزيتون',
          'اعتمادك كوجبة عشاء رئيسية لدعم الشبع البطيء وموازنة سكر الدم ليلاً.'),
      (Icons.directions_walk_rounded, '15 دقيقة مشي خفيف بعد العشاء',
          'تنشيط الدورة الدموية وتفريغ مخازن الجليكوجين قبل النوم.'),
    ];
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text('توجيهات الأسبوع القادم', style: AppTextStyles.sectionHeading.copyWith(fontSize: 15)),
          const Spacer(),
          const Text('3 مهام محددة', style: AppTextStyles.caption),
        ]),
        const SizedBox(height: 12),
        for (var i = 0; i < tasks.length; i++)
          _TaskRow(
            icon: tasks[i].$1,
            title: tasks[i].$2,
            subtitle: tasks[i].$3,
            done: _doneTasks.contains(i),
            onTap: () => setState(() {
              _doneTasks.contains(i) ? _doneTasks.remove(i) : _doneTasks.add(i);
            }),
          ),
      ]),
    );
  }

  // ── 9) زر واتساب ──────────────────────────────────────────────────────
  Widget _whatsappButton() {
    return SizedBox(
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        // TODO: فتح محادثة واتساب مع الأخصائية (url_launcher).
        onPressed: () {},
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.chat_outlined, size: 19),
          SizedBox(width: 8),
          Flexible(child: Text('مناقشة التقييم عبر الواتساب مباشرة')),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// مكونات مساعدة
// ═════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Pill({
    required this.color,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: child,
    );
  }
}

/// صورة الأخصائية مع نقطة اتصال خضراء أسفل اليسار.
class _SpecialistAvatar extends StatelessWidget {
  const _SpecialistAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(clipBehavior: Clip.none, children: [
        ClipOval(
          child: Image.asset(
            // TODO: replace with the real asset path of the specialist photo.
            'assets/images/specialist_khulood.jpg',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              color: AppColors.primaryTint,
              child: Text('خ', style: AppTextStyles.h1.copyWith(color: AppColors.primary, fontSize: 22)),
            ),
          ),
        ),
        PositionedDirectional(
          bottom: -1,
          end: -1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ]),
    );
  }
}

/// بطاقة قياس حيوي: الاسم يميناً وأيقونة يساراً، والقيمة يميناً ومؤشر التغيّر يساراً.
class _VitalCard extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  const _VitalCard({required this.label, required this.value, required this.delta, required this.icon});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: const Color(0xFFF2F4FC), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: const Color(0xFF0E7C86)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTextStyles.metricMedium.copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              const Text('سم', style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          _Pill(
            color: const Color(0xFFF2F4FC),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(delta,
                style: AppTextStyles.caption.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ]),
      ]),
    );
  }
}

/// مهمة أسبوعية: مربع اختيار يميناً (ممتلئ عند الإنجاز) ثم الأيقونة والعنوان والشرح.
class _TaskRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;
  const _TaskRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF6F7FC), borderRadius: BorderRadius.circular(12)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: done ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.6), width: 1.5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, size: 17, color: const Color(0xFF0E7C86)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(title, style: AppTextStyles.body.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.right, style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// مخطط مسار الوزن: منحنى ناعم بتظليل متدرج، نقاط، خطوط شبكة متقطعة وتلميح.
class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter();

  static const Color _teal = Color(0xFF0E6F78);
  static const Color _mint = Color(0xFF6FF0CF);
  static const Color _navy = Color(0xFF1F2A44);

  // (x, y) كنسب من منطقة الرسم؛ y: 0 = أعلى خط شبكة، 1 = أسفله.
  static const List<Offset> _pts = [
    Offset(0, 0),
    Offset(0.18, 0.19),
    Offset(0.52, 0.57),
    Offset(0.67, 0.77),
    Offset(0.85, 0.89),
    Offset(1, 1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const l = 34.0, r = 34.0, t = 14.0, b = 12.0;
    final plot = Rect.fromLTRB(l, t, size.width - r, size.height - b);

    final grid = Paint()
      ..color = const Color(0xFFD5DBEE)
      ..strokeWidth = 1;
    const labels = ['70', '69.5', '68'];
    for (var i = 0; i < 3; i++) {
      final y = plot.top + plot.height * i / 2;
      _dashed(canvas, Offset(plot.left, y), Offset(plot.right, y), grid);
      final tp = TextPainter(
        text: TextSpan(
            text: labels[i],
            style: const TextStyle(fontSize: 10, color: Color(0xFF7A8197), fontFamily: AppTextStyles.fontFamily)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final pts = [for (final p in _pts) Offset(plot.left + p.dx * plot.width, plot.top + p.dy * plot.height)];
    final line = _smooth(pts);

    final area = Path.from(line)
      ..lineTo(pts.last.dx, plot.bottom)
      ..lineTo(pts.first.dx, plot.bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_teal.withValues(alpha: 0.28), _teal.withValues(alpha: 0)],
        ).createShader(plot),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = _teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < pts.length; i++) {
      final end = i == 0 || i == pts.length - 1;
      final radius = end ? 7.0 : 5.5;
      canvas.drawCircle(pts[i], radius, Paint()..color = end ? _mint : Colors.white);
      canvas.drawCircle(
        pts[i],
        radius,
        Paint()
          ..color = _teal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // التلميح فوق النقطة الأخيرة.
    final tp = TextPainter(
      text: const TextSpan(
          text: '68.5 كجم',
          style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700, fontFamily: AppTextStyles.fontFamily)),
      textDirection: TextDirection.rtl,
    )..layout();
    final c = Offset(pts.last.dx - 2, pts.last.dy - 30);
    final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: tp.width + 20, height: 24), const Radius.circular(8));
    canvas.drawRRect(rr, Paint()..color = _navy);
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  Path _smooth(List<Offset> p) {
    final path = Path()..moveTo(p[0].dx, p[0].dy);
    for (var i = 0; i < p.length - 1; i++) {
      final p0 = i > 0 ? p[i - 1] : p[i];
      final p1 = p[i];
      final p2 = p[i + 1];
      final p3 = i + 2 < p.length ? p[i + 2] : p[i + 1];
      final c1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final c2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 5.0, gap = 4.0;
    var x = a.dx;
    while (x < b.dx) {
      canvas.drawLine(Offset(x, a.dy), Offset((x + dash).clamp(a.dx, b.dx), a.dy), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// موجة صوتية: الجزء المُشغَّل (من اليمين) بلون داكن، والباقي رمادي فاتح.
class _WaveformPainter extends CustomPainter {
  const _WaveformPainter();

  static const List<double> _h = [
    6, 10, 16, 12, 18, 14, 9, 20, 24, 15, 11, 19, 25, 21, 15, 23, 17, 11, 7, 13, 9, 5,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const w = 3.0;
    final gap = (size.width - _h.length * w) / (_h.length - 1);
    const played = 10;
    for (var i = 0; i < _h.length; i++) {
      final x = size.width - i * (w + gap) - w;
      final h = _h[i].clamp(4.0, size.height);
      final color = i < played
          ? Color.lerp(const Color(0xFF0B5D56), const Color(0xFF3F9A93), i / played)!
          : const Color(0xFFC9CFE0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x + w / 2, size.height / 2), width: w, height: h),
          const Radius.circular(2),
        ),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
