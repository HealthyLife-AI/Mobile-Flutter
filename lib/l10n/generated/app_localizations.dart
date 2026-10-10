import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'HealthyLife AI'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonDone.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get commonNext;

  /// No description provided for @commonLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل…'**
  String get commonLoading;

  /// No description provided for @commonEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات لعرضها بعد'**
  String get commonEmptyTitle;

  /// No description provided for @commonEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر المعلومات هنا فور توفرها.'**
  String get commonEmptyBody;

  /// No description provided for @commonErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get commonErrorTitle;

  /// No description provided for @commonErrorBody.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل البيانات. حاول مرة أخرى.'**
  String get commonErrorBody;

  /// No description provided for @commonOfflineTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get commonOfflineTitle;

  /// No description provided for @commonOfflineBody.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من اتصالك بالشبكة ثم أعد المحاولة.'**
  String get commonOfflineBody;

  /// No description provided for @commonSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم بنجاح'**
  String get commonSuccess;

  /// No description provided for @failureNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالخادم. تحقّق من شبكة الإنترنت وحاول مجدداً.'**
  String get failureNetwork;

  /// No description provided for @failureTimeout.
  ///
  /// In ar, this message translates to:
  /// **'استغرق الاتصال وقتاً طويلاً. حاول مرة أخرى.'**
  String get failureTimeout;

  /// No description provided for @failureServer.
  ///
  /// In ar, this message translates to:
  /// **'خدمة غير متاحة حالياً. حاول لاحقاً.'**
  String get failureServer;

  /// No description provided for @failureUnauthorized.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية الجلسة. سجّل الدخول مجدداً.'**
  String get failureUnauthorized;

  /// No description provided for @failureNotFound.
  ///
  /// In ar, this message translates to:
  /// **'العنصر المطلوب غير موجود.'**
  String get failureNotFound;

  /// No description provided for @failureValidation.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من البيانات المدخلة وأعد المحاولة.'**
  String get failureValidation;

  /// No description provided for @failureCache.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر قراءة البيانات المحفوظة محلياً.'**
  String get failureCache;

  /// No description provided for @failureUnexpected.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. حاول مرة أخرى.'**
  String get failureUnexpected;

  /// No description provided for @validationRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريداً إلكترونياً صحيحاً'**
  String get validationInvalidEmail;

  /// No description provided for @validationTooShort.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا يقل عن {min} أحرف'**
  String validationTooShort(int min);

  /// No description provided for @validationTooLong.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا يتجاوز {max} حرفاً'**
  String validationTooLong(int max);

  /// No description provided for @validationMissingUppercase.
  ///
  /// In ar, this message translates to:
  /// **'أضف حرفاً كبيراً واحداً على الأقل'**
  String get validationMissingUppercase;

  /// No description provided for @validationMissingDigit.
  ///
  /// In ar, this message translates to:
  /// **'أضف رقماً واحداً على الأقل'**
  String get validationMissingDigit;

  /// No description provided for @validationMissingSpecial.
  ///
  /// In ar, this message translates to:
  /// **'أضف رمزاً خاصاً واحداً على الأقل'**
  String get validationMissingSpecial;

  /// No description provided for @validationMismatch.
  ///
  /// In ar, this message translates to:
  /// **'القيمتان غير متطابقتين'**
  String get validationMismatch;

  /// No description provided for @validationInvalidNumber.
  ///
  /// In ar, this message translates to:
  /// **'أرقاماً صحيحة فقط'**
  String get validationInvalidNumber;

  /// No description provided for @validationOutOfRange.
  ///
  /// In ar, this message translates to:
  /// **'القيمة يجب أن تكون بين {min} و {max}'**
  String validationOutOfRange(num min, num max);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
