import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

enum HomeConnectionState { online, offline, syncing }

/// The compact, non-blocking banner Home shows in place of a full takeover
/// screen whenever there is already cached content on-screen: "offline but
/// everything still works" (with a pending-sync count once something was
/// logged while disconnected), then a brief "syncing" moment the instant
/// connectivity returns. [OfflineStateScreen] remains the full-page version
/// for a cold start with nothing cached yet — the two are deliberately
/// different weights for two different situations.
class OfflineBanner extends StatelessWidget {
  final HomeConnectionState state;
  final int pendingCount;
  final VoidCallback onTap;

  const OfflineBanner({super.key, required this.state, required this.pendingCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool syncing = state == HomeConnectionState.syncing;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: syncing ? AppColors.primaryTint : const Color(0xFFFDF3E4),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(children: [
          SizedBox(
            width: 34,
            height: 34,
            child: syncing
                ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(AppColors.primary)))
                : Container(decoration: const BoxDecoration(color: Color(0xFFF2C265), shape: BoxShape.circle), child: const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                syncing ? 'جاري مزامنة بياناتك...' : 'أنت غير متصل بالإنترنت الآن',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                syncing ? 'يتم تحديث سجلاتك مع الخادم الآن' : 'بياناتك محفوظة محلياً بأمان تام',
                style: AppTextStyles.caption,
              ),
            ]),
          ),
          if (!syncing && pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text('$pendingCount بانتظار المزامنة', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
            ),
        ]),
      ),
    );
  }
}
