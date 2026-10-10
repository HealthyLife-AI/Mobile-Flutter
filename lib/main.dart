import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  runApp(
    // `enabled: kDebugMode` keeps the preview frame, toolbar and its device
    // bezel out of release/profile builds — `DevicePreview` falls straight
    // through to `builder`, so the shipped app is the untouched widget tree.
    DevicePreview(
      enabled: kDebugMode,
      // Curated rather than the full `Devices.all` list: the sizes this app
      // actually has to survive, tightest-first.
      devices: [
        Devices.ios.iPhoneSE, // smallest realistic target - catches overflow
        Devices.ios.iPhone13, // default
        Devices.ios.iPhone16ProMax, // largest common phone
        Devices.android.googlePixel9, // Android reference
        Devices.android.samsungGalaxyS25, // non-Google Android
        Devices.ios.iPad, // tablet - the 5-tab shell is width-sensitive
        Devices.macOS.macBookPro, // desktop, since macos/ is a target here
      ],
      defaultDevice: Devices.ios.iPhone13,
      // Arabic is the product language and English is the toggle already
      // offered on the Profile screen, so those are the two the preview
      // should let us switch between.
      availableLocales: const [Locale('ar'), Locale('en')],
      builder: (context) => const HealthyLifeApp(),
    ),
  );
}

class HealthyLifeApp extends StatelessWidget {
  const HealthyLifeApp({super.key, this.home = const SplashScreen()});

  /// Overridable so tests can mount the app without SplashScreen's
  /// deliberately-never-settling particle animation and status timer.
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthyLife AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // No `useInheritedMediaQuery` here: it is deprecated and inert as of
      // Flutter 3.7 (the View widget owns MediaQuery), and device_preview
      // 1.3.1's `isWidgetsAppUsingInheritedMediaQuery` assert passes anyway
      // because the builder hands it this StatelessWidget, not a bare
      // MaterialApp. Verified: the app reads 390x844 from the iPhone 13
      // frame regardless of the flag's value.
      locale: DevicePreview.locale(context),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => DevicePreview.appBuilder(
        context,
        // ORDER MATTERS. `DevicePreview.appBuilder` wraps whatever it is given
        // in its own `Directionality(TextDirection.ltr)` — that frame hosts the
        // preview toolbar, which genuinely needs LTR. Putting the RTL wrapper
        // INSIDE it (rather than around it) keeps the chrome LTR while the app
        // subtree stays RTL. With the old ordering the preview's LTR won and
        // every Arabic paragraph rendered left-aligned.
        Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox.shrink()),
      ),
      home: home,
    );
  }
}
