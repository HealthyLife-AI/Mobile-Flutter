import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

enum PasswordStrength { empty, weak, fair, good, strong }

PasswordStrength evaluatePasswordStrength(String pw) {
  if (pw.isEmpty) return PasswordStrength.empty;
  int score = 0;
  if (pw.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(pw)) score++;
  if (RegExp(r'[0-9]').hasMatch(pw)) score++;
  if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pw)) score++;
  switch (score) {
    case 0:
    case 1:
      return PasswordStrength.weak;
    case 2:
      return PasswordStrength.fair;
    case 3:
      return PasswordStrength.good;
    default:
      return PasswordStrength.strong;
  }
}

/// PasswordStrengthMeter — 4-segment bar + label, matching the confirmed
/// Password screen ("جيدة ومقبولة" style status).
class PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;
  const PasswordStrengthMeter({super.key, required this.strength});

  int get _filled {
    switch (strength) {
      case PasswordStrength.empty:
        return 0;
      case PasswordStrength.weak:
        return 1;
      case PasswordStrength.fair:
        return 2;
      case PasswordStrength.good:
        return 3;
      case PasswordStrength.strong:
        return 4;
    }
  }

  String get _label {
    switch (strength) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'ضعيفة';
      case PasswordStrength.fair:
        return 'متوسطة';
      case PasswordStrength.good:
        return 'جيدة ومقبولة';
      case PasswordStrength.strong:
        return 'قوية جداً';
    }
  }

  Color get _color {
    switch (strength) {
      case PasswordStrength.empty:
      case PasswordStrength.weak:
        return AppColors.danger;
      case PasswordStrength.fair:
        return AppColors.accentOrange;
      case PasswordStrength.good:
      case PasswordStrength.strong:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('قوة كلمة المرور:', style: AppTextStyles.caption),
            const Spacer(),
            Text(_label, style: AppTextStyles.caption.copyWith(color: _color, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(4, (i) {
            final bool on = i < _filled;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(left: i == 3 ? 0 : 4),
                decoration: BoxDecoration(
                  color: on ? _color : AppColors.neutralTrack,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
