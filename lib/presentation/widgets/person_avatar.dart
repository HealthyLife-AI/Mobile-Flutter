import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// One avatar for the people the app shows (the patient and the nutritionist),
/// so the same rules apply everywhere:
///
///  * a real photo when the server gives a URL,
///  * the first letter of the real name otherwise,
///  * a neutral icon when even the name is not known.
///
/// Nothing is hardcoded: the name and the URL come from the profile the app
/// loaded, and the widget never invents a person. A photo that fails to load
/// falls back to the letter/icon instead of a broken image.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.fallbackInitial,
    this.fallbackIcon = Icons.person_rounded,
    this.size = 48,
    this.background,
    this.foreground,
    this.textStyle,
  });

  /// The photo, when the profile carries one. Empty/null means no photo.
  final String? imageUrl;

  /// The real name, used for the fallback letter.
  final String? name;

  /// A last-resort letter when [name] is not known either (for example the
  /// existing generic specialist initial). Not used when [name] has a letter.
  final String? fallbackInitial;

  final IconData fallbackIcon;
  final double size;
  final Color? background;
  final Color? foreground;
  final TextStyle? textStyle;

  /// The letter shown for a name: the first letter after an optional title
  /// ("د. أمل" -> "أ"), or the name's first letter.
  static String initialOf(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    final bare = trimmed.replaceFirst(RegExp(r'^\S+\.\s*'), '').trim();
    final source = bare.isEmpty ? trimmed : bare;
    return source.substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final child = url.isNotEmpty
        ? Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallback(context),
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : _fallback(context),
          )
        : _fallback(context);
    return ClipOval(
      child: SizedBox(width: size, height: size, child: child),
    );
  }

  Widget _fallback(BuildContext context) {
    final letter = initialOf(name);
    final shown = letter.isNotEmpty ? letter : (fallbackInitial ?? '');
    final bg = background ?? AppColors.primaryTint;
    final fg = foreground ?? AppColors.primary;
    if (shown.isEmpty) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: bg,
        child: Icon(fallbackIcon, color: fg, size: size * 0.5),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: bg,
      child: Text(
        shown,
        style: (textStyle ?? AppTextStyles.h1)
            .copyWith(color: fg, fontSize: size * 0.42),
      ),
    );
  }
}
