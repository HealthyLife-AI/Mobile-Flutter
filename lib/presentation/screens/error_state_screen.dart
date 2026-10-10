import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/app_header_bar.dart';

/// "حدث خطأ" — the generic, retryable sync-failure state (distinct from
/// [OfflineStateScreen]: this is "we had a connection and the request still
/// failed", not "there is no connection at all"). Always pairs a clear
/// data-safety reassurance with one concrete next step.
class ErrorStateScreen extends StatelessWidget {
  const ErrorStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'حدث خطأ', backIcon: Icons.close_rounded),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: const Text('قيد الفحص السريع', style: AppTextStyles.caption),
              ),
              const Spacer(),
              const Row(children: [
                Text('حالة خوادم HealthyLife', style: AppTextStyles.caption),
                SizedBox(width: 6),
                _StatusPulseDot(),
              ]),
            ]),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFEAF7F2), Color(0xFFF7FBFA)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Stack(alignment: Alignment.center, children: [
                Container(width: 210, height: 210, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.4))),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16)]),
                  child: const Icon(Icons.priority_high_rounded, color: AppColors.danger, size: 32),
                ),
                Positioned(top: 30, right: 60, child: Container(width: 46, height: 46, decoration: const BoxDecoration(color: AppColors.accentGreenBg, shape: BoxShape.circle), child: const Icon(Icons.favorite_rounded, color: AppColors.accentGreen))),
                Positioned(bottom: 34, left: 60, child: Container(width: 46, height: 46, decoration: const BoxDecoration(color: Color(0xFFFCE4E4), shape: BoxShape.circle), child: const Icon(Icons.replay_rounded, color: AppColors.danger))),
              ]),
            ),
            const SizedBox(height: 26),
            const Text('حدث خطأ غير متوقع', textAlign: TextAlign.center, style: AppTextStyles.h1),
            const SizedBox(height: 12),
            const Text(
              'عذراً، لم نتمكن من مزامنة هذه الصفحة في الوقت الراهن. خذ نفساً هادئاً، ونرجو منك المحاولة مرة أخرى.',
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary,
            ),
            const SizedBox(height: 26),
            const _InfoRow(
              icon: Icons.verified_user_rounded,
              iconColor: AppColors.accentGreen,
              iconBg: AppColors.accentGreenBg,
              title: 'بياناتك الصحية بأمان تام',
              subtitle: 'سجلات الوجبات، تتبع السعرات، وتاريخك الحيوي لم تتأثر إطلاقاً ومحفوظة سحابياً بنجاح.',
            ),
            const SizedBox(height: 14),
            const _InfoRow(
              icon: Icons.wifi_tethering_rounded,
              iconColor: AppColors.primary,
              iconBg: AppColors.primaryTint,
              title: 'إرشادات سريعة للحل',
              subtitle: 'يُرجى التحقق من اتصال شبكة الإنترنت أو تكرار الطلب بعد بضع ثوانٍ ليستجيب النظام.',
            ),
            const SizedBox(height: 26),
            GradientCtaButton(
              label: 'إعادة المحاولة الآن',
              icon: Icons.refresh_rounded,
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                icon: const Icon(Icons.home_rounded, size: 16, color: AppColors.textSecondary),
                label: const Text('العودة للرئيسية', style: AppTextStyles.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _InfoRow({required this.icon, required this.iconColor, required this.iconBg, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle), child: Icon(icon, color: iconColor)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption),
          ]),
        ),
      ]),
    );
  }
}

class _StatusPulseDot extends StatefulWidget {
  const _StatusPulseDot();
  @override
  State<_StatusPulseDot> createState() => _StatusPulseDotState();
}

class _StatusPulseDotState extends State<_StatusPulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.accentGreen.withValues(alpha: 0.5 + 0.5 * _c.value), shape: BoxShape.circle)),
    );
  }
}
