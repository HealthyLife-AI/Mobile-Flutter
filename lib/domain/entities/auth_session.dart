/// Authentication/session state for the invite-based activation flow.
///
/// There is no username/password login: a clinic sends an invite link,
/// the patient activates it by choosing a password, completes onboarding,
/// and from then on the session simply records that this device is
/// activated and onboarded.
class AuthSession {
  const AuthSession({
    required this.activated,
    required this.onboardingCompleted,
    this.activatedAt,
    this.displayName,
  });

  final bool activated;
  final bool onboardingCompleted;
  final DateTime? activatedAt;
  final String? displayName;

  /// App shell is only reachable once the invite is activated AND the
  /// onboarding wizard finished.
  bool get isReady => activated && onboardingCompleted;

  AuthSession copyWith({bool? activated, bool? onboardingCompleted, DateTime? activatedAt, String? displayName}) =>
      AuthSession(
        activated: activated ?? this.activated,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        activatedAt: activatedAt ?? this.activatedAt,
        displayName: displayName ?? this.displayName,
      );

  Map<String, dynamic> toJson() => {
        'activated': activated,
        'onboardingCompleted': onboardingCompleted,
        if (activatedAt != null) 'activatedAt': activatedAt!.toIso8601String(),
        if (displayName != null) 'displayName': displayName,
      };

  static AuthSession? fromJson(Map<String, dynamic> json) {
    final activated = json['activated'];
    if (activated is! bool) return null; // unknown/corrupted payload
    return AuthSession(
      activated: activated,
      onboardingCompleted: json['onboardingCompleted'] == true,
      activatedAt: json['activatedAt'] is String ? DateTime.tryParse(json['activatedAt'] as String) : null,
      displayName: json['displayName'] is String ? json['displayName'] as String : null,
    );
  }

  static const AuthSession empty = AuthSession(activated: false, onboardingCompleted: false);
}
