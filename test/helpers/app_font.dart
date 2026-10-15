import 'dart:io';

import 'package:flutter/services.dart';
import 'package:healthylife_ai/core/theme/app_text_styles.dart';

/// Loads the app's font for widget tests, which otherwise fall back to the
/// Ahem test font: every glyph a full em wide and short lines, which both
/// inflates widths and hides height overflows. The Tajawal files
/// `pubspec.yaml` bundles are loaded under the family the app asks for, so
/// the layout maths (Tajawal's tall lines included) matches the device. Segoe
/// UI stands in only if the bundled files are missing.
///
/// Returns false when no font could be loaded. Call it once, in `setUpAll`.
Future<bool> loadAppFont() async {
  try {
    final bundled = [
      for (final face in const ['Regular', 'Medium', 'Bold', 'ExtraBold'])
        'assets/fonts/Tajawal-$face.ttf',
    ];
    final useBundled = bundled.every((path) => File(path).existsSync());
    final regular = File(r'C:\Windows\Fonts\segoeui.ttf');
    if (!useBundled && !regular.existsSync()) return false;
    final loader = FontLoader(AppTextStyles.fontFamily);
    for (final path in useBundled
        ? bundled
        : [r'C:\Windows\Fonts\segoeui.ttf', r'C:\Windows\Fonts\segoeuib.ttf']) {
      final file = File(path);
      if (!file.existsSync()) continue;
      loader.addFont(
        file
            .readAsBytes()
            .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)),
      );
    }
    await loader.load();
    return true;
  } catch (_) {
    return false;
  }
}
