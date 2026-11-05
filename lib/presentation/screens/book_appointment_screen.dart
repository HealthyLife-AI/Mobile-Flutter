import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/appointment_entities.dart';
import '../../domain/entities/nutritionist_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/appointments/appointment_slots_cubit.dart';
import '../bloc/nutritionist/nutritionist_cubit.dart';
import '../date_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/external_link.dart';
import '../widgets/load_error_view.dart';
import '../widgets/spec_ui.dart';

/// Books an appointment, or moves one ([reschedule]) (API guide 12.1 to 12.3).
///
/// Booking asks for the kind, a free time, the channel, topics and a note.
/// Moving asks only for a fresh time of the same kind. The screen pops with
/// the saved appointment, or with nothing when the patient leaves.
class BookAppointmentScreen extends StatelessWidget {
  const BookAppointmentScreen({super.key, this.reschedule});

  /// The appointment to move. Null books a new one.
  final Appointment? reschedule;

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppointmentSlotsCubit(deps.appointments)
            ..load(reschedule?.type ?? bookableAppointmentTypes.first),
        ),
        BlocProvider(
          create: (_) => NutritionistCubit(deps.nutritionist)..load(),
        ),
      ],
      child: _BookingView(reschedule: reschedule),
    );
  }
}

class _BookingView extends StatefulWidget {
  const _BookingView({this.reschedule});

  final Appointment? reschedule;

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  late AppointmentType _type =
      widget.reschedule?.type ?? bookableAppointmentTypes.first;
  int _day = 0;
  AppointmentSlot? _slot;
  AppointmentChannel _channel = AppointmentChannel.whatsapp;
  final Set<String> _topics = {};
  final TextEditingController _note = TextEditingController();
  bool _sending = false;

  bool get _moving => widget.reschedule != null;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _pickType(AppointmentType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _day = 0;
      _slot = null;
    });
    context.read<AppointmentSlotsCubit>().load(type);
  }

  /// Reads the free times again, after the chosen one was taken.
  void _reloadTimes() {
    setState(() => _slot = null);
    context.read<AppointmentSlotsCubit>().load(_type);
  }

  Future<void> _submit() async {
    final slot = _slot;
    if (slot == null || _sending) return;
    setState(() => _sending = true);
    final cubit = context.read<AppointmentSlotsCubit>();
    final moving = widget.reschedule;
    final result = moving == null
        ? await cubit.book(AppointmentRequest(
            type: _type,
            slot: slot,
            channel: _channel,
            topics: [
              for (final topic in appointmentTopics)
                if (_topics.contains(topic)) topic,
            ],
            note: _note.text,
          ))
        : await cubit.reschedule(moving, slot);
    if (!mounted) return;
    setState(() => _sending = false);
    switch (result) {
      case Success(:final value):
        Navigator.of(context).pop(value);
      case Failed(:final failure):
        final code = failure is ApiFailure ? failure.code : null;
        if (code == 'video_unavailable') {
          setState(() => _channel = AppointmentChannel.whatsapp);
        }
        if (code == 'slot_unavailable' ||
            code == 'slot_taken' ||
            code == 'video_unavailable') {
          _reloadTimes();
        }
        await showAppointmentFailure(context, failure);
        // Nothing left to book or move here: the list reads again.
        if (mounted &&
            (code == 'appointment_exists' || code == 'appointment_closed')) {
          Navigator.of(context).pop();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AppointmentSlotsCubit>().state;
    final slots = state.dataOrNull;
    final videoAvailable = slots?.videoAvailable ?? false;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(
          title: _moving ? l10n.callsChangeTitle : l10n.callsBookTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (widget.reschedule case final current?) ...[
              SpecSectionTitle(l10n.callsCurrentAppointment,
                  icon: Icons.event_outlined),
              const SizedBox(height: 8),
              SpecCard(
                child: Text(
                  [
                    appointmentTypeTitle(l10n, current.type),
                    fullDayLabel(context, current.startsAt),
                    context.localizeDigits(MaterialLocalizations.of(context)
                        .formatTimeOfDay(
                            TimeOfDay.fromDateTime(current.startsAt))),
                  ].join(' • '),
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(height: 18),
            ] else ...[
              SpecSectionTitle(l10n.callsTypeSection,
                  icon: Icons.medical_services_outlined),
              const SizedBox(height: 8),
              for (final type in bookableAppointmentTypes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChoiceTile(
                    label: appointmentTypeTitle(l10n, type),
                    hint: l10n.callsMinutes(
                        context.localizeDigits(_minutesOf(type))),
                    selected: type == _type,
                    onTap: () => _pickType(type),
                  ),
                ),
              const SizedBox(height: 10),
            ],
            SpecSectionTitle(l10n.callsTimeSection,
                icon: Icons.schedule_rounded),
            const SizedBox(height: 4),
            Text(l10n.callsTimesLocal, style: AppTextStyles.caption),
            const SizedBox(height: 10),
            _times(context, state),
            if (!_moving) ...[
              const SizedBox(height: 18),
              SpecSectionTitle(l10n.callsChannelSection,
                  icon: Icons.forum_outlined),
              const SizedBox(height: 8),
              for (final channel in [
                AppointmentChannel.whatsapp,
                AppointmentChannel.phone,
                if (videoAvailable) AppointmentChannel.video,
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChoiceTile(
                    label: appointmentChannelLabel(l10n, channel),
                    icon: appointmentChannelIcon(channel),
                    selected: channel == _channel,
                    onTap: () => setState(() => _channel = channel),
                  ),
                ),
              const SizedBox(height: 10),
              SpecSectionTitle(l10n.callsTopicsSection,
                  icon: Icons.checklist_rounded),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final topic in appointmentTopics)
                    FilterChip(
                      label: Text(_topicLabel(l10n, topic)),
                      selected: _topics.contains(topic),
                      selectedColor: AppColors.primaryTint,
                      checkmarkColor: AppColors.primary,
                      onSelected: (on) => setState(() {
                        if (!on) {
                          _topics.remove(topic);
                        } else if (_topics.length < maxAppointmentTopics) {
                          _topics.add(topic);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              SpecSectionTitle(l10n.callsNoteSection,
                  icon: Icons.edit_note_rounded),
              const SizedBox(height: 8),
              TextField(
                controller: _note,
                maxLength: maxAppointmentNoteLength,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SpecPrimaryButton(
          label: _moving ? l10n.callsConfirmChange : l10n.callsConfirmBooking,
          loading: _sending,
          onPressed: _slot == null ? null : _submit,
        ),
      ),
    );
  }

  /// The day chips and the time chips of the chosen day, or why there are
  /// none.
  Widget _times(BuildContext context, AsyncState<AppointmentSlots> state) {
    final l10n = context.l10n;
    final slots = state.dataOrNull;
    if (slots == null) {
      if (state case AsyncError<AppointmentSlots>(:final failure)) {
        return LoadErrorView(
          message: loadFailureMessage(context, failure),
          onRetry: _reloadTimes,
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (slots.isEmpty) {
      final whatsapp =
          context.watch<NutritionistCubit>().state.dataOrNull?.whatsappUri;
      return SpecEmptyState(
        icon: Icons.event_busy_outlined,
        title: l10n.callsNoSlots,
        body: l10n.callsNoSlotsBody,
        action: whatsapp == null
            ? null
            : SpecSecondaryButton(
                label: l10n.commonOpenWhatsApp,
                icon: Icons.chat_outlined,
                onPressed: () => openExternalLink(context, whatsapp),
              ),
      );
    }
    final day = slots.days[_day.clamp(0, slots.days.length - 1)];
    final material = MaterialLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: slots.days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => ChoiceChip(
              label: Text(fullDayLabel(context, slots.days[i].date)),
              selected: slots.days[i] == day,
              selectedColor: AppColors.primaryTint,
              onSelected: (_) => setState(() {
                _day = i;
                _slot = null;
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final slot in day.times)
              ChoiceChip(
                label: Text(context.localizeDigits(material
                    .formatTimeOfDay(TimeOfDay.fromDateTime(slot.startsAt)))),
                selected: slot.value == _slot?.value,
                selectedColor: AppColors.primaryTint,
                onSelected: (_) => setState(() => _slot = slot),
              ),
          ],
        ),
      ],
    );
  }

  /// How long each kind lasts (12.1).
  static int _minutesOf(AppointmentType type) =>
      type == AppointmentType.quickConsult ? 15 : 30;

  static String _topicLabel(AppLocalizations l10n, String topic) =>
      switch (topic) {
        'weight' => l10n.callsTopicWeight,
        'meals' => l10n.callsTopicMeals,
        'plan_change' => l10n.callsTopicPlanChange,
        'results' => l10n.callsTopicResults,
        'medications' => l10n.callsTopicMedications,
        _ => l10n.callsTopicOther,
      };
}

/// Tells the patient why an appointment write failed (API guide 12, 15).
/// `appointment_locked` opens a dialog with the nutritionist's WhatsApp,
/// since only they can change the appointment now.
Future<void> showAppointmentFailure(
    BuildContext context, Failure failure) async {
  final l10n = context.l10n;
  if (failure case ApiFailure(code: 'appointment_locked', :final body)) {
    final hours = body['lock_hours'] is int ? body['lock_hours'] as int : 12;
    final number = body['nutritionist_whatsapp'];
    final whatsapp = number is String
        ? NutritionistProfile(name: '', whatsappNumber: number).whatsappUri
        : null;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.callsErrorLocked(context.localizeDigits(hours))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonClose),
          ),
          if (whatsapp != null)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openExternalLink(context, whatsapp);
              },
              child: Text(l10n.commonOpenWhatsApp),
            ),
        ],
      ),
    );
    return;
  }
  showSpecSnack(
    context,
    switch (failure) {
      ApiFailure(code: 'appointment_exists') => l10n.callsErrorExists,
      ApiFailure(code: 'slot_unavailable' || 'slot_taken') =>
        l10n.callsErrorSlotTaken,
      ApiFailure(code: 'video_unavailable') => l10n.callsErrorVideo,
      ApiFailure(code: 'appointment_closed') ||
      NotFoundFailure() =>
        l10n.callsErrorClosed,
      NetworkFailure() => l10n.commonOfflineBody,
      _ => l10n.callsErrorGeneric,
    },
    error: true,
  );
}

String appointmentTypeTitle(AppLocalizations l10n, AppointmentType type) =>
    switch (type) {
      AppointmentType.followUp => l10n.callsTypeFollowUp,
      AppointmentType.resultsReview => l10n.callsResultsReview,
      AppointmentType.quickConsult => l10n.callsTypeQuickConsult,
      AppointmentType.unknown => l10n.callsTypeOther,
    };

String appointmentChannelLabel(
        AppLocalizations l10n, AppointmentChannel channel) =>
    switch (channel) {
      AppointmentChannel.whatsapp => l10n.callsChannelWhatsapp,
      AppointmentChannel.phone => l10n.callsChannelPhone,
      AppointmentChannel.video => l10n.callsChannelVideo,
      AppointmentChannel.unknown => l10n.callsTypeOther,
    };

IconData appointmentChannelIcon(AppointmentChannel channel) =>
    switch (channel) {
      AppointmentChannel.whatsapp => Icons.chat_outlined,
      AppointmentChannel.phone => Icons.call_outlined,
      AppointmentChannel.video => Icons.videocam_outlined,
      AppointmentChannel.unknown => Icons.event_outlined,
    };
