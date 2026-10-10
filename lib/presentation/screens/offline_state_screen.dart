import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/offline_capability_panel.dart';
import '../widgets/connection_status_sheet.dart';
import '../widgets/app_header_bar.dart';
import 'weekly_plan_screen.dart';
import 'error_state_screen.dart';
import '../../core/navigation/app_page_route.dart';

/// The full-screen "no connection" state. Reached today from Profile →
/// المزيد (a QA/demo entry point, matching how [PlanPreparingScreen] is
/// wired) and, in a real build, would replace the Home tab's body whenever
/// connectivity drops. Retrying here simulates the request failing, which
/// hands off to [ErrorStateScreen] — offline and error are two different,
/// clearly distinguished states rather than one generic message.
class OfflineStateScreen extends StatelessWidget {
  const OfflineStateScreen({super.key});

  Future<void> _retry(BuildContext context) async {
    await Navigator.of(context).push(AppPageRoute(builder: (_) => const ErrorStateScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(
        title: 'لا يوجد اتصال',
        backIcon: Icons.close_rounded,
        actions: [],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            GestureDetector(
              onTap: () => ConnectionStatusSheet.show(context),
              child: const OfflineExplainerBody(),
            ),
            const SizedBox(height: 26),
            GradientCtaButton(label: 'إعادة محاولة الاتصال', icon: Icons.refresh_rounded, onPressed: () => _retry(context)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(AppPageRoute(builder: (_) => const WeeklyPlanScreen())),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
                icon: const Icon(Icons.restaurant_menu_rounded, size: 18, color: AppColors.textPrimary),
                label: const Text('عرض الوجبات المحفوظة أوفلاين', style: AppTextStyles.body),
              ),
            ),
            const SizedBox(height: 14),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Flexible(child: Text('تحقق من تفعيل Wi-Fi أو بيانات الهاتف من إعدادات جهازك', style: AppTextStyles.caption, textAlign: TextAlign.center)),
            ]),
          ],
        ),
      ),
    );
  }
}
