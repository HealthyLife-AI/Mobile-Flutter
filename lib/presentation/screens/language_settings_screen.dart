import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/app_header_bar.dart';
import '../../core/di/app_dependencies.dart';
import '../bloc/settings/settings_cubit.dart';

import '../../l10n/l10n.dart';

/// اللغة — AR/EN selector. Tapping a card only selects it; "save" applies
/// the choice through [SettingsCubit] (the app's single language state),
/// which persists it and re-renders the whole app — text and direction —
/// without a restart.
class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  /// The card tapped on this screen, applied only on save. Until the user
  /// taps one, the selection is the app's current language.
  String? _picked;

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final settings = context.read<SettingsCubit>();
    final preferences = context.read<AppDependencies>().preferences;
    final code = _picked ?? settings.state.effectiveLocale.languageCode;
    await settings.setLocale(Locale(code));
    // The server needs the new language for push text (API guide 10.5).
    unawaited(preferences.sync());
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final current = context.select<SettingsCubit, String>(
        (cubit) => cubit.state.effectiveLocale.languageCode);
    final selected = _picked ?? current;
    // Each card names its language in its own script, with the other
    // language's name for it underneath — the same in both app languages.
    // Only the "current app language" marker is UI text and follows the
    // language the app is actually in.
    String subtitle(String code, String otherName) => code == current
        ? context.l10n.languageSubtitleCurrent(otherName)
        : otherName;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.languageTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          const _LanguageHero(),
          const SizedBox(height: 22),
          _LanguageCard(
            code: 'ar',
            name: 'العربية',
            subtitle: subtitle('ar', 'Arabic'),
            flowLabel: 'اتجاه القراءة',
            directionTag: 'RTL',
            directionText: 'من اليمين إلى اليسار',
            isRtl: true,
            selected: selected == 'ar',
            isCurrent: current == 'ar',
            onTap: () => setState(() => _picked = 'ar'),
          ),
          const SizedBox(height: 14),
          _LanguageCard(
            code: 'en',
            name: 'English',
            subtitle: subtitle('en', 'الإنجليزية'),
            flowLabel: 'Text Flow:',
            directionTag: 'LTR',
            directionText: '(Left-to-Right)',
            isRtl: false,
            selected: selected == 'en',
            isCurrent: current == 'en',
            onTap: () => setState(() => _picked = 'en'),
          ),
          const SizedBox(height: 20),
          const _DirectionEffectNote(),
          const SizedBox(height: 22),
          GradientCtaButton(
            label: context.l10n.languageSave,
            icon: Icons.check_circle_outline_rounded,
            onPressed: _save,
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              context.l10n.languageFooter,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

/// المقدمة: النصان على اليمين وأيقونة الترجمة داخل دائرة على اليسار،
/// ثم فقرة الشرح بدون صندوق.
class _LanguageHero extends StatelessWidget {
  const _LanguageHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.languageCustomizeInterface,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.pillLabel,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.languageChooseTitle,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.h1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.translate_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.languageChooseBody,
          textAlign: TextAlign.start,
          style: AppTextStyles.secondary,
        ),
      ],
    );
  }
}

/// بطاقة لغة قابلة للاختيار.
///
/// الترتيب (من اليمين لليسار): أيقونة شبكة الحروف، الاسم + الشارة،
/// ثم دائرة الاختيار. وفي الأسفل: عنوان الاتجاه على اليمين
/// وكبسولة الاتجاه على اليسار.
class _LanguageCard extends StatelessWidget {
  final String code;
  final String name;
  final String subtitle;
  final String flowLabel;
  final String directionTag;
  final String directionText;
  final bool isRtl;
  final bool selected;

  /// The language the app is in right now (shows the badge).
  final bool isCurrent;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.flowLabel,
    required this.directionTag,
    required this.directionText,
    required this.isRtl,
    required this.selected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.hairline,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // أيقونة شبكة الحروف (على اليمين)
                _LanguageGlyph(code: code, selected: selected),
                const SizedBox(width: 12),
                // الاسم + الشارة + السطر الفرعي
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(name, style: AppTextStyles.cardTitle),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTint,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  context.l10n.languageCurrentBadge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // دائرة الاختيار (على اليسار)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('check'),
                            size: 15,
                            color: Colors.white,
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // عنوان الاتجاه + أيقونته (على اليمين)
                Icon(
                  isRtl
                      ? Icons.format_textdirection_r_to_l_rounded
                      : Icons.format_textdirection_l_to_r_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(flowLabel, style: AppTextStyles.caption),
                const Spacer(),
                // كبسولة الاتجاه (على اليسار)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          directionTag,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          directionText,
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// المربع المدوّر الذي يحتوي شبكة حروف اللغة (عربية أو لاتينية).
class _LanguageGlyph extends StatelessWidget {
  final String code;
  final bool selected;
  const _LanguageGlyph({required this.code, required this.selected});

  static const List<String> _arabicRows = [
    'ا ب ت ث ج',
    'ح خ د ذ ر',
    'ز س ش ص ض',
    'ط ظ ع غ ف',
  ];

  static const List<String> _latinRows = [
    'F G H I J',
    'K L M N O',
    'P Q R S T',
    'U V W X Y',
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = code == 'ar';
    final rows = isArabic ? _arabicRows : _latinRows;
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryTint : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.28)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final row in rows)
              SizedBox(
                width: 48,
                height: 10,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    row,
                    softWrap: false,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: 8.5,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ملاحظة تشرح أن اتجاه التطبيق ينعكس تلقائياً عند تغيير اللغة.
class _DirectionEffectNote extends StatelessWidget {
  const _DirectionEffectNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.sync_alt_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.languageEffectTitle,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.languageEffectBody,
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
