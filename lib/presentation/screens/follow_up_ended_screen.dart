import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/navigation/logout_flow.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/final_report_summary_sheet.dart';
import 'specialist_profile_screen.dart';
import 'privacy_document_screen.dart';

class _StatChip {
  final String value;
  final String label;
  final IconData icon;
  const _StatChip(this.value, this.label, this.icon);
}

/// Shown once a patient's clinical follow-up period has expired: their
/// data is safe and nothing is lost, but active plan customization is
/// paused until they renew through their specialist. Reached today from
/// Profile → المزيد as a QA/demo entry, matching how [PlanPreparingScreen]
/// and [OfflineStateScreen] are previewed — in production this would be
/// the gate Home redirects to once the subscription end date passes.
class FollowUpEndedScreen extends StatelessWidget {
  const FollowUpEndedScreen({super.key});

  static const List<_StatChip> _stats = [
    _StatChip('بنجاح', 'حالة المتابعة', Icons.check_circle_outline_rounded),
    _StatChip('12 أسبوع', 'القياسات المسجلة', Icons.calendar_month_outlined),
    _StatChip('88%', 'الالتزام بالوجبات', Icons.pie_chart_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'انتهت المتابعة'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          children: [
            Center(
              child: Stack(alignment: Alignment.center, children: [
                Container(width: 108, height: 108, decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle)),
                const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 44),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 16)),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.verified_rounded, size: 13, color: AppColors.accentGreen),
                  SizedBox(width: 6),
                  Text('اكتمال خطة المتابعة السريرية', style: TextStyle(fontSize: 11, color: AppColors.accentGreen, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            const SizedBox(height: 18),
            const Text('انتهت فترة متابعتك الحالية', textAlign: TextAlign.center, style: AppTextStyles.h1),
            const SizedBox(height: 10),
            const Text(
              'نتمنى أنك استمتعتِ بخطتك الصحية وحققتِ أهدافك! لقد انتهت فترة المتابعة الحالية مع أخصائيتك. للتجديد أو لاستكمال رحلتك العلاجية والحصول على خطة جديدة، يمكنك التواصل مباشرة وبكل سهولة.',
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary,
            ),
            const SizedBox(height: 22),
            Row(
              children: _stats
                  .map((s) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                          child: Column(children: [
                            Icon(s.icon, color: AppColors.primary, size: 18),
                            const SizedBox(height: 8),
                            Text(s.value, style: AppTextStyles.cardTitle),
                            const SizedBox(height: 2),
                            Text(s.label, style: AppTextStyles.caption, textAlign: TextAlign.center),
                          ]),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Row(children: [
                Container(width: 46, height: 46, decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('د. خلود العربي', style: AppTextStyles.cardTitle),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)), child: const Text('مشرفك', style: TextStyle(fontSize: 10, color: AppColors.primary))),
                    ]),
                    const SizedBox(height: 2),
                    const Text('أخصائية التغذية العلاجية المشرفة عليك', style: AppTextStyles.caption),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: const Row(children: [
                Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(child: Text('سجلاتك وقياساتك السابقة محفوظة بأمان تام في ملفك الصحي، ويمكن استئناف الخطة والمتابعة فوراً بمجرد التجديد.', style: AppTextStyles.caption)),
              ]),
            ),
            const SizedBox(height: 22),
            GradientCtaButton(
              label: 'التواصل مع أخصائيتك عبر واتساب',
              gradient: CtaGradientType.voice,
              icon: Icons.chat_rounded,
              onPressed: () => Navigator.of(context).push(AppPageRoute(builder: (_) => const SpecialistProfileScreen())),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => performLogoutFlow(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
                label: const Text('تسجيل الخروج من الحساب', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: () => FinalReportSummarySheet.show(context),
                child: const Text('استعراض ملخص التقرير النهائي للمتابعة', style: AppTextStyles.pillLabel),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(AppPageRoute(builder: (_) => const PrivacyDocumentScreen())),
                child: const Text('شروط الخدمة وسياسة الخصوصية للملفات الطبية', style: AppTextStyles.caption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
