import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// The animated "no internet" glyph: a dashed radar ring, a Wi-Fi arc with a
/// red alert badge, a green "still saving" check, and a small syncing chat
/// bubble — shared by [ConnectionStatusSheet] and [OfflineStateScreen] so
/// the two never drift into slightly different iconography.
class OfflineStatusGlyph extends StatefulWidget {
  const OfflineStatusGlyph({super.key});

  @override
  State<OfflineStatusGlyph> createState() => _OfflineStatusGlyphState();
}

class _OfflineStatusGlyphState extends State<OfflineStatusGlyph> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Opacity(opacity: 0.5 + 0.5 * _pulse.value, child: child),
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.4)),
          ),
        ),
        Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryTint.withValues(alpha: 0.5))),
        const Icon(Icons.wifi_rounded, size: 46, color: AppColors.primary),
        Positioned(
          top: 34,
          right: 40,
          child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFFFCE4E4), shape: BoxShape.circle), child: const Icon(Icons.priority_high_rounded, color: AppColors.danger, size: 16)),
        ),
        Positioned(
          bottom: 40,
          left: 40,
          child: Container(width: 34, height: 34, decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 18)),
        ),
        Positioned(
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
            child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 5, height: 5, decoration: BoxDecoration(color: i == 0 ? AppColors.accentGreen : AppColors.iconMuted, shape: BoxShape.circle)))),
          ),
        ),
      ]),
    );
  }
}

class OfflineCapabilityItem {
  final String title;
  final String subtitle;
  const OfflineCapabilityItem(this.title, this.subtitle);
}

const List<OfflineCapabilityItem> offlineCapabilities = [
  OfflineCapabilityItem('تصفح خطة وجبات اليوم المخزنة', 'جداول السعرات والمكونات متوفرة بدون اتصال'),
  OfflineCapabilityItem('تسجيل قياسات الوزن والمحيط', 'يتم حفظ التغييرات بقاعدة بيانات الهاتف المشفرة'),
  OfflineCapabilityItem('تدوين الملاحظات والوجبات السريعة', 'تُدرج في قائمة الانتظار للمزامنة الفورية لاحقاً'),
  OfflineCapabilityItem('حماية الخصوصية والتشفير المحلي', 'تشفير متقدم يحمي سجلاتك الصحية دون الحاجة لسيرفر'),
];

/// The shared body: headline, reassurance paragraph, the "local mode
/// active" highlight box, and the capability checklist. Both offline
/// surfaces render this identically; only the chrome around it differs.
class OfflineExplainerBody extends StatelessWidget {
  final bool showGlyph;
  const OfflineExplainerBody({super.key, this.showGlyph = true});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (showGlyph) ...[const OfflineStatusGlyph(), const SizedBox(height: 24)],
      const Text('لا يوجد اتصال بالإنترنت', textAlign: TextAlign.center, style: AppTextStyles.h1),
      const SizedBox(height: 12),
      const Text(
        'بياناتك ووجباتك المسجلة محفوظة بأمان تام على جهازك. سنقوم بالمزامنة السحابية تلقائياً فور عودة الشبكة.',
        textAlign: TextAlign.center,
        style: AppTextStyles.secondary,
      ),
      const SizedBox(height: 20),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.bolt_rounded, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)), child: const Text('محلياً', style: TextStyle(fontSize: 10, color: AppColors.primary))),
                const SizedBox(width: 8),
                const Text('الوضع غير المتصل نشط', style: AppTextStyles.cardTitle),
              ]),
              const SizedBox(height: 6),
              const Text('يمكنك متابعة تصفح خطتك الغذائية وتسجيل وجباتك كالمعتاد بدون أي انقطاع.', style: AppTextStyles.caption),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 22),
      const Row(children: [
        Icon(Icons.visibility_off_outlined, color: AppColors.primary, size: 18),
        SizedBox(width: 8),
        Expanded(child: Text('ما الذي يمكنك إنجازه الآن؟', style: AppTextStyles.sectionHeading)),
      ]),
      const SizedBox(height: 14),
      for (final c in offlineCapabilities)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 26, height: 26, decoration: const BoxDecoration(color: AppColors.accentGreenBg, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: AppColors.accentGreen, size: 15)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(c.subtitle, style: AppTextStyles.caption),
              ]),
            ),
          ]),
        ),
    ]);
  }
}
