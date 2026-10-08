import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/clinical_trust_footer.dart';
import '../widgets/app_header_bar.dart';

/// ملف الأخصائي — the linked nutritionist's profile, a short standing
/// "health follow-up" message, and a WhatsApp quick-consult card.
class SpecialistProfileScreen extends StatelessWidget {
  const SpecialistProfileScreen({super.key});

  static const Color _whatsapp = Color(0xFF25D366);
  static const Color _mint = Color(0xFF7DF2D6);
  static const Color _lavender = Color(0xFFEEF1FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'ملف الأخصائي'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            // ── شريط حالة الملف ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الملف الغذائي العلاجي نشط',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.verified_rounded, size: 15, color: AppColors.primary),
                const SizedBox(width: 4),
                const Text(
                  'معتمد',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ]),
            ),
            const SizedBox(height: 10),

            // ── بطاقة الأخصائية ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.hairline),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // الشريط المتدرج الرفيع (تيل من اليمين إلى نعناعي يساراً)
                    Container(
                      height: 4,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [AppColors.primary, _mint],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const _SpecialistAvatar(),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Flexible(
                                        child: Text(
                                          'أ. خلود العربي',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.sectionHeading.copyWith(fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryTint,
                                          borderRadius: BorderRadius.circular(AppRadius.pill),
                                        ),
                                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                          Icon(Icons.verified_user_outlined, size: 11, color: AppColors.primary),
                                          SizedBox(width: 3),
                                          Text(
                                            'مرخصة',
                                            style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700),
                                          ),
                                        ]),
                                      ),
                                    ]),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'أخصائية التغذية العلاجية المعتمدة',
                                      maxLines: 2,
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(height: 5),
                                    Row(children: [
                                      const Icon(Icons.add_box_outlined, size: 14, color: AppColors.textPrimary),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          'عيادة التغذية العلاجية المتخصصة',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Tag(icon: Icons.workspace_premium_outlined, label: 'مرخصة من الهيئة الصحية'),
                              _Tag(icon: Icons.badge_outlined, label: 'رعاية فردية مباشرة'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── رسالة المتابعة الصحية ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(children: [
                    Icon(Icons.format_quote_rounded, color: AppColors.textPrimary, size: 22),
                    SizedBox(width: 6),
                    Text('رسالة المتابعة الصحية', style: AppTextStyles.sectionHeading),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: _lavender,
                      borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                    ),
                    child: Text(
                      '“مرحباً سارة، أتابع سجل وجباتك وقياساتك بانتظام لتحديث خطتك بما يتناسب مع أهدافك الصحية واستجابة جسمك. لأي استفسار عاجل أو طلب تعديل، يسعدني تواصلك المباشر.”',
                      textAlign: TextAlign.start,
                      style: AppTextStyles.caption.copyWith(height: 1.9, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 17),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('أوقات الرد والمتابعة المعتادة', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle),
                        SizedBox(height: 2),
                        Text('الأحد - الخميس  |  9 ص - 5 م', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
                      ]),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── استشارة سريعة مع الأخصائية ───────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(color: _mint, shape: BoxShape.circle),
                      child: const Icon(Icons.headset_mic_rounded, color: AppColors.primary, size: 22),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('استشارة سريعة مع أخصائيتك', textAlign: TextAlign.center, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  const Text(
                    'تواصلي في أي وقت لمناقشة تعديلات الوجبات والشعور العام',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 46,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _whatsapp,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      // TODO: launch WhatsApp (e.g. url_launcher with wa.me/<number>).
                      onPressed: () {},
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('تواصل عبر واتساب'),
                            SizedBox(width: 8),
                            // TODO: swap for the WhatsApp logo (font_awesome_flutter / SVG).
                            Icon(Icons.chat_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'يفتح محادثة مباشرة مع الأخصائية لمتابعة حالتك',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const ClinicalTrustFooter(),
          ],
        ),
      ),
    );
  }
}

/// صورة الأخصائية الدائرية مع شارة التوثيق (أسفل اليسار).
/// تعود إلى الحرف الأول إن لم تتوفر الصورة.
class _SpecialistAvatar extends StatelessWidget {
  const _SpecialistAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/specialist.png',
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                color: AppColors.primaryTint,
                child: Text('خ', style: AppTextStyles.h1.copyWith(color: AppColors.primary, fontSize: 24)),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -2,
            end: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 5),
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption)),
      ]),
    );
  }
}
