import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import 'offline_capability_panel.dart';

/// "حالة الاتصال" — a draggable info sheet a patient can open (e.g. by
/// tapping the connection badge on [OfflineStateScreen]) to understand
/// exactly what still works while offline, without leaving their place in
/// the app. Purely informational — no destructive or navigating actions.
class ConnectionStatusSheet extends StatelessWidget {
  const ConnectionStatusSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ConnectionStatusSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
          child: Column(children: [
            const SizedBox(height: 10),
            Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(AppRadius.pill))),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20)),
                const SizedBox(width: 8),
                GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close_rounded, color: AppColors.textSecondary)),
                const Spacer(),
                const Text('حالة الاتصال', style: AppTextStyles.sectionHeading),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary, size: 18),
              ]),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                children: const [OfflineExplainerBody()],
              ),
            ),
          ]),
        );
      },
    );
  }
}
