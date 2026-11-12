import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfx/pdfx.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/health_records_repository_impl.dart';
import '../../domain/entities/health_records_entities.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../l10n/l10n.dart';
import '../date_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/confirm_action_sheet.dart';
import '../widgets/spec_ui.dart';
import '../widgets/state_views.dart';

String reportCategoryLabel(AppLocalizations l10n, ReportCategory c) =>
    switch (c) {
      ReportCategory.labTest => l10n.reportCategoryLab,
      ReportCategory.imaging => l10n.reportCategoryImaging,
      ReportCategory.prescription => l10n.reportCategoryPrescription,
      ReportCategory.medicalLetter => l10n.reportCategoryLetter,
      ReportCategory.other => l10n.reportCategoryOther,
    };

/// "340 ك.ب" / "1.2 م.ب".
String fileSizeLabel(BuildContext context, int bytes) {
  final l10n = context.l10n;
  if (bytes >= 1024 * 1024) {
    return l10n.fileSizeMb(
        context.localizeDigits((bytes / (1024 * 1024)).toStringAsFixed(1)));
  }
  return l10n.fileSizeKb(context.localizeDigits((bytes / 1024).ceil()));
}

/// "تقاريري الطبية", inside the health record.
///
/// Every reports endpoint answers 404 until the privacy policy is published:
/// then this section renders nothing, with no error. A new consent version
/// asks for agreement first.
class MedicalReportsSection extends StatefulWidget {
  const MedicalReportsSection({super.key});

  @override
  State<MedicalReportsSection> createState() => _MedicalReportsSectionState();
}

enum _ReportsPhase { loading, off, consent, list, error }

class _MedicalReportsSectionState extends State<MedicalReportsSection> {
  late final MedicalReportsRepository _repository =
      context.read<AppDependencies>().medicalReports;

  _ReportsPhase _phase = _ReportsPhase.loading;
  ReportsConsent? _consent;
  List<MedicalReport> _reports = const [];
  bool _agreeing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final consent = await _repository.getConsent();
    if (!mounted) return;
    if (consent.failureOrNull != null) {
      setState(() => _phase = _ReportsPhase.error);
      return;
    }
    final value = consent.valueOrNull;
    if (value == null) {
      setState(() => _phase = _ReportsPhase.off);
      return;
    }
    if (value.needsAgreement) {
      setState(() {
        _consent = value;
        _phase = _ReportsPhase.consent;
      });
      return;
    }
    await _loadReports();
  }

  Future<void> _loadReports() async {
    final result = await _repository.getReports();
    if (!mounted) return;
    setState(() {
      final reports = result.valueOrNull;
      if (result.failureOrNull is ApiFailure &&
          (result.failureOrNull as ApiFailure).statusCode == 403) {
        _phase = _ReportsPhase.consent;
      } else if (result.failureOrNull != null) {
        _phase = _ReportsPhase.error;
      } else if (reports == null) {
        _phase = _ReportsPhase.off;
      } else {
        _reports = reports;
        _phase = _ReportsPhase.list;
      }
    });
  }

  Future<void> _agree() async {
    setState(() => _agreeing = true);
    final result = await _repository.acceptConsent();
    if (!mounted) return;
    setState(() => _agreeing = false);
    if (result.failureOrNull != null) {
      showSpecSnack(context, loadFailureText(context, result.failureOrNull),
          error: true);
      return;
    }
    await _loadReports();
  }

  Future<void> _upload() async {
    final uploaded = await Navigator.of(context)
        .push<bool>(AppPageRoute(builder: (_) => const ReportUploadScreen()));
    if (!mounted) return;
    if (uploaded == false) {
      // The server asked for consent again.
      await _load();
    } else if (uploaded == true) {
      await _loadReports();
    }
  }

  Future<void> _delete(MedicalReport report) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmActionSheet.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: l10n.reportDeleteTitle,
      message: report.title,
      confirmLabel: l10n.reportDelete,
    );
    if (confirmed != true || !mounted) return;
    final result = await _repository.delete(report.id);
    if (!mounted) return;
    if (result.failureOrNull != null) {
      showSpecSnack(context, loadFailureText(context, result.failureOrNull),
          error: true);
      return;
    }
    setState(() => _reports = [
          for (final r in _reports)
            if (r.id != report.id) r,
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    switch (_phase) {
      case _ReportsPhase.loading:
      case _ReportsPhase.off:
        return const SizedBox.shrink();
      case _ReportsPhase.error:
        return SpecCard(
          child: Row(
            children: [
              Expanded(
                child: Text(l10n.reportsLoadFailed,
                    style: AppTextStyles.secondary
                        .copyWith(color: AppColors.textSecondary)),
              ),
              TextButton(onPressed: _load, child: Text(l10n.commonRetry)),
            ],
          ),
        );
      case _ReportsPhase.consent:
        return _ConsentCard(
            consent: _consent, agreeing: _agreeing, onAgree: _agree);
      case _ReportsPhase.list:
        final full = _reports.length >= MedicalReport.maxReports;
        return SpecColumn(
          children: [
            SpecSectionTitle(l10n.reportsTitle,
                icon: Icons.folder_shared_outlined),
            SpecPrimaryButton(
              label: l10n.reportsUploadNew,
              icon: Icons.upload_file_rounded,
              onPressed: full ? null : _upload,
            ),
            for (final report in _reports)
              _ReportCard(
                report: report,
                onOpen: () => Navigator.of(context).push(AppPageRoute(
                    builder: (_) => ReportViewerScreen(report: report))),
                onDelete: () => _delete(report),
              ),
            Text(
              full
                  ? l10n.reportsLimitReached(
                      context.localizeDigits(MedicalReport.maxReports))
                  : l10n.reportsCount(context.localizeDigits(_reports.length),
                      context.localizeDigits(MedicalReport.maxReports)),
              textAlign: TextAlign.center,
              style: AppTextStyles.tiny,
            ),
          ],
        );
    }
  }
}

String loadFailureText(BuildContext context, Failure? failure) =>
    failure is NetworkFailure
        ? context.l10n.commonOfflineBody
        : context.l10n.commonErrorBody;

class _ConsentCard extends StatelessWidget {
  const _ConsentCard(
      {required this.consent, required this.agreeing, required this.onAgree});

  final ReportsConsent? consent;
  final bool agreeing;
  final VoidCallback onAgree;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = consent?.text ?? '';
    return SpecCard(
      highlighted: true,
      child: SpecColumn(
        children: [
          SpecCardHeader(
            icon: Icons.verified_user_outlined,
            title: l10n.reportsConsentTitle,
            trailing: StatusPill(l10n.reportsConsentOnce),
          ),
          SpecPanel(
            child: SpecColumn(
              gap: 6,
              children: [
                BulletLine(l10n.reportsConsentEncrypted),
                BulletLine(l10n.reportsConsentOnlyNutritionist),
                BulletLine(l10n.reportsConsentDelete),
                BulletLine(l10n.reportsConsentNoAi),
              ],
            ),
          ),
          if (text.trim().isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(AppPageRoute(
                    builder: (_) => _ConsentTextScreen(text: text))),
                child: Text(l10n.reportsConsentReadFull),
              ),
            ),
          SpecPrimaryButton(
              label: l10n.reportsConsentAgree,
              loading: agreeing,
              onPressed: onAgree),
        ],
      ),
    );
  }
}

class _ConsentTextScreen extends StatelessWidget {
  const _ConsentTextScreen({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.reportsConsentTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SpecCard(
              child: SelectableText(text,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w400, height: 1.7)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard(
      {required this.report, required this.onOpen, required this.onDelete});

  final MedicalReport report;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final note = report.nutritionistNote;
    final meta = [
      reportCategoryLabel(l10n, report.category),
      if (report.reportDate case final date?) shortDateLabel(context, date),
      report.isPdf ? l10n.reportKindPdf : l10n.reportKindImage,
      if (report.sizeBytes case final size?) fileSizeLabel(context, size),
    ].join(' • ');
    return SpecCard(
      onTap: onOpen,
      child: SpecColumn(
        children: [
          Row(
            children: [
              SpecIconTile(report.isPdf
                  ? Icons.picture_as_pdf_outlined
                  : Icons.image_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title.isEmpty ? '—' : report.title,
                        style: AppTextStyles.cardTitle),
                    Text(meta,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.reportDelete,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textMuted),
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: report.reviewed
                ? StatusPill(l10n.reportReviewed,
                    tone: PillTone.success, icon: Icons.check_rounded)
                : StatusPill(l10n.reportAwaitingReview,
                    tone: PillTone.warning, icon: Icons.schedule_rounded),
          ),
          if (note != null)
            SpecPanel(
              color: AppColors.primaryTint,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.reportNutritionistNote,
                      style: AppTextStyles.pillLabel),
                  const SizedBox(height: 2),
                  Text(note,
                      style: AppTextStyles.secondary
                          .copyWith(color: AppColors.textPrimary, height: 1.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows one report inside the app: downloaded with the patient's token and
/// held in memory only, never saved to the gallery, a public folder or a
/// cache. Leaving the screen drops it.
class ReportViewerScreen extends StatefulWidget {
  const ReportViewerScreen({super.key, required this.report});

  final MedicalReport report;

  @override
  State<ReportViewerScreen> createState() => _ReportViewerScreenState();
}

class _ReportViewerScreenState extends State<ReportViewerScreen> {
  Uint8List? _bytes;
  PdfControllerPinch? _pdf;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pdf?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _failure = null);
    final result = await context
        .read<AppDependencies>()
        .medicalReports
        .downloadFile(widget.report.id);
    if (!mounted) return;
    setState(() {
      result.when(
        success: (bytes) {
          final data = Uint8List.fromList(bytes);
          _bytes = data;
          if (widget.report.isPdf) {
            _pdf = PdfControllerPinch(document: PdfDocument.openData(data));
          }
        },
        failure: (failure) => _failure = failure,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    final pdf = _pdf;
    final Widget body;
    if (_failure != null) {
      body = Center(
        child: SpecEmptyState(
          icon: Icons.cloud_off_rounded,
          title: loadFailureText(context, _failure),
          action: SpecSecondaryButton(
              expand: false, label: context.l10n.commonRetry, onPressed: _load),
        ),
      );
    } else if (bytes == null) {
      body = const ListSkeleton();
    } else if (pdf != null) {
      body = PdfViewPinch(controller: pdf);
    } else {
      body = InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: Image.memory(bytes,
              gaplessPlayback: true,
              errorBuilder: (context, _, __) => SpecEmptyState(
                  icon: Icons.broken_image_outlined,
                  title: context.l10n.reportCannotShow)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: widget.report.title),
      body: SafeArea(child: body),
    );
  }
}

/// "رفع تقرير" — `POST /me/reports` (multipart).
///
/// Photos are taken or picked at about 2000 px on the long side and 80%
/// quality, which also turns iPhone HEIC into JPEG (the server refuses HEIC).
/// PDF up to 10 MB. Title required (up to 120 characters), date optional and
/// never in the future. A progress bar runs during the upload, the button
/// stays off until it ends, and nothing is uploaded offline.
///
/// Pops `true` after an upload, `false` when the server asked for consent.
class ReportUploadScreen extends StatefulWidget {
  const ReportUploadScreen({super.key});

  @override
  State<ReportUploadScreen> createState() => _ReportUploadScreenState();
}

class _PickedFile {
  const _PickedFile(this.bytes, this.name, this.mime);

  final Uint8List bytes;
  final String name;
  final String mime;
}

class _ReportUploadScreenState extends State<ReportUploadScreen> {
  final TextEditingController _title = TextEditingController();
  ReportCategory _category = ReportCategory.labTest;
  DateTime? _date;
  _PickedFile? _file;
  String? _fileError;
  String? _titleError;
  String? _error;
  double? _progress;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() => _titleError = null));
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  static String _mimeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }

  /// HEIC/HEIF starts with an `ftyp` box naming a HEIF brand.
  static bool _isHeif(Uint8List b) {
    if (b.length < 12) return false;
    final brand = String.fromCharCodes(b.sublist(4, 12));
    return brand.startsWith('ftyp') &&
        const ['heic', 'heix', 'hevc', 'heim', 'heis', 'mif1', 'msf1']
            .contains(brand.substring(4));
  }

  void _take(Uint8List bytes, String name) {
    final l10n = context.l10n;
    setState(() {
      _error = null;
      if (_isHeif(bytes)) {
        _file = null;
        _fileError = l10n.reportErrorType;
      } else if (bytes.length > MedicalReport.maxBytes) {
        _file = null;
        _fileError = l10n.reportErrorTooLarge;
      } else {
        _file = _PickedFile(bytes, name, _mimeFor(name));
        _fileError = null;
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 80,
        requestFullMetadata: false,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      var name = picked.name;
      // Re-encoded by the picker: name it after what it now is.
      if (!RegExp(r'\.(jpe?g|png|webp)$', caseSensitive: false)
          .hasMatch(name)) {
        name = '${name.split('.').first}.jpg';
      }
      _take(bytes, name);
    } on Object {
      if (mounted) {
        showSpecSnack(context, context.l10n.reportPickFailed, error: true);
      }
    }
  }

  Future<void> _pickPdf() async {
    try {
      final picked = await FilePicker.pickFile(
          type: FileType.custom, allowedExtensions: const ['pdf']);
      if (picked == null || !mounted) return;
      final size = await picked.length();
      if (!mounted) return;
      if (size != null && size > MedicalReport.maxBytes) {
        setState(() {
          _file = null;
          _fileError = context.l10n.reportErrorTooLarge;
        });
        return;
      }
      final bytes = await picked.readAsBytes();
      if (mounted) _take(bytes, picked.name);
    } on Object {
      if (mounted) {
        showSpecSnack(context, context.l10n.reportPickFailed, error: true);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: DateTime(today.year - 30),
      lastDate: today,
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _upload() async {
    final l10n = context.l10n;
    final file = _file;
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = l10n.reportTitleRequired);
      return;
    }
    if (file == null) return;
    setState(() {
      _progress = 0;
      _error = null;
    });
    final result = await context.read<AppDependencies>().medicalReports.upload(
      ReportUpload(
        bytes: file.bytes,
        filename: file.name,
        mime: file.mime,
        category: _category,
        title: title,
        reportDate: _date,
      ),
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );
    if (!mounted) return;
    final failure = result.failureOrNull;
    if (failure == null) {
      showSpecSnack(context, l10n.reportUploaded);
      Navigator.of(context).pop(true);
      return;
    }
    final known = reportUploadErrorOf(failure);
    if (known == ReportUploadError.consentRequired) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _progress = null;
      _error = switch (known) {
        ReportUploadError.tooLarge => l10n.reportErrorTooLarge,
        ReportUploadError.typeNotAllowed => l10n.reportErrorType,
        ReportUploadError.invalidImage => l10n.reportErrorInvalidImage,
        ReportUploadError.limitReached => l10n.reportErrorLimit,
        _ => failure is ApiFailure && failure.fieldErrors.isNotEmpty
            ? failure.fieldErrors.values.first
            : loadFailureText(context, failure),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uploading = _progress != null;
    final file = _file;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.reportUploadTitle),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: uploading,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Text(l10n.reportCategory, style: AppTextStyles.cardTitle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in ReportCategory.values)
                    ChoiceChip(
                      label: Text(reportCategoryLabel(l10n, c)),
                      selected: _category == c,
                      showCheckmark: false,
                      selectedColor: AppColors.primaryTint,
                      labelStyle: AppTextStyles.secondary.copyWith(
                          color: _category == c
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                      side: BorderSide(
                          color: _category == c
                              ? AppColors.primary
                              : AppColors.border),
                      shape: const StadiumBorder(),
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.reportTitleLabel, style: AppTextStyles.cardTitle),
              const SizedBox(height: 6),
              TextField(
                controller: _title,
                maxLength: MedicalReport.titleMaxLength,
                decoration: specInputDecoration(l10n.reportTitleHint)
                    .copyWith(counterText: '', errorText: _titleError),
              ),
              const SizedBox(height: 14),
              Text(l10n.reportDateLabel, style: AppTextStyles.cardTitle),
              const SizedBox(height: 6),
              _PickerBox(
                text: _date == null
                    ? l10n.quickRequestPickDate
                    : fullDayLabel(context, _date!),
                placeholder: _date == null,
                icon: Icons.calendar_month_rounded,
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              Text(l10n.reportFileLabel, style: AppTextStyles.cardTitle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                        icon: Icons.photo_camera_outlined,
                        label: l10n.reportFromCamera,
                        onTap: () => _pickImage(ImageSource.camera)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SourceButton(
                        icon: Icons.photo_library_outlined,
                        label: l10n.reportFromGallery,
                        onTap: () => _pickImage(ImageSource.gallery)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SourceButton(
                        icon: Icons.picture_as_pdf_outlined,
                        label: l10n.reportFromPdf,
                        onTap: _pickPdf),
                  ),
                ],
              ),
              if (file != null) ...[
                const SizedBox(height: 10),
                SpecPanel(
                  child: Row(
                    children: [
                      Icon(
                          file.mime == 'application/pdf'
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined,
                          color: AppColors.primary,
                          size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            '${file.name} • ${fileSizeLabel(context, file.bytes.length)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.secondary),
                      ),
                    ],
                  ),
                ),
              ],
              if (_fileError != null) ...[
                const SizedBox(height: 10),
                _ErrorBox(_fileError!),
              ],
              const SizedBox(height: 8),
              Text(l10n.reportFileHint, style: AppTextStyles.tiny),
              if (_error != null) ...[
                const SizedBox(height: 12),
                _ErrorBox(_error!),
              ],
              const SizedBox(height: 18),
              if (uploading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    color: AppColors.primary,
                    backgroundColor: AppColors.border,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SpecPrimaryButton(
                label: l10n.reportUpload,
                loading: uploading,
                onPressed: file == null ? null : _upload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.text,
    required this.placeholder,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final bool placeholder;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.panel),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(text,
                    style: placeholder
                        ? AppTextStyles.secondary
                            .copyWith(color: AppColors.textMuted)
                        : AppTextStyles.body),
              ),
              Icon(icon, color: AppColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.panel),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(AppRadius.panel),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.danger, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: AppTextStyles.secondary
                      .copyWith(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }
}
