import 'package:flutter/material.dart';
import '../../widgets/confirm_action_sheet.dart';
import 'app_page_route.dart';
import '../../screens/onboarding_screen.dart';

/// Confirms with the person, then tears down the navigation stack back to
/// the marketing onboarding carousel — the app's one "logged out" landing
/// state, since activation here is invite-based rather than a traditional
/// login screen. Every logout affordance in the app (Profile, the
/// follow-up-ended state, …) calls this one function so the behavior can
/// never drift between screens.
Future<void> performLogoutFlow(BuildContext context) async {
  final confirmed = await ConfirmActionSheet.show(
    context,
    icon: Icons.logout_rounded,
    title: 'تسجيل الخروج من الحساب',
    message: 'سيتم إنهاء الجلسة بأمان من هذا الجهاز بعد التأكد من مزامنة قياساتك وسجلاتك الأخيرة.',
    confirmLabel: 'تسجيل الخروج',
  );
  if (confirmed == true && context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(AppPageRoute(builder: (_) => const OnboardingScreen()), (route) => false);
  }
}
