import 'package:flutter/material.dart';

import '../../core/config/app_version.dart';

/// Shows a line built from the installed app version, and nothing until the
/// version is known. [builder] gets the label, such as `1.0.0 (3)`.
class AppVersionText extends StatelessWidget {
  const AppVersionText({
    super.key,
    required this.builder,
    this.style,
    this.textAlign,
    this.future,
  });

  final String Function(String version) builder;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// The version to show. The installed one unless a test passes its own.
  final Future<String?>? future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: future ?? AppVersion.label(),
      builder: (context, snapshot) {
        final version = snapshot.data;
        if (version == null) return const SizedBox.shrink();
        return Text(
          builder(version),
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
      },
    );
  }
}
