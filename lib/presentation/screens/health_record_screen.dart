import '../widgets/spec_ui.dart';
import 'achievements_screen.dart';
import 'medical_reports_screens.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/clinical_trust_footer.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/state/async_state.dart';
import '../../core/utils/formatters.dart';
import '../../core/navigation/app_page_route.dart';
import '../../domain/entities/nutritionist_entities.dart';
import '../../domain/entities/patient_health_profile_entities.dart';
import '../bloc/health_profile/health_profile_cubit.dart';
import '../bloc/nutritionist/nutritionist_cubit.dart';
import '../health_profile_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/load_error_view.dart';
import 'change_requests_screen.dart';

import '../widgets/person_avatar.dart';
import '../../l10n/l10n.dart';
import '../bloc/auth/auth_cubit.dart';
import '../widgets/state_views.dart';
import '../widgets/directional_icon.dart';

const _lav = Color(0xFFF6F8FE); // خلفية الصناديق الفاتحة
const _lavGrey = Color(0xFFEEF1F8);
const _dangerBg = Color(0xFFFDE8E8);
const _mintPill = Color(0xFFD3F3E8);

double _seg(double v, double b, double e, [Curve c = Curves.easeOutCubic]) {
  final value = v.isFinite ? math.max(0.0, math.min(1.0, v)) : 0.0;
  final begin = b.isFinite ? math.max(0.0, math.min(1.0, b)) : 0.0;
  final end = e.isFinite ? math.max(0.0, math.min(1.0, e)) : 1.0;

  if (end <= begin) {
    return value >= begin ? 1.0 : 0.0;
  }

  return Interval(begin, end, curve: c).transform(value);
}

List<BoxShadow> get _softShadow => [
      BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 5)),
    ];

String _kgText(double kg) =>
    kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);

/// The latest review date among the medications, if any.
DateTime? _latestReview(List<MedicationItem> medications) {
  DateTime? latest;
  for (final medication in medications) {
    final at = medication.reviewedAt;
    if (at != null && (latest == null || at.isAfter(latest))) latest = at;
  }
  return latest;
}

_ChipSpec _allergyChip(AppLocalizations l10n, AllergyItem allergy) {
  final confirmed = allergy.allergyClass == 'confirmed_allergy';
  final classText = allergyClassLabel(l10n, allergy.allergyClass);
  return _ChipSpec(
    classText == null ? allergy.label : '${allergy.label} · $classText',
    confirmed ? _dangerBg : _lavGrey,
    confirmed ? AppColors.danger : AppColors.textSecondary,
    confirmed ? AppColors.danger : AppColors.textPrimary,
  );
}

/// "السجل الطبي" — the patient's full clinical record at a glance.
class HealthRecordScreen extends StatelessWidget {
  const HealthRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    return MultiBlocProvider(
      providers: [
        BlocProvider<HealthProfileCubit>(
          create: (_) => HealthProfileCubit(deps.patientHealthProfile)..load(),
        ),
        BlocProvider<NutritionistCubit>(
          create: (_) => NutritionistCubit(deps.nutritionist)..load(),
        ),
      ],
      child: const _HealthRecordView(),
    );
  }
}

class _HealthRecordView extends StatefulWidget {
  const _HealthRecordView();

  @override
  State<_HealthRecordView> createState() => _HealthRecordViewState();
}

class _HealthRecordViewState extends State<_HealthRecordView>
    with TickerProviderStateMixin {
  // Created in initState, not lazily: a screen closed before the profile
  // loads (offline, an error) never touched them, and creating one inside
  // dispose() looks up a deactivated ancestor.
  late final AnimationController _enter;
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3400))
      ..forward();
    _loop = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeaderBar(title: context.l10n.healthRecordTitle),
      body: BlocBuilder<HealthProfileCubit, AsyncState<PatientHealthProfile>>(
        builder: (context, state) {
          final profile = state.dataOrNull;
          if (profile == null) return _ProfileStatus(state: state);
          return _content(profile);
        },
      ),
    );
  }

  /// The change-request screen shares this record's profile, so a sent request
  /// shows here as soon as the screen closes.
  void _openRequests() {
    final cubit = context.read<HealthProfileCubit>();
    Navigator.of(context).push(AppPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const ChangeRequestsScreen(),
      ),
    ));
  }

  Widget _content(PatientHealthProfile profile) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
      children: [
        _Reveal(
            anim: _enter,
            begin: 0.00,
            end: 0.20,
            child:
                BlocBuilder<NutritionistCubit, AsyncState<NutritionistProfile>>(
                    builder: (context, nutritionist) => _IdentityLevelCard(
                        enter: _enter,
                        loop: _loop,
                        nutritionist: nutritionist.dataOrNull))),
        const SizedBox(height: 18),
        _Reveal(
            anim: _enter,
            begin: 0.12,
            end: 0.30,
            child: _GoalCard(goal: profile.goal, loop: _loop)),
        const SizedBox(height: 18),
        _Reveal(
            anim: _enter,
            begin: 0.22,
            end: 0.40,
            child: _MedicationsCard(
                medications: profile.medications, enter: _enter, loop: _loop)),
        const SizedBox(height: 24),
        _Reveal(
            anim: _enter,
            begin: 0.34,
            end: 0.48,
            child: _DiagnosesHeader(loop: _loop)),
        const SizedBox(height: 14),
        _Reveal(
          anim: _enter,
          begin: 0.40,
          end: 0.54,
          child: _RecordBox(
            enter: _enter,
            loop: _loop,
            chipsBegin: 0.48,
            pulseIcon: true,
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.danger,
            iconBg: _dangerBg,
            title: context.l10n.healthRecordAllergies,
            emptyText: context.l10n.healthNoAllergies,
            chips: [
              for (final allergy in profile.allergies)
                _allergyChip(context.l10n, allergy),
            ],
            footer: context.l10n.healthAllergyFooter,
          ),
        ),
        const SizedBox(height: 14),
        _Reveal(
            anim: _enter,
            begin: 0.54,
            end: 0.66,
            child: _EditRequestRow(loop: _loop, onTap: _openRequests)),
        // The medical reports (spec, phase 4). Renders nothing while the
        // feature is off on the server (every reports endpoint answers 404).
        const SizedBox(height: 22),
        const MedicalReportsSection(),
        const SizedBox(height: 18),
        // Milestones come from the patient's own logs, on their own screen.
        SpecCard(
          onTap: () => Navigator.of(context)
              .push(AppPageRoute(builder: (_) => const AchievementsScreen())),
          child: SpecCardHeader(
            icon: Icons.emoji_events_outlined,
            title: context.l10n.profileAchievements,
            subtitle: context.l10n.profileAchievementsSubtitle,
            trailing: const Icon(Icons.chevron_left_rounded,
                color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 4),
        _Reveal(
            anim: _enter,
            begin: 0.92,
            end: 1.0,
            child: const ClinicalTrustFooter()),
      ],
    );
  }
}

// ═════════════════════════ أدوات الأنيميشن المشتركة ═════════════════════════

/// دخول متتابع: تلاشي + انزلاق من الأسفل
/// What the health record shows until a profile is available: a spinner while
/// loading, or the error with a retry when there is nothing kept to show.
class _ProfileStatus extends StatelessWidget {
  const _ProfileStatus({required this.state});

  final AsyncState<PatientHealthProfile> state;

  @override
  Widget build(BuildContext context) {
    final current = state;
    if (current is AsyncError<PatientHealthProfile>) {
      return LoadErrorView(
        failure: current.failure,
        onRetry: () => context.read<HealthProfileCubit>().load(),
      );
    }
    return const ListSkeleton();
  }
}

class _Reveal extends StatelessWidget {
  final Animation<double> anim;
  final double begin, end, dy;
  final Widget child;
  const _Reveal(
      {required this.anim,
      required this.begin,
      required this.end,
      required this.child,
      this.dy = 28});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      child: child,
      builder: (_, c) {
        final v = _seg(anim.value, begin, end);
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, (1 - v) * dy), child: c),
        );
      },
    );
  }
}

/// نقطة نابضة بموجة
class _PulseDot extends StatelessWidget {
  final Animation<double> loop;
  static const Color color = AppColors.primary;
  const _PulseDot({required this.loop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: AnimatedBuilder(
        animation: loop,
        builder: (_, __) {
          final t = (loop.value * 1.5) % 1.0;
          return Stack(alignment: Alignment.center, children: [
            Transform.scale(
              scale: 1 + t * 1.6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: (1 - t) * 0.4)),
              ),
            ),
            Container(
                width: 8,
                height: 8,
                decoration:
                    const BoxDecoration(color: color, shape: BoxShape.circle)),
          ]);
        },
      ),
    );
  }
}

// ═════════════════════════ كرت الهوية والمستوى ═════════════════════════

class _IdentityLevelCard extends StatelessWidget {
  final Animation<double> enter, loop;

  /// The patient's own nutritionist. The badge is hidden without one.
  final NutritionistProfile? nutritionist;
  const _IdentityLevelCard(
      {required this.enter, required this.loop, this.nutritionist});

  @override
  Widget build(BuildContext context) {
    Widget doctorBadge({double? width}) {
      final profile = nutritionist;
      if (profile == null) return const SizedBox.shrink();
      final subtitle = profile.specialty ?? profile.clinicName;
      final label =
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          profile.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption
              .copyWith(fontWeight: FontWeight.w700, fontSize: 11),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
      ]);
      return Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
            mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
            children: [
              const Icon(Icons.verified_user_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              width == null ? label : Expanded(child: label),
            ]),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: _softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(children: [
          // التوهّج الأخضر (يتنفس)
          PositionedDirectional(
            end: -50,
            top: -50,
            child: AnimatedBuilder(
              animation: loop,
              builder: (_, __) => Transform.scale(
                scale: 1 + 0.08 * math.sin(loop.value * 2 * math.pi),
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      const Color(0xFFBDEFDC).withValues(alpha: 0.8),
                      const Color(0xFFBDEFDC).withValues(alpha: 0),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final compact = constraints.maxWidth < 360;
                    final patientInfo = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                  context.watch<AuthCubit>().state.user?.name ??
                                      '',
                                  style: AppTextStyles.cardTitle),
                            ],
                          ),
                          if (context.watch<AuthCubit>().state.user?.patientCode
                              case final code?) ...[
                            const SizedBox(height: 6),
                            Text(context.l10n.healthRecordFileCode(code),
                                style: AppTextStyles.caption),
                          ],
                        ]);

                    final profileRow = Row(children: [
                      _Avatar(loop: loop),
                      const SizedBox(width: 12),
                      Expanded(child: patientInfo),
                    ]);

                    if (compact) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            profileRow,
                            const SizedBox(height: 12),
                            doctorBadge(width: double.infinity),
                          ]);
                    }

                    return Row(children: [
                      Expanded(child: profileRow),
                      const SizedBox(width: 10),
                      Flexible(flex: 0, child: doctorBadge()),
                    ]);
                  }),
                ]),
          ),
        ]),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Animation<double> loop;
  const _Avatar({required this.loop});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(clipBehavior: Clip.none, children: [
        // حلقة نابضة
        Positioned.fill(
          child: AnimatedBuilder(
            animation: loop,
            builder: (_, __) {
              final t = (loop.value * 1.5) % 1.0;
              return Transform.scale(
                scale: 1 + t * 0.18,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color:
                            AppColors.primary.withValues(alpha: (1 - t) * 0.5),
                        width: 2),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(2),
            // The patient's own photo when the profile has one, her initial
            // otherwise: no bundled placeholder image.
            child: PersonAvatar(
              imageUrl: user?.avatarUrl,
              name: user?.name,
              size: 70,
            ),
          ),
        ),
        PositionedDirectional(
            start: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 11),
            )),
      ]),
    );
  }
}

// ═════════════════════════ الهدف الصحي ═════════════════════════

class _GoalCard extends StatelessWidget {
  final HealthGoal? goal;
  final Animation<double> loop;
  const _GoalCard({required this.goal, required this.loop});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final goal = this.goal;
    final weight = goal?.targetWeightKg;
    final date = goal?.targetDate;
    final details = goal?.details;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _lav, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.trending_down_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(l10n.healthRecordCurrentGoal,
                style: AppTextStyles.sectionHeading
                    .copyWith(color: AppColors.primaryInk)),
          ),
        ]),
        const SizedBox(height: 12),
        Text(
            goal == null
                ? l10n.healthGoalNotSet
                : goalTypeLabel(l10n, goal.goalType),
            style: AppTextStyles.body.copyWith(height: 1.9, fontSize: 13)),
        if (details != null) ...[
          const SizedBox(height: 4),
          Text(details, style: AppTextStyles.caption),
        ],
        if (weight != null || date != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
            child: Row(children: [
              AnimatedBuilder(
                animation: loop,
                builder: (_, child) => Transform.rotate(
                  angle: 0.12 * math.sin(loop.value * 4 * math.pi),
                  alignment: AlignmentDirectional.bottomStart,
                  child: child,
                ),
                child: const Icon(Icons.outlined_flag_rounded,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    weight == null
                        ? ''
                        : l10n.healthGoalTarget(l10n.commonKgValue(
                            context.localizeDigits(_kgText(weight)))),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
              ),
              if (date != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: _mintPill,
                      borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(
                      l10n.healthGoalTargetDate(
                          context.localizeDigits(numericDate(date))),
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
          ),
        ],
      ]),
    );
  }
}

// ═════════════════════════ الأدوية ═════════════════════════

class _MedicationsCard extends StatelessWidget {
  final List<MedicationItem> medications;
  final Animation<double> enter, loop;
  const _MedicationsCard({
    required this.medications,
    required this.enter,
    required this.loop,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reviewed = _latestReview(medications);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: _softShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.medical_services_outlined,
              color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Expanded(
              child: Text(l10n.healthRecordMedications,
                  style: AppTextStyles.sectionHeading)),
          _PulseDot(loop: loop),
          const SizedBox(width: 2),
          Text(l10n.healthRecordActive, style: AppTextStyles.caption),
        ]),
        const SizedBox(height: 14),
        if (medications.isEmpty)
          Text(l10n.healthNoMedications, style: AppTextStyles.caption)
        else
          for (var i = 0; i < medications.length; i++)
            _Reveal(
              anim: enter,
              begin: 0.28 + i * 0.05,
              end: 0.42 + i * 0.05,
              dy: 16,
              child: _MedicationRow(
                  medication: medications[i], loop: loop, phase: i * 0.4),
            ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: _lav,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
          child: Text(l10n.healthMedDisclaimer,
              style: AppTextStyles.caption.copyWith(height: 1.7)),
        ),
        if (reviewed != null) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.schedule_rounded,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.healthMedReviewedOn(
                    context.localizeDigits(numericDate(reviewed))),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

class _MedicationRow extends StatelessWidget {
  final MedicationItem medication;
  final Animation<double> loop;
  final double phase;
  const _MedicationRow(
      {required this.medication, required this.loop, required this.phase});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final frequency = medication.frequency;
    final reviewedAt = medication.reviewedAt;
    final note = medication.reviewNote;
    final details = medicationDetails(l10n, medication,
        formatDate: (date) => context.localizeDigits(numericDate(date)));
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: _lav,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          AnimatedBuilder(
            animation: loop,
            builder: (_, child) => Transform.translate(
              offset: Offset(
                  0, -2.5 * math.sin((loop.value + phase) * 2 * math.pi)),
              child: child,
            ),
            child: const Text('💊', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(medication.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle),
              const SizedBox(height: 2),
              Text(details,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption),
            ]),
          ),
          if (frequency != null) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 112),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Text(
                  frequency,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryInk, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ]),
        if (reviewedAt != null) ...[
          const SizedBox(height: 8),
          Text(l10n.healthMedReviewedBy,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryInk, fontWeight: FontWeight.w700)),
          if (note != null) Text(note, style: AppTextStyles.caption),
        ],
      ]),
    );
  }
}

// ═════════════════════════ السجل الطبي المعتمد ═════════════════════════

class _DiagnosesHeader extends StatelessWidget {
  final Animation<double> loop;
  const _DiagnosesHeader({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AnimatedBuilder(
        animation: loop,
        builder: (_, child) => Transform.scale(
            scale: 1 + 0.05 * math.sin(loop.value * 2 * math.pi), child: child),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(11)),
          child:
              const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.l10n.healthRecordCertified,
              style: AppTextStyles.sectionHeading),
          const SizedBox(height: 2),
          Text(context.l10n.healthRecordDiagnosesNote,
              style: AppTextStyles.caption),
        ]),
      ),
    ]);
  }
}

class _ChipSpec {
  final String text;
  final Color bg, dot, fg;
  const _ChipSpec(this.text, this.bg, this.dot, this.fg);
}

class _RecordBox extends StatelessWidget {
  final Animation<double> enter, loop;
  final double chipsBegin;
  final bool pulseIcon;
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, footer;
  final List<_ChipSpec> chips;
  final String? emptyText;

  const _RecordBox({
    required this.enter,
    required this.loop,
    required this.chipsBegin,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.chips,
    required this.footer,
    this.pulseIcon = false,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: _softShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          AnimatedBuilder(
            animation: loop,
            builder: (_, child) {
              final s = pulseIcon
                  ? 1 + 0.12 * (math.sin(loop.value * 4 * math.pi) + 1) / 2
                  : 1.0;
              return Transform.scale(scale: s, child: child);
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 13))),
        ]),
        const SizedBox(height: 14),
        if (chips.isEmpty && emptyText != null)
          Text(emptyText!, style: AppTextStyles.caption),
        for (var i = 0; i < chips.length; i++)
          _Reveal(
            anim: enter,
            begin: chipsBegin + i * 0.04,
            end: chipsBegin + 0.12 + i * 0.04,
            dy: 12,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: chips[i].bg, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: chips[i].dot, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(chips[i].text,
                      style: AppTextStyles.caption.copyWith(
                          color: chips[i].fg, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
          ),
        const SizedBox(height: 4),
        Text(footer, style: AppTextStyles.caption),
      ]),
    );
  }
}

class _EditRequestRow extends StatelessWidget {
  final Animation<double> loop;
  final VoidCallback? onTap;
  const _EditRequestRow({required this.loop, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _lav,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.edit_note_rounded,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(context.l10n.healthRecordRequestChange,
                  style: AppTextStyles.pillLabel),
            ),
            const SizedBox(width: 4),
            AnimatedBuilder(
              animation: loop,
              builder: (_, child) => Transform.translate(
                offset: Offset(
                    -3 *
                        rtlDesignSign(context) *
                        (math.sin(loop.value * 2 * math.pi) + 1) /
                        2,
                    0),
                child: child,
              ),
              child: const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.primary),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════ الأوسمة والإنجازات ═════════════════════════
