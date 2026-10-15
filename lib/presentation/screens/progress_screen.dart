import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/errors/result.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/navigation/app_page_route.dart';
import 'measurement_guide_screen.dart';
import 'new_measurement_screen.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/measurement_entities.dart';
import '../../domain/entities/progress_entities.dart';
import '../../domain/entities/review_entities.dart';
import '../bloc/appointments/appointments_cubit.dart';
import '../bloc/nutritionist/nutritionist_cubit.dart';
import '../bloc/progress/progress_cubit.dart';
import '../bloc/measurements/measurements_cubit.dart';
import '../bloc/reviews/reviews_cubit.dart';
import '../people_view.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/load_error_view.dart';
import 'reviews_screen.dart';

import '../widgets/directional_icon.dart';
import '../widgets/person_avatar.dart';
import '../../l10n/l10n.dart';

/// متابعة التقدم والتقييم — specialist header, weight progress, weight
/// trend chart, circumferences, the nutritionist's latest note with its key
/// points and tasks, WhatsApp and the next appointment. Everything comes from
/// the patient's data (API guide 7, 8, 9 and 12); a part with nothing to show
/// is left out.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProgressCubit(deps.progress)..load()),
        BlocProvider(
          create: (_) => NutritionistCubit(deps.nutritionist)..load(),
        ),
        BlocProvider(create: (_) => ReviewsCubit(deps.reviews)..load()),
        BlocProvider(
            create: (_) => AppointmentsCubit(deps.appointments)..load()),
      ],
      child: const _ProgressBody(),
    );
  }
}

/// The screen's content. The cards read the cubits provided above it, and the
/// app-wide [MeasurementsCubit] for the circumferences.
class _ProgressBody extends StatefulWidget {
  const _ProgressBody();

  @override
  State<_ProgressBody> createState() => _ProgressBodyState();
}

class _ProgressBodyState extends State<_ProgressBody> {
  // ألوان مقدّرة من اللقطة؛ استبدلها برموز الثيم إن وُجد ما يقابلها.
  static const Color _teal = Color(0xFF0E7C86);
  static const Color _lavender = Color(0xFFF2F4FC);
  static const Color _mint = Color(0xFF6FF0CF);

  int _tab = 0;
  int _chartRange = 0; // 0 = 30 يوماً، 1 = 90 يوماً
  final GlobalKey _progressKey = GlobalKey();
  final GlobalKey _notesKey = GlobalKey();

  void _selectTab(int i) {
    setState(() => _tab = i);
    final ctx = (i == 0 ? _progressKey : _notesKey).currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic);
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
              ..._keyPointsCard(),
              ..._tasksCard(),
              ..._whatsappButton(),
              ..._nextAppointment(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Data-backed helpers (API guide 8) ───────────────────────────────────

  /// The current weight, or a dash when there is no reading.
  String _latestText(BuildContext context, ProgressSnapshot? snapshot) {
    final weight = snapshot?.latestWeightKg;
    if (weight == null) return '—';
    return context.localizeDigits(weight.toStringAsFixed(1));
  }

  /// The change over the window with its unit, such as "−2.3 kg" or "+0.5 kg".
  String _changeText(BuildContext context, ProgressSnapshot? snapshot) {
    final change = snapshot?.weightChangeKg ?? 0;
    final sign = change > 0 ? '+' : (change < 0 ? '−' : '');
    final digits = context.localizeDigits(change.abs().toStringAsFixed(1));
    return '$sign$digits ${context.l10n.commonKilogramsUnit}';
  }

  IconData _changeIcon(ProgressSnapshot? snapshot) =>
      (snapshot?.weightChangeKg ?? 0) > 0
          ? Icons.arrow_upward_rounded
          : Icons.arrow_downward_rounded;

  /// Dates under the chart. Today is the first label, on the left as in the
  /// design; the others are a third, two thirds and the whole window back.
  List<String> _axisLabels(BuildContext context, int days) {
    final now = DateTime.now();
    return [
      for (final ago in [days ~/ 3, days * 2 ~/ 3, days])
        context.localizeDigits(
            numericDate(DateTime(now.year, now.month, now.day - ago))),
    ];
  }

  /// Whole calendar days from [earlier] to [later], counted by date only, so a
  /// change of clocks does not move a reading by a day.
  static int _daysBetween(DateTime later, DateTime earlier) {
    final a = DateTime.utc(later.year, later.month, later.day);
    final b = DateTime.utc(earlier.year, earlier.month, earlier.day);
    return a.difference(b).inDays;
  }

  /// The weight chart, or what takes its place while the window loads, fails,
  /// or has no readings.
  Widget _chartBody(BuildContext context, AsyncState<ProgressSnapshot> state) {
    final snapshot = state.dataOrNull;
    if (snapshot == null) {
      if (state case AsyncError<ProgressSnapshot>(:final failure)) {
        return LoadErrorView(
          message: loadFailureMessage(context, failure),
          onRetry: () => context.read<ProgressCubit>().load(),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.weightTrend.isEmpty) {
      return Center(
        child: Text(
          context.l10n.progressNoReadings,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
      );
    }

    final days = context.read<ProgressCubit>().days;
    final today = DateTime.now();
    final points = [
      for (final p in snapshot.weightTrend)
        _ChartPoint(
          daysAgo: _daysBetween(today, p.recordedAt).toDouble(),
          weightKg: p.weightKg,
          clinic: p.isClinic,
        ),
    ]..sort((a, b) => a.daysAgo.compareTo(b.daysAgo));

    final weights = [for (final p in points) p.weightKg];
    final low = weights.reduce((a, b) => a < b ? a : b);
    final high = weights.reduce((a, b) => a > b ? a : b);
    final spread = high - low;
    final pad = spread * 0.15 < 0.5 ? 0.5 : spread * 0.15;
    final top = high + pad;
    final bottom = low - pad;
    String axis(double kg) => context.localizeDigits(kg.toStringAsFixed(1));

    return CustomPaint(
      size: Size.infinite,
      painter: _WeightChartPainter(
        points: points,
        days: days,
        top: top,
        bottom: bottom,
        yLabels: [axis(top), axis((top + bottom) / 2), axis(bottom)],
        tooltip:
            '${axis(points.first.weightKg)} ${context.l10n.commonKilogramsUnit}',
        textDirection: Directionality.of(context),
      ),
    );
  }

  // ── 1) بطاقة العنوان والأخصائية ────────────────────────────────────────
  Widget _headerCard() {
    final nutritionist = context.watch<NutritionistCubit>().state.dataOrNull;
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text(context.l10n.progressTitle,
                style: AppTextStyles.sectionHeading.copyWith(fontSize: 16)),
          ),
          _Pill(
            color: _lavender,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.verified_outlined, size: 15, color: _teal),
              const SizedBox(width: 4),
              Text(context.l10n.progressActiveFile,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ]),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                  color: AppColors.accentGreen, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(context.l10n.progressLiveSync,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primary, fontSize: 11)),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: _lavender, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const _SpecialistAvatar(),
            const SizedBox(width: 10),
            // No "online now" claim: the app does not know when the
            // nutritionist is available.
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (nutritionist != null) ...[
                      Text(nutritionist.name,
                          style:
                              AppTextStyles.cardTitle.copyWith(fontSize: 13)),
                      if (nutritionist.specialty != null) ...[
                        const SizedBox(height: 2),
                        Text(nutritionist.specialty!,
                            style: AppTextStyles.caption),
                      ],
                    ],
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
              Icon(icon,
                  size: 17,
                  color: selected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color:
                            selected ? Colors.white : AppColors.textSecondary)),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                _Pill(
                  color: _mint,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  child: Text(badge,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B4F44))),
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
        item(0, Icons.trending_down_rounded,
            context.l10n.progressAndMeasurements),
        // "New" only while the latest note waits for «فهمت».
        item(1, Icons.assignment_ind_outlined,
            context.l10n.progressSpecialistNotes,
            badge: _latestReview()?.isAcknowledged == false
                ? context.l10n.commonNew
                : null),
      ]),
    );
  }

  // ── 3) بطاقة الوزن ────────────────────────────────────────────────────
  Widget _weightCard() {
    final snapshot = context.watch<ProgressCubit>().state.dataOrNull;
    return _Card(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(context.l10n.progressCurrentWeight,
                style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(_latestText(context, snapshot),
                      style: AppTextStyles.metricMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(width: 4),
                  Text(context.l10n.commonKilogramsUnit,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700)),
                ]),
          ]),
          const Spacer(),
          if (snapshot?.weightChangeKg != null)
            _Pill(
              color: _lavender,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_changeIcon(snapshot), size: 14, color: _teal),
                const SizedBox(width: 4),
                Text(_changeText(context, snapshot),
                    style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ]),
            ),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              // The family is named: a button's text style replaces the
              // theme's, and would otherwise fall back to the system font.
              textStyle: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
            onPressed: () => Navigator.of(context).push(
              AppPageRoute(
                builder: (_) => MeasurementEntryScreen(
                  // Reload the progress chart and the app-wide measurements
                  // (which the shell's Progress gate reads) so the new weight
                  // shows everywhere at once.
                  onSaved: () {
                    setState(() {});
                    context.read<ProgressCubit>().load();
                    context.read<MeasurementsCubit>().load();
                  },
                ),
              ),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.add_circle_outline_rounded, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(context.l10n.progressLogWeightToday,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── 4) مسار الوزن ─────────────────────────────────────────────────────
  Widget _chartCard() {
    final cubit = context.watch<ProgressCubit>();
    Widget rangeItem(int i, String label) {
      final sel = _chartRange == i;
      return GestureDetector(
        onTap: () {
          setState(() => _chartRange = i);
          context.read<ProgressCubit>().load(days: i == 0 ? 30 : 90);
        },
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
                  color:
                      sel ? AppColors.textPrimary : AppColors.textSecondary)),
        ),
      );
    }

    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // The titles wrap on a narrow phone; the range toggle keeps its size.
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.l10n.progressWeightTrend,
                  style: AppTextStyles.sectionHeading.copyWith(fontSize: 15)),
              const SizedBox(height: 3),
              Text(context.l10n.progressClinicVsHome,
                  style: AppTextStyles.caption),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                color: _lavender,
                borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              rangeItem(0, context.l10n.progressRange30),
              rangeItem(1, context.l10n.progressRange90),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          height: 170,
          child: _chartBody(context, cubit.state),
        ),
        const SizedBox(height: 6),
        // محور التاريخ: "اليوم" يساراً كما في التصميم.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.only(left: 34, right: 34),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.commonToday,
                      style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  for (final label in _axisLabels(context, cubit.days))
                    Text(label,
                        style: const TextStyle(
                            fontSize: 10.5, color: AppColors.textSecondary)),
                ]),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
              color: _lavender, borderRadius: BorderRadius.circular(12)),
          // The two keys share a line when they fit, and stack otherwise.
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 22,
            runSpacing: 6,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                      color: _mint,
                      shape: BoxShape.circle,
                      border: Border.all(color: _teal, width: 2)),
                ),
                const SizedBox(width: 6),
                Text(context.l10n.progressClinicReading,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textPrimary, fontSize: 11)),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                        color: Color(0xFF0E6F78), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(context.l10n.progressHomeReading,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textPrimary, fontSize: 11)),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  // ── 5) القياسات الحيوية ───────────────────────────────────────────────
  /// The latest value of each circumference and its change since the reading
  /// before it, from the patient's readings (7.2). A part never measured shows
  /// a dash.
  Widget _vitalsSection() {
    final l10n = context.l10n;
    final snapshot = context.watch<MeasurementsCubit>().state.snapshot;
    final stats = {
      for (final stat in snapshot?.circumference ?? const <CircumferenceStat>[])
        stat.part: stat,
    };
    // The newest reading that measured any circumference.
    DateTime? updated;
    for (final entry in snapshot?.savedEntries ?? const <MeasurementEntry>[]) {
      final measured = entry.waistCm != null ||
          entry.hipCm != null ||
          entry.thighCm != null ||
          entry.armCm != null;
      if (measured &&
          (updated == null || !entry.recordedAt.isBefore(updated))) {
        updated = entry.recordedAt;
      }
    }

    Widget card(CircumferencePart part, String label, IconData icon) {
      final stat = stats[part];
      final delta = stat?.deltaCm;
      return _VitalCard(
        label: label,
        value:
            stat == null ? '—' : context.localizeDigits(_cmText(stat.valueCm)),
        delta: delta == null ? null : l10n.progressCmChange(_signed(delta)),
        icon: icon,
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
          child: Text(l10n.progressVitalCircumference,
              style: AppTextStyles.sectionHeading.copyWith(fontSize: 15)),
        ),
        if (updated != null)
          Text(
              l10n.progressUpdatedOn(context.localizeDigits(
                  MaterialLocalizations.of(context).formatMediumDate(updated))),
              style: AppTextStyles.caption),
      ]),
      const SizedBox(height: 12),
      if (stats.isEmpty)
        Text(l10n.progressNoCircumference,
            textAlign: TextAlign.start, style: AppTextStyles.caption)
      else ...[
        Row(children: [
          Expanded(
              child: card(CircumferencePart.waist, l10n.progressWaist,
                  Icons.accessibility_new_rounded)),
          const SizedBox(width: 12),
          Expanded(
              child: card(CircumferencePart.hip, l10n.progressHip,
                  Icons.straighten_rounded)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: card(CircumferencePart.thigh, l10n.progressThigh,
                  Icons.directions_run_rounded)),
          const SizedBox(width: 12),
          Expanded(
              child: card(CircumferencePart.arm, l10n.progressArm,
                  Icons.open_in_full_rounded)),
        ]),
      ],
    ]);
  }

  /// A centimetre value without a trailing ".0".
  static String _cmText(double cm) =>
      cm == cm.roundToDouble() ? cm.toStringAsFixed(0) : cm.toStringAsFixed(1);

  /// A change with its sign, digits localized: "−2", "+0.5", "0".
  String _signed(double delta) {
    final sign = delta > 0 ? '+' : (delta < 0 ? '−' : '');
    return '$sign${context.localizeDigits(_cmText(delta.abs()))}';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(children: [
            const Icon(Icons.square_foot_rounded, size: 18, color: _teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(context.l10n.progressGuideLink,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _teal)),
            ),
            Icon(
                directionalIcon(context,
                    rtl: Icons.arrow_back_rounded,
                    ltr: Icons.arrow_forward_rounded),
                size: 18,
                color: _teal),
          ]),
        ),
      ),
    );
  }

  // ── 6) آخر تقييم من الأخصائي (API guide 9.2) ──────────────────────────
  /// The newest note, or null while the notes load, when they failed with
  /// nothing kept, or when there is none.
  NutritionistReview? _latestReview() {
    final reviews = context.watch<ReviewsCubit>().state.dataOrNull;
    return reviews == null || reviews.isEmpty ? null : reviews.first;
  }

  /// The adherence over the chart's window, then the nutritionist's latest
  /// note: its rating, date and text, and «فهمت» until it is acknowledged.
  Widget _evaluationCard() {
    final l10n = context.l10n;
    final percent =
        context.watch<ProgressCubit>().state.dataOrNull?.adherence.percent;
    final nutritionist = context.watch<NutritionistCubit>().state.dataOrNull;
    final reviewsState = context.watch<ReviewsCubit>().state;
    final review = _latestReview();
    final rating =
        review == null ? null : reviewRatingLabel(l10n, review.rating);
    final date = review?.createdAt;

    final Widget body;
    if (review != null) {
      body = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (nutritionist != null) ...[
          const SizedBox(height: 4),
          Text(l10n.progressReviewedBy(nutritionist.name),
              style: AppTextStyles.caption),
        ],
        const SizedBox(height: 12),
        if (rating != null || date != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                color: _lavender, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              if (rating != null) ...[
                const Icon(Icons.flag_rounded, size: 18, color: _teal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(rating,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ] else
                const Spacer(),
              if (date != null)
                Text(context.localizeDigits(numericDate(date)),
                    style: AppTextStyles.caption),
            ]),
          ),
        if (review.note.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            review.note,
            textAlign: TextAlign.start,
            style: AppTextStyles.caption
                .copyWith(height: 2.0, color: AppColors.textPrimary),
          ),
        ],
        const SizedBox(height: 12),
        if (review.isAcknowledged)
          Row(children: [
            const Icon(Icons.check_circle_rounded,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(l10n.reviewSeen,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ])
        else
          GradientCtaButton(
            label: l10n.reviewAcknowledge,
            onPressed: () => _reportWrite(
                context.read<ReviewsCubit>().acknowledge(review.id)),
          ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () => Navigator.of(context)
                .push(AppPageRoute(builder: (_) => const ReviewsScreen())),
            child: Text(l10n.progressAllNotes),
          ),
        ),
      ]);
    } else if (reviewsState
        case AsyncError<List<NutritionistReview>>(:final failure)) {
      body = Padding(
        padding: const EdgeInsets.only(top: 12),
        child: LoadErrorView(
          message: loadFailureMessage(context, failure),
          onRetry: () => context.read<ReviewsCubit>().load(),
        ),
      );
    } else if (reviewsState is AsyncSuccess<List<NutritionistReview>>) {
      body = Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(l10n.reviewsEmpty,
            textAlign: TextAlign.start, style: AppTextStyles.caption),
      );
    } else {
      body = const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text(l10n.progressLatestReview,
                style: AppTextStyles.sectionHeading.copyWith(fontSize: 15)),
          ),
          if (percent != null)
            _Pill(
              color: _mint,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 15, color: Color(0xFF0B4F44)),
                const SizedBox(width: 4),
                Text(
                    l10n.progressAdherencePercent(
                        context.localizeDigits('$percent')),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B4F44))),
              ]),
            ),
        ]),
        body,
      ]),
    );
  }

  /// Shows a failed «فهمت» or task tick. The cubit reloads after a success.
  Future<void> _reportWrite(Future<Result<void>> write) async {
    final failure = (await write).failureOrNull;
    if (failure == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loadFailureMessage(context, failure))),
    );
  }

  // ── 7) أهم النقاط في آخر ملاحظة ───────────────────────────────────────
  List<Widget> _keyPointsCard() {
    final points = _latestReview()?.keyPoints ?? const <String>[];
    if (points.isEmpty) return const [];
    return [
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: _lavender, borderRadius: BorderRadius.circular(18)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const Icon(Icons.format_quote_rounded, size: 22, color: _teal),
            const SizedBox(width: 6),
            Expanded(
              child: Text(context.l10n.reviewKeyPointsTitle,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _teal)),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final point in points)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text('•  $point',
                        textAlign: TextAlign.start,
                        style: AppTextStyles.caption.copyWith(
                            height: 1.8,
                            fontSize: 12.5,
                            color: AppColors.textPrimary)),
                  ),
              ],
            ),
          ),
        ]),
      ),
    ];
  }

  // ── 8) مهام آخر ملاحظة ────────────────────────────────────────────────
  /// The tasks in the latest note. A tap ticks or unticks it on the server
  /// (`POST` / `DELETE /me/tasks/{id}/done`, 9.2).
  List<Widget> _tasksCard() {
    final tasks = _latestReview()?.tasks ?? const <ReviewTask>[];
    if (tasks.isEmpty) return const [];
    final l10n = context.l10n;
    return [
      const SizedBox(height: 16),
      _Card(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: Text(l10n.progressNextWeekGuidance,
                  style: AppTextStyles.sectionHeading.copyWith(fontSize: 15)),
            ),
            Text(
                l10n.progressTaskCount(
                    tasks.length, context.localizeDigits(tasks.length)),
                style: AppTextStyles.caption),
          ]),
          const SizedBox(height: 12),
          for (final task in tasks)
            _TaskRow(
              icon: Icons.task_alt_rounded,
              title: task.title,
              done: task.isDone,
              onTap: () => _reportWrite(context
                  .read<ReviewsCubit>()
                  .setTaskDone(task.id, done: !task.isDone)),
            ),
        ]),
      ),
    ];
  }

  // ── 9) زر واتساب ──────────────────────────────────────────────────────
  /// Opens a chat with the nutritionist (`https://wa.me/<digits>`, 9.1). Left
  /// out when the profile has no number.
  List<Widget> _whatsappButton() {
    final uri =
        context.watch<NutritionistCubit>().state.dataOrNull?.whatsappUri;
    if (uri == null) return const [];
    return [
      const SizedBox(height: 16),
      SizedBox(
        height: 52,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
          onPressed: () => _openWhatsApp(uri),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.chat_outlined, size: 19),
            const SizedBox(width: 8),
            Flexible(child: Text(context.l10n.progressDiscussWhatsApp)),
          ]),
        ),
      ),
    ];
  }

  Future<void> _openWhatsApp(Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.linkCouldNotOpen)),
      );
    }
  }

  // ── 10) الموعد القادم (API guide 12.4) ────────────────────────────────
  /// The soonest booked appointment, in the device's time. Left out when
  /// there is none or the list is not known.
  List<Widget> _nextAppointment() {
    final upcoming = context.watch<AppointmentsCubit>().state.dataOrNull;
    if (upcoming == null || upcoming.isEmpty) return const [];
    final startsAt = upcoming.first.startsAt;
    final material = MaterialLocalizations.of(context);
    final when = context.localizeDigits(
        '${material.formatFullDate(startsAt)} · ${material.formatTimeOfDay(TimeOfDay.fromDateTime(startsAt))}');
    return [
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.calendar_month_outlined,
            size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(context.l10n.progressNextAppointment(when),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ),
      ]),
    ];
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
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
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
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: child,
    );
  }
}

/// The nutritionist's avatar, from the real profile. No "online" dot: the app
/// does not know when the nutritionist is available.
class _SpecialistAvatar extends StatelessWidget {
  const _SpecialistAvatar();

  @override
  Widget build(BuildContext context) {
    return PersonAvatar(
      name: nutritionistName(context),
      size: 48,
    );
  }
}

/// بطاقة قياس حيوي: الاسم يميناً وأيقونة يساراً، والقيمة يميناً ومؤشر التغيّر يساراً.
class _VitalCard extends StatelessWidget {
  final String label;
  final String value;

  /// The change since the reading before, or null when there is none to
  /// compare with.
  final String? delta;
  final IconData icon;
  const _VitalCard(
      {required this.label,
      required this.value,
      required this.delta,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          Text(label,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: const Color(0xFFF2F4FC),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: const Color(0xFF0E7C86)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: AppTextStyles.metricMedium
                      .copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              Text(context.l10n.commonCmUnit, style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          if (delta != null)
            _Pill(
              color: const Color(0xFFF2F4FC),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(delta!,
                  style: AppTextStyles.caption.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
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
  final bool done;
  final VoidCallback onTap;
  const _TaskRow({
    required this.icon,
    required this.title,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: done,
      label: title,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFF6F7FC),
              borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: done
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                    width: 1.5),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 17, color: const Color(0xFF0E7C86)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(title,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.body.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      decoration: done ? TextDecoration.lineThrough : null)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// One reading on the chart: how many days before today it was taken, its
/// weight, and whether it came from the clinic.
class _ChartPoint {
  const _ChartPoint({
    required this.daysAgo,
    required this.weightKg,
    required this.clinic,
  });

  final double daysAgo;
  final double weightKg;
  final bool clinic;
}

/// Weight trend chart: a smooth line with a gradient under it, a dot for each
/// reading (mint for the clinic's, teal for the patient's), dashed grid lines,
/// and a tooltip over the newest reading.
class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter({
    required this.points,
    required this.days,
    required this.top,
    required this.bottom,
    required this.yLabels,
    required this.tooltip,
    required this.textDirection,
  });

  /// Newest first: the first point is the one nearest today.
  final List<_ChartPoint> points;

  /// The window length. The x axis runs from today (left) to [days] ago.
  final int days;

  /// The weights at the top and bottom grid lines.
  final double top;
  final double bottom;

  /// Labels for the top, middle and bottom grid lines.
  final List<String> yLabels;

  /// Shown over the newest reading, already localized.
  final String tooltip;
  final TextDirection textDirection;

  static const Color _teal = Color(0xFF0E6F78);
  static const Color _mint = Color(0xFF6FF0CF);
  static const Color _navy = Color(0xFF1F2A44);

  @override
  void paint(Canvas canvas, Size size) {
    const l = 34.0, r = 34.0, t = 14.0, b = 12.0;
    final plot = Rect.fromLTRB(l, t, size.width - r, size.height - b);

    final grid = Paint()
      ..color = const Color(0xFFD5DBEE)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = plot.top + plot.height * i / 2;
      _dashed(canvas, Offset(plot.left, y), Offset(plot.right, y), grid);
      final tp = TextPainter(
        text: TextSpan(
            text: yLabels[i],
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF7A8197),
                fontFamily: AppTextStyles.fontFamily)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    if (points.isEmpty) return;
    final span = top - bottom;
    final pts = [
      for (final p in points)
        Offset(
          plot.left + (p.daysAgo / days).clamp(0.0, 1.0) * plot.width,
          plot.top + (top - p.weightKg) / span * plot.height,
        ),
    ];

    if (pts.length >= 2) {
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
    }

    for (var i = 0; i < pts.length; i++) {
      final radius = i == 0 ? 7.0 : 5.5;
      canvas.drawCircle(
          pts[i], radius, Paint()..color = points[i].clinic ? _mint : _teal);
      canvas.drawCircle(
        pts[i],
        radius,
        Paint()
          ..color = _teal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // The tooltip sits over the newest reading and stays inside the plot.
    final tp = TextPainter(
      text: TextSpan(
          text: tooltip,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              fontFamily: AppTextStyles.fontFamily)),
      textDirection: textDirection,
    )..layout();
    final boxWidth = tp.width + 20;
    final newest = pts.first;
    final cx = (newest.dx - 2)
        .clamp(plot.left + boxWidth / 2, plot.right - boxWidth / 2)
        .toDouble();
    final c = Offset(cx, newest.dy - 30);
    final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: boxWidth, height: 24),
        const Radius.circular(8));
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
      final c1 =
          Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final c2 =
          Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 5.0, gap = 4.0;
    var x = a.dx;
    while (x < b.dx) {
      canvas.drawLine(
          Offset(x, a.dy), Offset((x + dash).clamp(a.dx, b.dx), a.dy), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) =>
      !identical(oldDelegate.points, points) ||
      oldDelegate.days != days ||
      oldDelegate.top != top ||
      oldDelegate.bottom != bottom ||
      oldDelegate.yLabels != yLabels ||
      oldDelegate.tooltip != tooltip ||
      oldDelegate.textDirection != textDirection;
}
