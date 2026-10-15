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

  /// UI text in core/navigation/logout_flow.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج من الحساب'**
  String get logoutConfirmTitle;

  /// UI text in core/navigation/logout_flow.dart
  ///
  /// In ar, this message translates to:
  /// **'سيتم إنهاء الجلسة بأمان من هذا الجهاز بعد التأكد من مزامنة قياساتك وسجلاتك الأخيرة.'**
  String get logoutConfirmMessage;

  /// UI text in core/navigation/logout_flow.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get commonLogout;

  /// UI text in presentation/app_shell.dart
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// UI text in presentation/app_shell.dart
  ///
  /// In ar, this message translates to:
  /// **'الخطة'**
  String get navPlan;

  /// UI text in presentation/app_shell.dart
  ///
  /// In ar, this message translates to:
  /// **'التقدم'**
  String get navProgress;

  /// UI text in presentation/app_shell.dart
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// UI text in presentation/app_shell.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل وجبة جديدة'**
  String get navLogMealTooltip;

  /// UI text in presentation/notification_category_labels.dart
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get notificationCategoryAll;

  /// UI text in presentation/notification_category_labels.dart
  ///
  /// In ar, this message translates to:
  /// **'الوجبات'**
  String get notificationCategoryMeals;

  /// UI text in presentation/notification_category_labels.dart
  ///
  /// In ar, this message translates to:
  /// **'القياسات'**
  String get notificationCategoryMeasurements;

  /// UI text in presentation/notification_category_labels.dart
  ///
  /// In ar, this message translates to:
  /// **'تحديثات الخطة'**
  String get notificationCategoryPlanUpdates;

  /// Inbox filter chip for category nutritionist (API guide 10.2).
  ///
  /// In ar, this message translates to:
  /// **'الأخصائي'**
  String get notificationCategoryNutritionist;

  /// UI text in presentation/notification_category_labels.dart
  ///
  /// In ar, this message translates to:
  /// **'الأخرى'**
  String get notificationCategoryOther;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get aboutTitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الشفافية والمعايير الطبية'**
  String get aboutTransparencyTitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لوائح معتمدة'**
  String get aboutCertifiedRegulations;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'منطقة الجلسة والحساب'**
  String get aboutSessionAccountTitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'HealthyLife Clinical Suite © 2026 • جميع الحقوق محفوظة'**
  String get aboutCopyright;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حياة صحية'**
  String get aboutBrandName;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'منصة المتابعة والتغذية العلاجية للمرضى'**
  String get aboutTagline;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الإصدار 1.0.0 (Build 240)'**
  String get aboutVersion;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تطبيق معتمد ومصمم لدعمك بالتعاون المباشر مع أخصائيك المعتمدة لتحقيق أهدافك الصحية المستدامة.'**
  String get aboutDescription;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية وأمان البيانات الصحية'**
  String get aboutPrivacyPolicyTitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تشفير سريري عالي المستوى لملفك الغذائي'**
  String get aboutPrivacyPolicySubtitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام الطبية'**
  String get aboutMedicalTermsTitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إرشادات متابعة خطط الرعاية الصحية'**
  String get aboutMedicalTermsSubtitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تراخيص الهيئة الطبية والاعتماد'**
  String get aboutLicensesTitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجل الامتثال الطبي الموثق رقم #A-8841'**
  String get aboutLicensesSubtitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني ومساعدة التطبيق'**
  String get aboutSupportTitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مساعدة متواصلة للاستفسارات التقنية'**
  String get aboutSupportSubtitle;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حماية صحية قياسية'**
  String get aboutStandardHealthProtection;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بياناتك مشفرة ومحمية وفق معايير الخصوصية الصحية المعتمدة لمزامنة آمنة مع ملفك السريري.'**
  String get aboutEncryptionNote;

  /// UI text in presentation/screens/about_app_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سيتم إنهاء جلستك بأمان، مع الاحتفاظ بجميع سجلاتك وقياساتك في السجلات الطبية دون أي فقدان للبيانات.'**
  String get aboutLogoutNote;

  /// UI text in presentation/screens/achievements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أسبوع كامل من الالتزام'**
  String get achievementsFullWeek;

  /// UI text in presentation/screens/achievements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'7 أيام تسجيل متواصل'**
  String get achievementsSevenDayStreak;

  /// UI text in presentation/screens/achievements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أول وجبة مسجّلة'**
  String get achievementsFirstMeal;

  /// UI text in presentation/screens/achievements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'شرب الماء بانتظام'**
  String get achievementsHydration;

  /// UI text in presentation/screens/achievements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'30 يوم التزام'**
  String get achievementsThirtyDays;

  /// UI text in presentation/screens/achievements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'هدف الوزن الأول'**
  String get achievementsFirstWeightGoal;

  /// UI text in presentation/screens/achievements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إنجازاتك'**
  String get achievementsTitle;

  /// UI text in presentation/screens/achievements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'استمري، كل خطوة صغيرة تُحسب'**
  String get achievementsEncouragement;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في HealthyLife'**
  String get activationWelcome;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فعّلي وصولك الفوري إلى برنامج الرعاية السريرية'**
  String get activationSubtitle;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'معتمدة'**
  String get activationCertified;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أخصائي التغذية العلاجية وإدارة الأيض'**
  String get activationSpecialistRole;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تمت دعوتك بواسطة أخصائي التغذية لربط ملفك الصحي وبدء خطتك الغذائية العلاجية المخصصة مباشرة.'**
  String get activationInvitedBy;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم إدخال بياناتك الأساسية مسبقاً من قبل العيادة'**
  String get activationPrefilledNote;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get activationNewPassword;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get activationConfirmPassword;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'8 أحرف أو أكثر'**
  String get passwordRuleMinLength;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حرف كبير واحد على الأقل (A-Z)'**
  String get passwordRuleUppercase;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'رقم واحد على الأقل (0-9)'**
  String get passwordRuleDigit;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الحساب وبدء الخطة'**
  String get activationCta;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بياناتك الصحية مشفرة ومحمية وفق لوائح الامتثال الطبي'**
  String get activationEncryptedNote;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'رابط ساري وعامل'**
  String get activationLinkValid;

  /// UI text in presentation/screens/activation_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'رابط منتهٍ / مُستخدم'**
  String get activationLinkExpired;

  /// UI text in presentation/screens/barcode_scanner_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'امسح باركود المنتج'**
  String get barcodeTitle;

  /// UI text in presentation/screens/barcode_scanner_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم العثور على المنتج ✓'**
  String get barcodeFound;

  /// UI text in presentation/screens/barcode_scanner_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'وجّه الكاميرا نحو الباركود — اضغط للمحاكاة'**
  String get barcodeHint;

  /// BeetAI first message. known: yes when the patient's name is known.
  ///
  /// In ar, this message translates to:
  /// **'{known, select, yes{أهلاً {name}! أنا BeetAI، اسألني عن أي شيء يخص خطتك الغذائية أو سجّل وجبة بسرعة 🌿} other{أهلاً! أنا BeetAI، اسألني عن أي شيء يخص خطتك الغذائية أو سجّل وجبة بسرعة 🌿}}'**
  String beetaiWelcome(String known, String name);

  /// UI text in presentation/screens/beetai_chat_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل ذلك في سجلك، هل تودين إضافة أي تفاصيل أخرى؟'**
  String get beetaiLoggedReply;

  /// UI text in presentation/screens/beetai_chat_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مساعدك الذكي'**
  String get beetaiSubtitle;

  /// UI text in presentation/screens/beetai_chat_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إدخال صوتي'**
  String get beetaiVoiceInput;

  /// UI text in presentation/screens/beetai_chat_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اسأل BeetAI أو سجّل وجبة…'**
  String get beetaiInputHint;

  /// UI text in presentation/screens/beetai_chat_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'رسالة صوتية'**
  String get beetaiVoiceMessage;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الوجبة من سجل اليوم'**
  String get dailyLogMealDeleted;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get commonUndo;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجل اليوم'**
  String get dailyLogTitle;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get commonNotifications;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'استعراض الخطة الأسبوعية'**
  String get dailyLogWeeklyPlanTooltip;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اليوم النشط'**
  String get dailyLogActiveDay;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الأحد، 21 سبتمبر 2025'**
  String get demoDateSunday21Sep2025;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الوجبات المسجلة'**
  String get dailyLogLoggedMeals;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مجموع الطاقة المستهلكة'**
  String get dailyLogTotalEnergy;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{value} سعرة'**
  String commonKcalValue(Object value);

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تجاوزت الهدف بـ {value} سعرة'**
  String dailyLogOverGoal(Object value);

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'توازن الطاقة اليومي المتزن'**
  String get dailyLogBalancedEnergy;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪ من الموصى به'**
  String dailyLogPercentOfRecommended(Object percent);

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا بأس، الأرقام مرشد هادئ وليست حكماً، وغداً يوم جديد.'**
  String get dailyLogOverGoalReassurance;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خياراتك اليوم متنوعة ومغذية، تذكّر أن الأرقام مرشد هادئ لدعم نشاطك وصحتك.'**
  String get dailyLogVariedChoices;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'التسلسل الزمني'**
  String get dailyLogTimeline;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'معاينة السجل الفارغ'**
  String get dailyLogPreviewEmpty;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خارج الخطة • إضافة حرة'**
  String get dailyLogOffPlanFree;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'من الخطة الغذائية'**
  String get dailyLogFromPlan;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{value} غرام'**
  String commonGramsValue(Object value);

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حذف الوجبة'**
  String get dailyLogDeleteMeal;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تذكير أخصائي التغذية'**
  String get dailyLogDietitianReminder;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المرونة جزء أساسي من النجاح المستدام. تدوينك اليومي بصدق هو الخطوة الأهم لدعم رعايتك الذاتية.'**
  String get dailyLogFlexibilityNote;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لم تُسجّل أي وجبة بعد'**
  String get dailyLogNoMealsYet;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorStateTitle;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قيد الفحص السريع'**
  String get errorStateQuickCheck;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حالة خوادم HealthyLife'**
  String get errorStateServerStatus;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get errorStateUnexpected;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عذراً، لم نتمكن من مزامنة هذه الصفحة في الوقت الراهن. خذ نفساً هادئاً، ونرجو منك المحاولة مرة أخرى.'**
  String get errorStateMessage;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بياناتك الصحية بأمان تام'**
  String get errorStateDataSafeTitle;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجلات الوجبات، تتبع السعرات، وتاريخك الحيوي لم تتأثر إطلاقاً ومحفوظة سحابياً بنجاح.'**
  String get errorStateDataSafeBody;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إرشادات سريعة للحل'**
  String get errorStateTipsTitle;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يُرجى التحقق من اتصال شبكة الإنترنت أو تكرار الطلب بعد بضع ثوانٍ ليستجيب النظام.'**
  String get errorStateTipsBody;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة الآن'**
  String get errorStateRetryNow;

  /// UI text in presentation/screens/error_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get commonBackToHome;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'دليل القياسات'**
  String get measurementGuideTitle;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّل قياسك التالي لنرسم لك خط التقدم'**
  String get firstMeasurementHeadline;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يتطلب رسم منحنى التقدم قياسين على الأقل لإظهار اتجاه التغير الحقيقي بدقة وموضوعية. تسجيلك القادم سيفعّل المخطط البياني فوراً.'**
  String get firstMeasurementExplanation;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّل قياساً جديداً'**
  String get firstMeasurementLogNew;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى خطتي اليومية'**
  String get firstMeasurementBackToPlan;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نقطة البداية المعتمدة'**
  String get firstMeasurementBaseline;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'القياس الأولي المسجل'**
  String get firstMeasurementInitial;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{value} كغ'**
  String commonKgValue(Object value);

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الجمعة، ١٩ سبتمبر ٢٠٢٥'**
  String get demoDateFriday19Sep2025;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم توثيق نقطة البداية بنجاح في ملفك الصحي.'**
  String get firstMeasurementBaselineSaved;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قياس واحد يحدد نقطة انطلاقك، والقياس القادم هو ما يرسم رحلتك مع أخصائي التغذية خطوة بخطوة.'**
  String get firstMeasurementJourneyNote;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'توقيت القياس المقترح'**
  String get firstMeasurementSuggestedTime;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'صباحاً بعد الاستيقاظ مباشرة لقراءة مستقرة'**
  String get firstMeasurementMorningTip;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'دليل القياس المصوّر 📐'**
  String get firstMeasurementIllustratedGuide;

  /// UI text in presentation/screens/first_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بانتظار القياس الثاني'**
  String get firstMeasurementAwaitingSecond;

  /// Progress tab before any reading exists: headline asking for the first measurement.
  ///
  /// In ar, this message translates to:
  /// **'سجّل قياسك الأول لنحدد نقطة انطلاقك'**
  String get measurementPromptFirstHeadline;

  /// Progress tab before any reading exists: explanation under the headline.
  ///
  /// In ar, this message translates to:
  /// **'قياسك الأول هو نقطة البداية، وبعده يكفي قياس واحد كل أسبوع لنرسم منحنى تقدّمك.'**
  String get measurementPromptFirstBody;

  /// Pill on the illustration before any reading exists.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار القياس الأول'**
  String get measurementPromptAwaitingFirst;

  /// Badge on the latest-reading card when the weekly measurement is due (API guide 10.6).
  ///
  /// In ar, this message translates to:
  /// **'موعد القياس الأسبوعي'**
  String get measurementPromptWeeklyBadge;

  /// Title of the card showing the patient's latest reading when the weekly measurement is due.
  ///
  /// In ar, this message translates to:
  /// **'آخر قياس مسجل'**
  String get measurementPromptLatest;

  /// Line under the latest reading when a week has passed since it.
  ///
  /// In ar, this message translates to:
  /// **'مرّ أسبوع على هذا القياس، وحان وقت القياس التالي.'**
  String get measurementPromptWeeklyNote;

  /// Progress tab headline when the weekly measurement is due.
  ///
  /// In ar, this message translates to:
  /// **'حان موعد قياسك الأسبوعي'**
  String get measurementPromptWeeklyHeadline;

  /// Progress tab explanation when the weekly measurement is due.
  ///
  /// In ar, this message translates to:
  /// **'قياس واحد كل أسبوع يُبقي منحنى تقدّمك دقيقاً ومحدّثاً.'**
  String get measurementPromptWeeklyBody;

  /// Pill on the illustration when the weekly measurement is due.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار القياس الجديد'**
  String get measurementPromptAwaitingNew;

  /// Text button on the measurement prompt that opens the progress dashboard without measuring now.
  ///
  /// In ar, this message translates to:
  /// **'عرض تقدّمي الآن'**
  String get measurementPromptViewProgress;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بنجاح'**
  String get followUpSuccessfully;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حالة المتابعة'**
  String get followUpStatus;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'12 أسبوع'**
  String get followUpTwelveWeeks;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'القياسات المسجلة'**
  String get followUpMeasurementsLogged;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الالتزام بالوجبات'**
  String get followUpMealAdherence;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'انتهت المتابعة'**
  String get followUpEndedTitle;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اكتمال خطة المتابعة السريرية'**
  String get followUpPlanCompleted;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'انتهت فترة متابعتك الحالية'**
  String get followUpPeriodEnded;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نتمنى أنك استمتعت بخطتك الصحية وحققت أهدافك! لقد انتهت فترة المتابعة الحالية مع أخصائي التغذية. للتجديد أو لاستكمال رحلتك العلاجية والحصول على خطة جديدة، يمكنك التواصل مباشرة وبكل سهولة.'**
  String get followUpEndedMessage;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مشرفك'**
  String get followUpSupervisor;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أخصائي التغذية العلاجية المشرف عليك'**
  String get followUpSupervisingSpecialist;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجلاتك وقياساتك السابقة محفوظة بأمان تام في ملفك الصحي، ويمكن استئناف الخطة والمتابعة فوراً بمجرد التجديد.'**
  String get followUpRecordsSafe;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع أخصائي التغذية عبر واتساب'**
  String get followUpContactWhatsApp;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'استعراض ملخص التقرير النهائي للمتابعة'**
  String get followUpViewFinalReport;

  /// UI text in presentation/screens/follow_up_ended_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة وسياسة الخصوصية للملفات الطبية'**
  String get followUpTerms;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فواكه وخضار'**
  String get foodSearchFilterFruitVeg;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نشويات وحبوب'**
  String get foodSearchFilterCarbsGrains;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بروتينات'**
  String get foodSearchFilterProteins;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أكلت شيئاً خارج الخطة'**
  String get foodSearchAteOffPlan;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا داعي للقلق، نحن معك'**
  String get foodSearchNoWorries;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'متابعة آمنة'**
  String get foodSearchSafeFollowUp;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل كل ما تناولته بصدق يمكّن أخصائي التغذية من المتابعة الدقيقة وضبط خطتك بسلاسة دون حرمان.'**
  String get foodSearchHonestLogging;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم العربي أو الإنجليزي'**
  String get foodSearchHint;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get foodSearchClear;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مسح الباركود'**
  String get foodSearchScanBarcode;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الأطعمة المقترحة'**
  String get foodSearchSuggested;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لكل {amount} غ'**
  String foodSearchPer100g(Object amount);

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أطعمة في هذا التصنيف'**
  String get foodSearchEmptyCategory;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا نتائج مطابقة لـ \"{query}\"'**
  String foodSearchNoResults(Object query);

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'جرّبي كلمة أخرى أو اطلبي إضافة الصنف من الأسفل'**
  String get foodSearchTryAnother;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لم تجد ما تبحث عنه؟'**
  String get foodSearchNotFound;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الحساسية متوقفة الآن: تعذّرت قراءة ملفك الصحي.'**
  String get foodAllergyCheckUnavailable;

  /// Food search help card. gender: male | female | other | unknown (profile not loaded).
  ///
  /// In ar, this message translates to:
  /// **'{gender, select, male{أخصائيك {name} بانتظارك} female{أخصائيتك {name} بانتظارك} unknown{أخصائي التغذية بانتظارك} other{{name} بانتظارك}}'**
  String foodSearchSpecialistWaiting(String gender, String name);

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إرسال اسم الصنف أو صورته لأخصائي التغذية ليضيفه إلى قاعدة بياناتك فوراً، أو ليقدّر مكوناته الأساسية دون انقطاع عن أهدافك.'**
  String get foodSearchSendItemNote;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'طلب إضافة صنف جديد عبر واتساب'**
  String get foodSearchRequestViaWhatsApp;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تقدير السعرات يدوياً (سريع)'**
  String get foodSearchManualEstimate;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تقدير يدوي'**
  String get foodSearchManualEstimateName;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'طلب إضافة صنف جديد'**
  String get foodSearchRequestNewItem;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أرسل اسم الصنف أو صورته لأخصائي التغذية عبر واتساب، وستتم إضافته إلى قاعدة بياناتك بأسرع وقت ممكن.'**
  String get foodSearchWhatsAppSheetBody;

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فتح واتساب'**
  String get commonOpenWhatsApp;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كيف تُحفظ بياناتك الصحية؟'**
  String get consentClauseStorageTitle;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تشفير كامل وفق أعلى معايير الخصوصية الصحية السريرية (HIPAA standards). تُخزَّن السجلات على خوادم طبية معزولة لا يمكن لأي طرف ثالث أو شركة إعلانات الوصول إليها تحت أي ظرف.'**
  String get consentClauseStorageBody;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'من يمكنه الاطلاع عليها؟'**
  String get consentClauseAccessTitle;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أخصائي التغذية العلاجية المعتمد على حسابك فقط، عبر نظام مراجعة سريري مشفر. لا تُشارك بياناتك مع أي جهة أخرى، ولا تُستخدم لأي غرض تسويقي.'**
  String get consentClauseAccessBody;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حقك الكامل في إلغاء الموافقة'**
  String get consentClauseRevokeTitle;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يمكنك سحب موافقتك في أي وقت من الحساب ← الخصوصية. سيؤدي ذلك إلى إيقاف تخصيص الخطة الغذائية تلقائياً حتى تجديد الموافقة، دون التأثير على سجلاتك المحفوظة.'**
  String get consentClauseRevokeBody;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الخروج من إعداد ملفك الصحي؟'**
  String get consentExitTitle;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لن تتمكني من متابعة رحلتك العلاجية أو الوصول لخطتك الغذائية قبل الموافقة على شروط الخصوصية الصحية.'**
  String get consentExitMessage;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الخروج الآن'**
  String get consentExitConfirm;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'متابعة الموافقة'**
  String get consentExitCancel;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بنود الخصوصية ومسؤولية الحفظ'**
  String get consentClausesHeader;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{count} بنود رئيسية'**
  String consentClausesCount(Object count);

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قراءة وثيقة الخصوصية السريرية الكاملة'**
  String get consentReadFullDocument;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'موثّق'**
  String get consentVerified;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'متابعة إعداد خطتي الصحية'**
  String get consentCta;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يُرجى الموافقة على الشروط السريرية للمتابعة'**
  String get consentPleaseAgree;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ميثاق الخصوصية التغذوية'**
  String get consentCharterTitle;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'موثّق سري'**
  String get consentConfidentialVerified;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بياناتك (سجل الوجبات، القياسات، والحالة الصحية) تصل لأخصائي التغذية المتابع لك فقط وتُستخدم لبناء خطتك الغذائية ومتابعة تقدمك السريري بأمان.'**
  String get consentDataUseNote;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مشفّرة بنظام bit-256 ومتوافقة مع المعايير الصحية السريرية (HIPAA).'**
  String get consentEncryptionShort;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الموافقة على استخدام البيانات الصحية'**
  String get consentTitle;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'منظومة الحماية السريرية الذكية'**
  String get consentProtectionSystem;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قبل أن نبدأ رحلتك الصحية'**
  String get consentBeforeWeStart;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نحن نلتزم بحماية خصوصية بياناتك الصحية والسريرية بأقصى درجات الشفافية والأمان.'**
  String get consentCommitment;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بياناتك الطبية مشفرة بنظام bit AES-256 من لحظة إدخالها'**
  String get consentAesNote;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قرأت ووافقت على شروط مشاركة البيانات بسياسة الخصوصية الصحية.'**
  String get consentCheckbox;

  /// UI text in presentation/screens/health_data_consent_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'موافقتك قابلة للتعديل أو الإلغاء فوراً في أي وقت.'**
  String get consentRevocable;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'السجل الطبي'**
  String get healthRecordTitle;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الحساسية والموانع'**
  String get healthRecordAllergies;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الأوسمة وسجل الإنجازات'**
  String get healthRecordBadges;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'3 أوسمة مفتوحة'**
  String get healthRecordBadgesUnlocked;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الهدف الأول'**
  String get healthRecordBadgeFirstGoal;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل أول قياس وزني بنجاح'**
  String get healthRecordBadgeFirstGoalDesc;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'التزام حديدي'**
  String get healthRecordBadgeIronCommitment;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'7 أيام متواصلة من التوثيق'**
  String get healthRecordBadgeIronCommitmentDesc;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'صديق الماء'**
  String get healthRecordBadgeWaterFriend;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'شرب 2.5 لتر لـ 5 أيام متتالية'**
  String get healthRecordBadgeWaterFriendDesc;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خسارة 5 كجم'**
  String get healthRecordBadgeLose5kg;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'باقي 1.2 كجم للفتح'**
  String get healthRecordBadgeLose5kgDesc;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الملخص والإنجازات مع الأخصائي'**
  String get healthRecordShareSummary;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نشط الآن'**
  String get healthRecordActiveNow;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'26 سنة • كود الملف: '**
  String get healthRecordAgeFileCode;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المستوى 3: بطل الالتزام'**
  String get healthRecordLevel;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أداء ممتاز خلال الأسبوع الحالي'**
  String get healthRecordExcellentWeek;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{points} / 1000 ن'**
  String healthRecordPoints(Object points);

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'باقي 250 نقطة للوصول للمستوى الرابع'**
  String get healthRecordPointsToNext;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{percent}% مكتمل'**
  String healthRecordPercentComplete(Object percent);

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الهدف الصحي الاستراتيجي الحالي'**
  String get healthRecordCurrentGoal;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الأدوية والمكملات اليومية المعتمدة'**
  String get healthRecordMedications;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get healthRecordActive;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get commonViewDetails;

  /// Snackbar when the server refuses a reading saved offline (API guide 14.2)
  ///
  /// In ar, this message translates to:
  /// **'لم يقبل الخادم قياساً سجّلته دون اتصال، ولم يُحفظ.'**
  String get offlineWriteDropped;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'السجل الطبي المعتمد'**
  String get healthRecordCertified;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'التشخيصات والمحاذير لتخصيص خطتك بدقة'**
  String get healthRecordDiagnosesNote;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل أو إضافة تقرير إلى السجل الطبي'**
  String get healthRecordRequestChange;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{days} يوماً متتالياً من الالتزام التام!'**
  String healthRecordStreakDays(Object days);

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الوجبات والنشاط الحركي اليومي بدقة، حافظ على شعلة الحماس!'**
  String get healthRecordStreakNote;

  /// UI text in presentation/screens/health_record_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم الإنجاز'**
  String get healthRecordDone;

  /// UI text in presentation/screens/health_sync_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ربط تطبيق الصحة'**
  String get healthSyncTitle;

  /// UI text in presentation/screens/health_sync_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم الربط بنجاح'**
  String get healthSyncConnected;

  /// UI text in presentation/screens/health_sync_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اربطي تطبيق الصحة'**
  String get healthSyncConnectPrompt;

  /// UI text in presentation/screens/health_sync_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ربط Apple Health أو Google Fit يتيح لأخصائي التغذية متابعة نشاطك ومعدل ضربات قلبك تلقائياً دون إدخال يدوي، ويحسّن دقة خطتك الغذائية.'**
  String get healthSyncBody;

  /// UI text in presentation/screens/health_sync_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ربط الآن'**
  String get healthSyncConnectNow;

  /// UI text in presentation/screens/health_sync_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'العودة للتقدّم'**
  String get healthSyncBackToProgress;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الفطور'**
  String get homeMealBreakfast;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'08:00 صباحاً'**
  String get homeBreakfastTime;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'البديل المقترح: 100g جبنة قريش'**
  String get homeBreakfastAlternative;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'2 بيضة مسلوقة'**
  String get homeItemTwoBoiledEggs;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'1 رغيف خبز شوفان'**
  String get homeItemOatBread;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خيار وطماطم كرزية'**
  String get homeItemCucumberTomatoes;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'طازج'**
  String get homeItemFresh;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الغداء'**
  String get homeMealLunch;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'02:30 ظهراً'**
  String get homeLunchTime;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'صدر دجاج مشوي'**
  String get homeItemGrilledChicken;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أرز أسمر مطبوخ على البخار'**
  String get homeItemBrownRice;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سلطة خضراء مع متبلة زيت زيتون'**
  String get homeItemGreenSalad;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'طبق كبير'**
  String get homeItemLargePlate;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'العشاء - 08:00 مساءً'**
  String get homeDinnerTitle;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خفيف وخالٍ - 320 سعرة حرارية تقريباً'**
  String get homeDinnerSubtitle;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'زبادي يوناني'**
  String get homeItemGreekYogurt;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خضار سوتيه'**
  String get homeItemSauteedVeg;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خبز توست أسمر'**
  String get homeItemBrownToast;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سناك المساء'**
  String get homeEveningSnack;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فاكهة موسمية (120g)'**
  String get homeEveningSnackSubtitle;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تمت مزامنة {count} عنصر بنجاح'**
  String homeSyncedItems(Object count);

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أنت متصل الآن'**
  String get homeOnlineNow;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اضغط للمزامنة والعودة للاتصال'**
  String get homeTapToSync;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'متصل — اضغط لمعاينة وضع عدم الاتصال'**
  String get homeOnlineTapPreview;

  /// Home greeting. known: yes when the patient's name is known.
  ///
  /// In ar, this message translates to:
  /// **'{known, select, yes{مرحباً {name} 👋} other{مرحباً 👋}}'**
  String homeGreeting(String known, String name);

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الالتزام اليوم'**
  String get homeAdherenceToday;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المسار اليومي للوجبات'**
  String get homeDailyMealPath;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{logged} من {total} وجبات مسجلة'**
  String homeMealsLogged(Object logged, Object total);

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'جدول الوجبات'**
  String get homeMealSchedule;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{value} سعرة مستهدفة'**
  String homeTargetKcal(Object value);

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المزامنة'**
  String get homeAwaitingSync;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بانتظار التسجيل'**
  String get homeAwaitingLog;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم التسجيل'**
  String get homeLogged;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بديل متاح'**
  String get homeAlternativeAvailable;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{value} سعرة حرارية'**
  String commonCaloriesValue(Object value);

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مكتمل في الموعد'**
  String get homeCompletedOnTime;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الوجبة'**
  String get homeLogMeal;

  /// UI text in presentation/screens/home_dashboard_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'شرب كوبين من الماء قبل كل وجبة يدعم الحرق المنتظم ويساعدك على الشعور بالشبع الهادئ. أنت تسيرين بوتيرة ممتازة!'**
  String get homeHydrationTip;

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get languageTitle;

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حفظ اللغة المختارة'**
  String get languageSave;

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'HealthyLife Care Portal — النسخة 2.4.0'**
  String get languageFooter;

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تخصيص الواجهة'**
  String get languageCustomizeInterface;

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة التطبيق'**
  String get languageChooseTitle;

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة العرض المفضلة لمتابعة خطتك الغذائية، مواعيد الاستشارات، وسجلاتك الصحية بكل وضوح وسهولة.'**
  String get languageChooseBody;

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اللغة الحالية'**
  String get languageCurrentBadge;

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تأثير التغيير على تجربة الاستخدام'**
  String get languageEffectTitle;

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عند تغيير اللغة، سيتم تحديث اتجاه واجهة التطبيق بالكامل تلقائياً (RTL للغة العربية و LTR للغة الإنجليزية) لضمان تجربة تصفح طبيعية ومريحة.'**
  String get languageEffectBody;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل وجبة'**
  String get logMealTitle;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل ما تناولته بصدق هو خطوتك الأولى نحو نتائج مستدامة. أخصائي التغذية هنا لدعمك دائماً دون أي تقييم.'**
  String get logMealIntro;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الوجبات المعتمدة'**
  String get logMealPlannedBadge;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّلت وجبة من خطتي'**
  String get logMealFromPlanTitle;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تأكيد سريع لتناول إحدى وجباتك المجدولة في جدول اليوم (فطور، سناك، غداء، عشاء) مع إمكانية تعديل البدائل المعتمدة.'**
  String get logMealFromPlanDesc;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مطابقة تلقائية للسعرات والمكونات المجدولة'**
  String get logMealFromPlanNote;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'استبدال ذكي للبدائل المتكافئة بنقرة واحدة'**
  String get logMealFromPlanNote2;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المتابعة لاختيار الوجبة (P-21)'**
  String get logMealFromPlanFooter;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بحث وتوثيق مرن'**
  String get logMealFlexibleBadge;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تناولت طعاماً أو وجبة خفيفة لم تكن مدرجة في جدولك؟ سجّلها بسهولة بالبحث المباشر أو تحديد الغرامات التقريبية.'**
  String get logMealOffPlanDesc;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قاعدة بيانات غنية بالأطعمة العربية والوجبات الشائعة'**
  String get logMealOffPlanNote;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا داعي للشعور بالذنب، المرونة جزء أساسي من النجاح'**
  String get logMealOffPlanNote2;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المتابعة للبحث وحساب الغرامات (P-22)'**
  String get logMealOffPlanFooter;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بياناتك الغذائية مشفرة وتُعامل بخصوصية طبية تامة'**
  String get logMealPrivacyNote;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إضاءة تشجيعية: '**
  String get logMealEncouragementLabel;

  /// UI text in presentation/screens/log_meal_intro_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'التسجيل الدقيق يساعد أخصائي التغذية على ضبط سعراتك وملاءمة الوجبات القادمة حسب استجابة جسمك الطبيعية وتفضيلاتك اليومية.'**
  String get logMealEncouragementBody;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الوجبة'**
  String get mealDetailTitle;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مكونات الوجبة والبدائل'**
  String get mealDetailIngredients;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{count} أصناف غذائية'**
  String mealDetailItemsCount(Object count);

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سيتم تحديث سجل اليوم ونسبة التزامك فوراً'**
  String get mealDetailUpdateNote;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الوجبة الحالية • {time}'**
  String mealDetailCurrentMeal(Object time);

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مرونة الاستبدال الذكي'**
  String get mealDetailSmartSwap;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اختر البديل إذا لم يتوفر الصنف الأصلي، والبديل يستبدل الصنف ولا يُضاف إليه لتحقيق التوازن التغذوي الدقيق.'**
  String get mealDetailSwapNote;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السعرات النشطة'**
  String get mealDetailTotalCalories;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سعرة حرارية'**
  String get commonCaloriesUnit;

  /// Meal detail: who approved the meal. gender: male | female | other | unknown.
  ///
  /// In ar, this message translates to:
  /// **'{gender, select, male{وجبة متوازنة معتمدة من أخصائي التغذية {name}} female{وجبة متوازنة معتمدة من أخصائية التغذية {name}} unknown{وجبة متوازنة معتمدة من أخصائي التغذية} other{وجبة متوازنة معتمدة من {name}}}'**
  String mealDetailApprovedBy(String gender, String name);

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'البروتين'**
  String get macroProtein;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الكارب'**
  String get macroCarbs;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الدهون الصحية'**
  String get macroHealthyFats;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{value} غ'**
  String commonGramsShortValue(Object value);

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'صنف أساسي بدون بديل'**
  String get mealDetailNoAlternative;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اختر صنفاً واحداً'**
  String get mealDetailChooseOne;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الصنف المجدول الأصلي'**
  String get mealDetailOriginalItem;

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يستبدل {item}'**
  String mealDetailReplaces(Object item);

  /// UI text in presentation/screens/meal_detail_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّلت هذه الوجبة الآن'**
  String get mealDetailLoggedNow;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'وجبة خارج الخطة'**
  String get mealLoggedOffPlan;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'وجبة من خطتك الغذائية'**
  String get mealLoggedFromPlan;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الوجبة بنجاح'**
  String get mealLoggedTitle;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث سجل اليوم ومستوى التزامك الغذائي بنجاح وبدقة سريرية.'**
  String get mealLoggedBody;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'وجبتك المسجلة'**
  String get mealLoggedYourMeal;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{plan}  •  {grams} غرام'**
  String mealLoggedMealLine(Object plan, Object grams);

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الانتقال فوراً لخطتي اليومية'**
  String get mealLoggedGoToPlan;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل وجبة أخرى'**
  String get mealLoggedLogAnother;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تحديث فوري'**
  String get mealLoggedInstantUpdate;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الالتزام بالوجبات اليومية'**
  String get mealLoggedDailyAdherence;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّلت {logged} من {planned} ({percent}٪)'**
  String mealLoggedSummary(Object logged, Object planned, Object percent);

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كربوهيدرات'**
  String get macroCarbohydrates;

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'جارٍ نقلك تلقائياً لخطتي اليومية...'**
  String get mealLoggedRedirecting;

  /// UI text in presentation/screens/measurement_guide_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'هل تحتاج مساعدة إضافية؟ تواصل مع أخصائي التغذية عبر المحادثة'**
  String get guideNeedHelp;

  /// UI text in presentation/screens/measurement_guide_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إرشادات أخذ القياسات بدقة'**
  String get guideHeadline;

  /// UI text in presentation/screens/measurement_guide_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الرسوم التوضيحية التالية توضح بدقة المكان الصحيح لوضع شريط القياس لضمان الحصول على قراءات دقيقة ومتسقة تساعد أخصائي التغذية.'**
  String get guideIntro;

  /// UI text in presentation/screens/measurement_guide_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نصائح عامة: قف باسترخاء، تنفس طبيعياً، ولا تشد شريط القياس بقوة على الجلد'**
  String get guideGeneralTips;

  /// UI text in presentation/screens/measurement_guide_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ميزة قيد الإعداد'**
  String get guideComingFeature;

  /// UI text in presentation/screens/measurement_guide_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'🎬 قريباً: فيديو إرشادي قصير (١٠ ثوان) لكل قياس لتسهيل المتابعة العملية المباشرة.'**
  String get guideVideoComingSoon;

  /// UI text in presentation/screens/measurement_guide_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فهمت، العودة لتسجيل القياسات'**
  String get guideDoneBack;

  /// UI text in presentation/screens/measurement_guide_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تكبير الرسم'**
  String get guideZoom;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الوزن ومحيط الجسم'**
  String get measurementsTitle;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الجمعة، 19 سبتمبر 2025'**
  String get measurementsDateLabel;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الوزن الحالي'**
  String get measurementsCurrentWeight;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كغ'**
  String get commonKgUnit;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{delta} كغ مقارنة بآخر قياس'**
  String measurementsDeltaVsLast(Object delta);

  /// Clinic reading badge. gender: male | female | other | unknown.
  ///
  /// In ar, this message translates to:
  /// **'{gender, select, male{تم التحقق أثناء زيارة العيادة مع الأخصائي {name}} female{تم التحقق أثناء زيارة العيادة مع الأخصائية {name}} unknown{تم التحقق أثناء زيارة العيادة} other{تم التحقق أثناء زيارة العيادة مع {name}}}'**
  String measurementsClinicVerified(String gender, String name);

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'30 يوم'**
  String get measurementsRange30;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'90 يوم'**
  String get measurementsRange90;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قياسات بعد. ستظهر أول قياساتك هنا.'**
  String get measurementsNoReadingsYet;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قياسات في هذه الفترة.'**
  String get measurementsNoReadingsInRange;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'انسيابي ومستقر'**
  String get measurementsSmoothStable;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مسار التغيير'**
  String get measurementsTrend;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قياس العيادة (معتمد)'**
  String get measurementsClinicReading;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قياس منزلي'**
  String get measurementsHomeReading;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تحديث البيانات متزامن مع قياسات العيادة وسجلك الشخصي بكل موثوقية.'**
  String get measurementsSyncNote;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: 19 سبتمبر'**
  String get measurementsLastUpdated;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'محيط الجسم'**
  String get measurementsBodyCircumference;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خطوة مستمرة'**
  String get measurementsOngoingStep;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الالتزام بالتسجيل'**
  String get measurementsLoggingCommitment;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّلتِ {days} أيام من 7 أيام هذا الأسبوع'**
  String measurementsDaysThisWeek(Object days);

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'(إجمالي {days} يوماً مسجلاً هذا الشهر)'**
  String measurementsDaysThisMonth(Object days);

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيلك المنتظم يمكّن أخصائي التغذية من تحليل نمطك بدقة ودعمك بالخيارات الأنسب دون أي ضغط أو تسرّع.'**
  String get measurementsRegularNote;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّل قياساتك اليومية'**
  String get measurementsLogDaily;

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{value} سم'**
  String commonCmValue(Object value);

  /// UI text in presentation/screens/measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ثابت ومستقر'**
  String get measurementsSteady;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل القياس'**
  String get measurementEntryTitle;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حفظ القياسات'**
  String get measurementEntrySave;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إلغاء والعودة للتقدّم'**
  String get measurementEntryCancel;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get measurementEntryView;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'دليل القياس المصوّر'**
  String get measurementEntryGuideTitle;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خطوات بسيطة للحصول على قراءة دقيقة'**
  String get measurementEntryGuideSubtitle;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تاريخ تسجيل القياس'**
  String get measurementEntryDate;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تحديد موعد مستقبلي'**
  String get measurementEntryNoFuture;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اليوم، الأحد 21 سبتمبر 2025'**
  String get measurementEntryToday;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'توقيت التسجيل المقترح: صباحاً قبل الإفطار'**
  String get measurementEntrySuggestedTime;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get measurementEntryRequired;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يساعد قياس الوزن المنتظم صباحاً بعد الاستيقاظ على تزويد أخصائي التغذية ببيانات موثوقة تعكس تطورك الحقيقي.'**
  String get measurementEntryRegularNote;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قياسات المحيط بشريط القياس'**
  String get measurementEntryCircumferenceTitle;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get commonOptional;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّل ما يتوفر لديك فقط دون أي إلزام'**
  String get measurementEntryOptionalNote;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كيف أقيس بدقة؟'**
  String get measurementEntryHowToMeasure;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'القياسات بالسنتيمتر (سم)'**
  String get measurementEntryUnitCm;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'محيط الخصر'**
  String get measurementWaist;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عند أضيق نقطة فوق السرة'**
  String get measurementWaistHint;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'محيط الورك'**
  String get measurementHip;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عند أعرض نقطة في الحوض'**
  String get measurementHipHint;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'محيط الفخذ'**
  String get measurementThigh;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'منتصف المسافة بين الورك والركبة'**
  String get measurementThighHint;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'محيط الذراع'**
  String get measurementArm;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'منتصف العضد مع استرخاء اليد'**
  String get measurementArmHint;

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خصوصيتك الصحية أمانة'**
  String get measurementEntryPrivacyTitle;

  /// Measurement entry privacy note. gender: other | unknown.
  ///
  /// In ar, this message translates to:
  /// **'{gender, select, unknown{جميع بياناتك محمية وتصل بأمان لملفك الطبي المباشر لدى أخصائي التغذية دون أي أحكام أو تقييمات مسبقة، لتعديل خطتك بما يناسبك.} other{جميع بياناتك محمية وتصل بأمان لملفك الطبي المباشر لدى {name} دون أي أحكام أو تقييمات مسبقة، لتعديل خطتك بما يناسبك.}}'**
  String measurementEntryPrivacyBody(String gender, String name);

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'آخر قياس: {value}'**
  String measurementEntryLastValueHint(Object value);

  /// UI text in presentation/screens/new_measurement_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سم'**
  String get commonCmUnit;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ص'**
  String get timeAm;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'م'**
  String get timePm;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تخصيص التنبيهات الصحية'**
  String get notificationSettingsHeading;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تحديد الإشعارات التي ترغب في استلامها بكل دقة، لتبقى على اتصال دائم بأهدافك دون أي إزعاج.'**
  String get notificationSettingsIntro;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تذكير الوجبات'**
  String get notificationSettingsMeals;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تذكير بمواعيد وجبات خطتك اليومية وتسجيلها في وقتها المناسب.'**
  String get notificationSettingsMealsDesc;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تذكير القياسات'**
  String get notificationSettingsMeasurements;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تنبيه لطيف صباح كل أسبوع لأخذ قياس الوزن ومحيط الجسم وتحديث تقدمك.'**
  String get notificationSettingsMeasurementsDesc;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إشعار فوري عند مراجعة أخصائي التغذية لخطتك وتعديل الوجبات أو البدائل.'**
  String get notificationSettingsPlanUpdatesDesc;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'من {start} حتى {end} تلقائياً'**
  String notificationSettingsQuietRange(Object start, Object end);

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الهاتف معطلة'**
  String get notificationSettingsPhoneDisabled;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إعدادات النظام'**
  String get notificationSettingsSystemSettings;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف صلاحية الإشعارات لتطبيق HealthyLife من إعدادات جهازك. لتلقي التذكيرات ومتابعة خطتك الغذائية، يرجى تفعيلها من إعدادات النظام.'**
  String get notificationSettingsPermissionOff;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فتح إعدادات الهاتف'**
  String get notificationSettingsOpenPhoneSettings;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الهاتف غير مفعّلة'**
  String get notificationSettingsEnableTitle;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا تظهر تذكيرات الوجبات ورسائل أخصائي التغذية حتى تسمح بها. تفعيلها يستغرق لحظة ويمكنك إيقافها في أي وقت.'**
  String get notificationSettingsEnableDesc;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات الآن'**
  String get notificationSettingsEnable;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الهاتف مفعّلة'**
  String get notificationSettingsEnabledTitle;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ستصلك تذكيرات الوجبات ورسائل أخصائي التغذية ومواعيد القياس.'**
  String get notificationSettingsEnabledDesc;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'هدوء وتوازن بدون تشويش'**
  String get notificationSettingsCalm;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ننظم إشعاراتك بما يلائم روتينك اليومي'**
  String get notificationSettingsRoutine;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get commonOff;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أوقات عدم الإزعاج'**
  String get notificationSettingsQuietHours;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نلتزم بإرسال التنبيهات الضرورية فقط لمساعدتك على الالتزام، دون أي إزعاج أو إشعارات ترويجية.'**
  String get notificationSettingsPromise;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الهدوء الليلي'**
  String get notificationSettingsNightQuiet;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'من {start} حتى {end}'**
  String commonFromTo(Object start, Object end);

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يبدأ'**
  String get notificationSettingsStarts;

  /// UI text in presentation/screens/notification_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ينتهي'**
  String get notificationSettingsEnds;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get notificationsTitle;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get notificationsMarkAllRead;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كل جديدك في مكان واحد'**
  String get notificationsAllInOne;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تحديثات خطتك وتذكيراتك الصحية'**
  String get notificationsSubtitle;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مقروء'**
  String get notificationsRead;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بروتين {protein} جم  •  كربوهيدرات {carbs} جم'**
  String notificationsMealMacros(Object protein, Object carbs);

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تحديث سريري'**
  String get notificationsClinicalUpdate;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الآن'**
  String get notificationsLogNow;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات في هذا التصنيف حالياً'**
  String get notificationsEmptyCategory;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تنبيهاتك مخصصة لراحتك'**
  String get notificationsPersonalized;

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تعديل أوقات الوجبات من الإعدادات'**
  String get notificationsEditMealTimes;

  /// UI text in presentation/screens/offline_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال'**
  String get offlineTitle;

  /// UI text in presentation/screens/offline_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إعادة محاولة الاتصال'**
  String get offlineRetry;

  /// UI text in presentation/screens/offline_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عرض الوجبات المحفوظة أوفلاين'**
  String get offlineSavedMeals;

  /// UI text in presentation/screens/offline_state_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تحقق من تفعيل Wi-Fi أو بيانات الهاتف من إعدادات جهازك'**
  String get offlineCheckWifi;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حسب الوصفة'**
  String get onboardingHealthAsPrescribed;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'البيانات الصحية'**
  String get onboardingHealthTitle;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الحالات الصحية والأمراض'**
  String get onboardingHealthConditions;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حدد أي حالات صحية تم تشخيصك بها لتكييف برنامجك الغذائي ومكوناته والوجبات المقترحة وفق استجابة تامة وآمنة لجسمك.'**
  String get onboardingHealthConditionsNote;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سرية سريرية مشفرة ومعتمدة طبياً — تساعد هذه التفاصيل أخصائي التغذية في استبعاد أي مكونات قد تتعارض مع مؤشراتك الحيوية أو أدويتك الموصوفة.'**
  String get onboardingHealthConfidentialNote;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الحساسية الغذائية والتفضيلات'**
  String get onboardingHealthAllergies;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حدد مسببات الحساسية المعتمدة ليقوم النظام باستبعادها تلقائياً من جداول الوجبات والوصفات المقترحة.'**
  String get onboardingHealthAllergiesNote;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الأدوية والمكملات المنتظمة'**
  String get onboardingHealthMedications;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'دقة الجرعات'**
  String get onboardingHealthDoseAccuracy;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اكتب أي أدوية موصوفة أو فيتامينات تتناولها لضمان عدم حدوث تداخلات كيميائية مع توقيت ومكونات الوجبات.'**
  String get onboardingHealthMedicationsNote;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get commonAdd;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الدواء والجرعة (مثال: أوميغا 3)'**
  String get onboardingHealthMedicationHint;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تخضع كافة الملاحظات والأدوية لمراجعة برمجية واستشارية دقيقة لملاءمة النظام الغذائي واستبعاد أي تداخلات غذائية مع أدويتك الموصوفة.'**
  String get onboardingHealthReviewNote;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات صحية أخرى للأخصائي (اختياري)'**
  String get onboardingHealthOtherNotes;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مثال: أتناول مكملات فيتامين د يومياً، إجراء جراحة مرارة سابقة، أو أي أدوية منتظمة...'**
  String get onboardingHealthOtherNotesHint;

  /// UI text in presentation/screens/onboarding_health_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'متابعة والتالي'**
  String get onboardingHealthContinue;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اختر وزنك'**
  String get onboardingMeasurementsPickWeight;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{value} كجم'**
  String commonKilogramsValue(Object value);

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'القياسات الأولية'**
  String get onboardingMeasurementsTitle;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قياساتك الأولية'**
  String get onboardingMeasurementsYours;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أدخل وزنك وقياساتك اليوم لنبدأ بتتبع رحلتك الصحية مع الأخصائي بدقة واحترافية.'**
  String get onboardingMeasurementsIntro;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إلزامي'**
  String get onboardingMeasurementsMandatory;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كجم'**
  String get commonKilogramsUnit;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اضغط للاختيار'**
  String get onboardingMeasurementsTapToChoose;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'160 كجم'**
  String get onboardingMeasurementsMaxWeight;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المثالي التقديري: 65-72'**
  String get onboardingMeasurementsIdealRange;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'40 كجم'**
  String get onboardingMeasurementsMinWeight;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نصيحة الأخصائي: يُفضل أخذ القياس صباحاً بعد الاستيقاظ مباشرة، بملابس خفيفة وقبل تناول الإفطار.'**
  String get onboardingMeasurementsTip;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كيف آخذ قياساتي بشكل دقيق؟'**
  String get onboardingMeasurementsHowTo;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'دليل مصور'**
  String get onboardingMeasurementsIllustratedGuide;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قياسات إضافية تدعم دقة متابعة الأخصائي لمحيط الجسم ونسب توزيع الدهون بدقة.'**
  String get onboardingMeasurementsExtraNote;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عند أضيق نقطة'**
  String get onboardingMeasurementsWaistHint;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المنطقة الأكبر حجماً'**
  String get onboardingMeasurementsHipHint;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أعلى الفخذ الأيمن'**
  String get onboardingMeasurementsThighHint;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بياناتك وقياساتك مشفرة بالكامل بمعايير أمان صحية معتمدة، وتُعرض حصرياً لأخصائي التغذية المعتمد لتصميم خطتك الغذائية الفردية.'**
  String get onboardingMeasurementsPrivacyNote;

  /// UI text in presentation/screens/onboarding_measurements_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حفظ والمتابعة'**
  String get onboardingMeasurementsSaveContinue;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا تفوّت مواعيد وجباتك'**
  String get onboardingNotificationsTitle;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فعّل الإشعارات لتصلك تذكيرات الوجبات المخصصة، وتنبيهات الأخصائي لمتابعة التزامك أولاً بأول وبكل سلاسة.'**
  String get onboardingNotificationsIntro;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات بمواعيد الوجبات المحددة'**
  String get onboardingNotificationsMealReminders;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تنبيه لطيف قبل موعد الوجبة لمساعدتك على تنظيم يومك وتناول طعامك الصحي في التوقيت الأنسب لجسمك.'**
  String get onboardingNotificationsMealRemindersDesc;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'رسائل وتوجيهات مباشرة من الأخصائي'**
  String get onboardingNotificationsSpecialistMessages;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'استلم تعليقات أخصائي التغذية وتعديلات الخطة فور إرسالها دون الحاجة لتفقد التطبيق باستمرار.'**
  String get onboardingNotificationsSpecialistMessagesDesc;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات لموعد تسجيل الوزن أسبوعياً'**
  String get onboardingNotificationsWeightReminders;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تذكير أسبوعي في الوقت الصباحي المثالي للقياس لمتابعة تطور نتائجك ومؤشراتك الحيوية بدقة.'**
  String get onboardingNotificationsWeightRemindersDesc;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات الآن'**
  String get onboardingNotificationsEnable;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ليس الآن، سأضبطها لاحقاً'**
  String get onboardingNotificationsLater;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خطوة ٣ من ٣ ({percent}%)'**
  String onboardingStepProgress(Object percent);

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إعداد التنبيهات • HealthyLife'**
  String get onboardingNotificationsHeader;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نحترم هدوءك وخصوصيتك: '**
  String get onboardingNotificationsRespectLabel;

  /// UI text in presentation/screens/onboarding_notifications_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لن نرسل أي إعلانات ترويجية، ويمكنك دائماً ضبط أو كتم أوقات التنبيهات من الإعدادات.'**
  String get onboardingNotificationsRespectBody;

  /// UI text in presentation/screens/onboarding_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تتبع وجباتك ووزنك بلمسة واحدة'**
  String get onboardingTrackTitle;

  /// UI text in presentation/screens/onboarding_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّل وجباتك اليومية ووزنك بدقة بالغرامات، واستفد من البدائل المتاحة لتسهيل التزامك بالنظام الغذائي دون حرمان.'**
  String get onboardingTrackDescription;

  /// UI text in presentation/screens/onboarding_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مسح ذكي فوري'**
  String get onboardingBadgeSmartScan;

  /// UI text in presentation/screens/onboarding_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'دقة تفصيلية'**
  String get onboardingBadgeDetailedAccuracy;

  /// UI text in presentation/screens/onboarding_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خطتك الغذائية بإشراف أخصائيك'**
  String get onboardingPlanTitle;

  /// UI text in presentation/screens/onboarding_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'احصل على نظام غذائي مخصص بالكامل يناسب طبيعة جسمك وحالتك الصحية، ومصمم مباشرة من أخصائي التغذية المتابع لك.'**
  String get onboardingPlanDescription;

  /// UI text in presentation/screens/onboarding_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'١٠٠٪ معتمد طبياً ومبني على التحاليل'**
  String get onboardingBadgeApproved;

  /// UI text in presentation/screens/onboarding_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onboardingStartNow;

  /// UI text in presentation/screens/onboarding_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get onboardingSkip;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور الحالية'**
  String get passwordErrorEnterCurrent;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اجعلي كلمة المرور 8 أحرف على الأقل'**
  String get passwordErrorMinLength;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أضيفي حرفًا كبيرًا واحدًا على الأقل'**
  String get passwordErrorUppercase;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أضيفي رقمًا واحدًا على الأقل'**
  String get passwordErrorDigit;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أضيفي رمزًا خاصًا واحدًا على الأقل'**
  String get passwordErrorSpecial;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أكدي كلمة المرور الجديدة بشكل مطابق'**
  String get passwordErrorMismatch;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ كلمة المرور بنجاح'**
  String get passwordSaved;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سيتم إرسال رابط استعادة كلمة المرور إلى رقمك أو بريدك المسجل'**
  String get passwordResetLinkSent;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordTitle;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get passwordCurrent;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get passwordForgot;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get passwordConfirmNew;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تطابق كلمة المرور الجديدة تماماً'**
  String get passwordMatches;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get passwordNoMatch;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'شروط كلمة المرور:'**
  String get passwordRequirements;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'٨ أحرف على الأقل'**
  String get passwordRuleMinLength8;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'رمز خاص واحد على الأقل (!@#\$%)'**
  String get passwordRuleSpecial;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بعد تغيير كلمة المرور بنجاح، سيتم تسجيل خروجك من الأجهزة الأخرى تلقائياً لحماية حسابك الطبي وصحتك.'**
  String get passwordLogoutOthersNote;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حماية الحساب والبيانات الصحية'**
  String get passwordProtectionTitle;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'احرص على اختيار كلمة مرور قوية وغير مكررة لضمان خصوصية خطتك وسجلاتك الصحية.'**
  String get passwordProtectionBody;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get passwordStrengthEnter;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ضعيفة'**
  String get passwordStrengthWeak;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'متوسطة'**
  String get passwordStrengthFair;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'جيدة ومقبولة'**
  String get passwordStrengthGood;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قوية جداً'**
  String get passwordStrengthVeryStrong;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قوة كلمة المرور:'**
  String get passwordStrengthLabel;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get commonSaved;

  /// UI text in presentation/screens/password_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حفظ كلمة المرور'**
  String get passwordSave;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خطتكِ قيد التحضير بعناية'**
  String get planPreparingTitle;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أخصائي التغذية العلاجية يُعدّ الآن جدولك الغذائي المخصص بدقة ليلائم أهدافك الصحية ونتائج قياساتك الأولية. سنرسل لك إشعاراً فور اعتماد الخطة لتجدها هنا.'**
  String get planPreparingBody;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الوقت المتوقع للاعتماد'**
  String get planPreparingExpectedTime;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خلال ٢٤ ساعة عمل من تسجيل قياساتك الأولية'**
  String get planPreparingWithin24h;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مراجعة طبية سريرية موثقة'**
  String get planPreparingReview;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{percent}٪ يدوي ومخصص'**
  String planPreparingManualPercent(Object percent);

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'استفسار أو تفضيل غذائي طارئ؟'**
  String get planPreparingUrgentQuestion;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فريقنا وأخصائي التغذية متاحون للمساعدة الفورية'**
  String get planPreparingTeamAvailable;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع أخصائي التغذية عبر واتساب'**
  String get planPreparingContactWhatsApp;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'متاح طوال أيام العمل الرسمية من ٩:٠٠ ص حتى ٦:٠٠ م'**
  String get planPreparingHours;

  /// Plan preparing: clinic line. gender: other | unknown.
  ///
  /// In ar, this message translates to:
  /// **'{gender, select, unknown{عيادة التغذية العلاجية} other{عيادة التغذية العلاجية • {name}}}'**
  String planPreparingClinic(String gender, String name);

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تخصيص متقدم'**
  String get planPreparingAdvanced;

  /// UI text in presentation/screens/plan_preparing_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get commonEnabled;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'١. نطاق البيانات المجمّعة'**
  String get privacyScopeTitle;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نجمع فقط ما يلزم لبناء خطتك الغذائية العلاجية: قياساتك الحيوية (الوزن، محيط الجسم)، سجلات وجباتك اليومية، حالاتك الصحية المشخصة، حساسياتك الغذائية، والأدوية والمكملات التي تخبرينا بها. لا نطلب أو نُخزّن أي بيانات مالية أو بيانات موقع دائم.'**
  String get privacyScopeBody;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'٢. التشفير وأماكن التخزين'**
  String get privacyEncryptionTitle;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تُشفّر جميع البيانات الصحية أثناء النقل والتخزين بنظام bit AES-256، وتُحفظ على خوادم طبية معزولة متوافقة مع معايير HIPAA. لا تُستخدم بياناتك في تدريب نماذج عامة ولا تُشارك مع أي شركة إعلانات تحت أي ظرف.'**
  String get privacyEncryptionBody;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'٣. من يستطيع الاطلاع على ملفك'**
  String get privacyAccessTitle;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فريق الرعاية المخصص لك فقط — أخصائي التغذية العلاجية المعتمد على حسابك — يستطيع الاطلاع على سجلك الكامل. أي تحديث أو تعديل على خطتك يُسجَّل باسم صاحبه ووقته في سجل تدقيق لا يمكن حذفه.'**
  String get privacyAccessBody;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'٤. حقك في التعديل والإلغاء'**
  String get privacyRightsTitle;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يمكنك سحب موافقتك في أي وقت من الحساب ← الخصوصية، وسيؤدي ذلك إلى إيقاف تخصيص الخطة تلقائياً حتى تجديد الموافقة. يمكنك أيضاً طلب نسخة كاملة من بياناتك أو حذفها نهائياً بالتواصل مع أخصائي التغذية.'**
  String get privacyRightsBody;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'٥. الاحتفاظ بالبيانات بعد انتهاء المتابعة'**
  String get privacyRetentionTitle;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عند انتهاء فترة المتابعة السريرية، تبقى سجلاتك وقياساتك محفوظة بأمان لاستئناف الخطة فور التجديد، ولا تُحذف تلقائياً إلا بطلب صريح منك.'**
  String get privacyRetentionBody;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية السريرية الكاملة'**
  String get privacyTitle;

  /// UI text in presentation/screens/privacy_document_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث لهذه الوثيقة: يناير 2026 — متوافقة مع معايير HIPAA السريرية'**
  String get privacyLastUpdated;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّل قياساتك وتابع مسار تغيّرك'**
  String get profileMeasurementsSubtitle;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المستوى، الهدف، الأدوية والتشخيصات المعتمدة'**
  String get profileHealthRecordSubtitle;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إنجازاتي'**
  String get profileAchievements;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'النوم والإجهاد والمزاج'**
  String get profileWellbeing;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المواعيد والمتابعة'**
  String get profileAppointments;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجل الإشعارات'**
  String get profileNotificationLog;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get profileTitle;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get commonSettings;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب والمتابعة'**
  String get profileAccountSettings;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الأخصائي الغذائي'**
  String get profileDietitian;

  /// Profile: the nutritionist row. gender: male | female | other | unknown.
  ///
  /// In ar, this message translates to:
  /// **'{gender, select, male{{name} (أخصائي التغذية العلاجية)} female{{name} (أخصائية التغذية العلاجية)} unknown{أخصائي التغذية العلاجية} other{{name}}}'**
  String profileDietitianName(String gender, String name);

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'التذكير بالوجبات والقياسات'**
  String get profileNotificationsSubtitle;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تحديث وحماية الحساب'**
  String get profilePasswordSubtitle;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'العربية (الحالية)'**
  String get profileLanguageCurrent;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عربي'**
  String get profileLanguageBadge;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الإصدار 1.0.0'**
  String get profileVersion;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة تتطلب باقة أعلى — تواصل مع أخصائي التغذية للترقية'**
  String get profileUpgradeRequired;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الملف الصحي (Health CV)'**
  String get profileHealthCv;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سجل صحي شامل يعدّه أخصائيك'**
  String get profileHealthCvSubtitle;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يتطلب تأكيد تسجيل الخروج لضمان مزامنة قياساتك الأخيرة'**
  String get profileLogoutCaption;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كود المريض: HL-0042'**
  String get profilePatientCode;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'العيادة المتابعة'**
  String get profileFollowingClinic;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get profileMore;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'القياسات، السجل الطبي، الإنجازات والمواعيد'**
  String get profileMoreSubtitle;

  /// UI text in presentation/screens/profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الجلسة بأمان من هذا الجهاز'**
  String get profileLogoutSubtitle;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الموعد الاستشاري القادم: الأحد القادم، الساعة 5:00 مساءً'**
  String get progressNextConsultation;

  /// Footer of the progress screen: the next booked appointment (API guide 12.4). date is already formatted with its time.
  ///
  /// In ar, this message translates to:
  /// **'موعدك القادم: {date}'**
  String progressNextAppointment(String date);

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'متابعة التقدم والتقييم'**
  String get progressTitle;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ملف نشط'**
  String get progressActiveFile;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مزامنة مباشرة مع العيادة'**
  String get progressLiveSync;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'متصل الآن'**
  String get progressOnlineNow;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'التقدّم والقياسات'**
  String get progressAndMeasurements;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الأخصائي'**
  String get progressSpecialistNotes;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get commonNew;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الوزن الحالي المسجل'**
  String get progressCurrentWeight;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل وزن جديد اليوم'**
  String get progressLogWeightToday;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مسار الوزن'**
  String get progressWeightTrend;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مقارنة بين قياس العيادة والمنزل'**
  String get progressClinicVsHome;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'30 يوماً'**
  String get progressRange30;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'90 يوماً'**
  String get progressRange90;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get commonToday;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قياس العيادة المعتمد'**
  String get progressClinicReading;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'قياس بيتي دوري'**
  String get progressHomeReading;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'محيط القياسات الحيوية'**
  String get progressVitalCircumference;

  /// Under the circumference heading: the date of the latest reading that measured one. date is already formatted.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث {date}'**
  String progressUpdatedOn(String date);

  /// Progress screen when no reading has a circumference yet.
  ///
  /// In ar, this message translates to:
  /// **'لم تُسجَّل قياسات المحيط بعد. أضفها مع قياس وزنك القادم.'**
  String get progressNoCircumference;

  /// Change of a circumference since the reading before, with its sign. value is the signed number as shown.
  ///
  /// In ar, this message translates to:
  /// **'{value} سم'**
  String progressCmChange(String value);

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث قبل يومين'**
  String get progressUpdatedTwoDaysAgo;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الخصر'**
  String get progressWaist;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'-4 سم'**
  String get progressWaistDelta;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الورك'**
  String get progressHip;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'-2 سم'**
  String get progressHipDelta;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الفخذ'**
  String get progressThigh;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'-1 سم'**
  String get progressThighDelta;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الذراع'**
  String get progressArm;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'دليل القياس المصوّر'**
  String get progressGuideLink;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تقييم الأسبوع الحالي'**
  String get progressWeeklyEvaluation;

  /// Title of the card with the nutritionist's latest note (API guide 9.2).
  ///
  /// In ar, this message translates to:
  /// **'آخر تقييم من أخصائي التغذية'**
  String get progressLatestReview;

  /// No description provided for @progressAdherencePercent.
  ///
  /// In ar, this message translates to:
  /// **'التزام {percent}%'**
  String progressAdherencePercent(String percent);

  /// No description provided for @progressNoReadings.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قراءات وزن في هذه الفترة بعد.'**
  String get progressNoReadings;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تمت المراجعة من {name}'**
  String progressReviewedBy(String name);

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أداء ممتاز'**
  String get progressExcellent;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'استجابة ممتازة لمقاومة الإنسولين، مع تحسن ملموس في توازن الطاقة الحيوية أثناء ساعات الصباح وثبات ملحوظ في قياسات الخصر.'**
  String get progressEvaluationBody;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'رسالة تشجيعية خاصة'**
  String get progressEncouragementTitle;

  /// Progress: encouragement card (no patient name).
  ///
  /// In ar, this message translates to:
  /// **'“فخورة جداً بوعيك والتزامك هذا الأسبوع! النزول تدريجي وصحي ومحيط الخصر تحسن بشكل ملحوظ. حافظي على نمط النوم الحالي وسنصل لهدف الشهر بكل سهولة”'**
  String get progressEncouragementQuote;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة صوتية من الدكتورة'**
  String get progressVoiceNote;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'زيادة شرب الماء لـ 2.5 لتر يومياً'**
  String get progressTaskWater;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'توزيع منتظم بمعدل كوب كل ساعتين بين الوجبات لتعزيز الأيض.'**
  String get progressTaskWaterDesc;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'بديل جبنة القريش مع زيت الزيتون'**
  String get progressTaskCottageCheese;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اعتمادك كوجبة عشاء رئيسية لدعم الشبع البطيء وموازنة سكر الدم ليلاً.'**
  String get progressTaskCottageCheeseDesc;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'15 دقيقة مشي خفيف بعد العشاء'**
  String get progressTaskWalk;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تنشيط الدورة الدموية وتفريغ مخازن الجليكوجين قبل النوم.'**
  String get progressTaskWalkDesc;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'توجيهات الأسبوع القادم'**
  String get progressNextWeekGuidance;

  /// Number of tasks in the latest note. count drives the plural; countText is the number as shown.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{مهمة واحدة} =2{مهمتان} few{{countText} مهام} other{{countText} مهمة}}'**
  String progressTaskCount(num count, String countText);

  /// Link from the progress screen to every note from the nutritionist.
  ///
  /// In ar, this message translates to:
  /// **'عرض كل الملاحظات'**
  String get progressAllNotes;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'3 مهام محددة'**
  String get progressThreeTasks;

  /// UI text in presentation/screens/progress_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مناقشة التقييم عبر الواتساب مباشرة'**
  String get progressDiscussWhatsApp;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'فاكهة طازجة'**
  String get quantityFreshFruit;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{kcal} سعرة حرارية لكل {grams} غرام'**
  String quantityKcalPerGrams(Object kcal, Object grams);

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{kcal} سعرة × {portions} حصة'**
  String quantityKcalTimesPortions(Object kcal, Object portions);

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'القيمة محسوبة بالكامل وتُضاف بدقة إلى خطتك اليومية'**
  String get quantityCalculatedNote;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المدى المتاح: {min} غرام حتى {max} غرام'**
  String quantityRange(Object min, Object max);

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'غرام (g)'**
  String get quantityGramsUnit;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'كميات شائعة وسريعة:'**
  String get quantityCommonAmounts;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'اختر بلمسة واحدة'**
  String get quantityOneTap;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'شريط الضبط الدقيق'**
  String get quantityFineSlider;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تلميح للمساعدة في التقدير'**
  String get quantityEstimateHint;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تفاحة متوسطة الحجم تعادل تقريباً {apple} غرام، بينما كف اليد المنبسط يعادل حوالي {palm} غرام من اللحوم أو الأرز المطبوخ، يمكنك دوماً التقدير بالتقريب دون قلق.'**
  String quantityEstimateBody(Object apple, Object palm);

  /// Floating badge after tapping + on the grams stepper. The Arabic order renders as +١٠ in RTL.
  ///
  /// In ar, this message translates to:
  /// **'{value}+'**
  String quantityStepAdd(String value);

  /// Floating badge after tapping - on the grams stepper.
  ///
  /// In ar, this message translates to:
  /// **'{value}-'**
  String quantityStepSubtract(String value);

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نهج مطمئن وصحي'**
  String get quantityReassuring;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'المرونة في التسجيل هي أساس استمرارية العادات الصحية'**
  String get quantityFlexibility;

  /// UI text in presentation/screens/quantity_selector_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الكمية وتسجيل الطعام'**
  String get quantityConfirm;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get weekdayShortSunday;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الإثنين'**
  String get weekdayShortMonday;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get weekdayShortTuesday;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get weekdayShortWednesday;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get weekdayShortThursday;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مراجعة نتائج القياسات'**
  String get callsResultsReview;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get callsCompleted;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get callsPast;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'القادمة'**
  String get callsUpcoming;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'حجز موعد جديد'**
  String get callsBookNew;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مع {name}'**
  String callsWithNutritionist(String name);

  /// Notification text in data/services/local_appointment_reminder_scheduler.dart
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات المواعيد'**
  String get appointmentReminderChannel;

  /// Notification text in data/services/local_appointment_reminder_scheduler.dart
  ///
  /// In ar, this message translates to:
  /// **'موعد قادم'**
  String get appointmentReminderTitle;

  /// Notification text in data/services/local_appointment_reminder_scheduler.dart
  ///
  /// In ar, this message translates to:
  /// **'موعدك بعد ٢٤ ساعة'**
  String get appointmentReminderDay;

  /// Notification text in data/services/local_appointment_reminder_scheduler.dart
  ///
  /// In ar, this message translates to:
  /// **'موعدك بعد ساعة'**
  String get appointmentReminderHour;

  /// Notification text in data/services/local_appointment_reminder_scheduler.dart
  ///
  /// In ar, this message translates to:
  /// **'موعدك يبدأ بعد ٥ دقائق'**
  String get appointmentReminderFiveMinutes;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'جلسة متابعة'**
  String get callsTypeFollowUp;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'استشارة سريعة'**
  String get callsTypeQuickConsult;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'موعد'**
  String get callsTypeOther;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get callsChannelWhatsapp;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مكالمة هاتفية'**
  String get callsChannelPhone;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مكالمة فيديو'**
  String get callsChannelVideo;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'محجوز'**
  String get callsStatusBooked;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get callsStatusCancelled;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لم يحضر'**
  String get callsStatusNoShow;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد قادمة.'**
  String get callsEmptyUpcoming;

  /// UI text in presentation/screens/schedule_calls_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواعيد سابقة بعد.'**
  String get callsEmptyPast;

  /// UI text in presentation/screens/sleep_stress_mood_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'جودة نومك الليلة الماضية'**
  String get wellbeingSleepQuality;

  /// UI text in presentation/screens/sleep_stress_mood_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ساعات'**
  String get wellbeingHours;

  /// UI text in presentation/screens/sleep_stress_mood_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نوم جيد — استمري على نفس الروتين'**
  String get wellbeingGoodSleep;

  /// UI text in presentation/screens/sleep_stress_mood_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مستوى الإجهاد'**
  String get wellbeingStressLevel;

  /// UI text in presentation/screens/sleep_stress_mood_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get wellbeingLow;

  /// UI text in presentation/screens/sleep_stress_mood_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لحظة تنفّس'**
  String get wellbeingBreathingMoment;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'ملف الأخصائي'**
  String get specialistTitle;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'عن أخصائي التغذية'**
  String get specialistAboutTitle;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الملف الغذائي العلاجي نشط'**
  String get specialistProfileActive;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'معتمد'**
  String get specialistCertified;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مرخصة'**
  String get specialistLicensed;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'مرخصة من الهيئة الصحية'**
  String get specialistLicensedByAuthority;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'رعاية فردية مباشرة'**
  String get specialistDirectCare;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'أوقات الرد والمتابعة المعتادة'**
  String get specialistHoursTitle;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'استشارة سريعة مع أخصائي التغذية'**
  String get specialistQuickConsult;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تواصل في أي وقت لمناقشة تعديلات الوجبات والشعور العام'**
  String get specialistQuickConsultBody;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'تواصل عبر واتساب'**
  String get specialistContactWhatsApp;

  /// UI text in presentation/screens/specialist_profile_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'يفتح محادثة مباشرة مع أخصائي التغذية لمتابعة حالتك'**
  String get specialistContactNote;

  /// UI text in presentation/screens/splash_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خطوة صغيرة نحو صحة أفضل'**
  String get splashTagline;

  /// UI text in presentation/screens/splash_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نرافقك نحو حياة أكثر توازنًا، يومًا بعد يوم.'**
  String get splashSubtitle;

  /// UI text in presentation/screens/splash_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'نعتني بصحتك، كل يوم'**
  String get splashCaringEveryDay;

  /// UI text in presentation/screens/splash_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'جاري تجهيز تجربتك الصحية'**
  String get splashPreparing;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get weekdayShortSaturday;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get weekdayShortFriday;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'شاشة استعراض الخطة والتحضير المسبق'**
  String get weeklyPlanPreviewScreen;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'لتسجيل الوجبات وتأكيد تناولها يرجى التوجه لتبويب خطتي اليومية'**
  String get weeklyPlanLoggingHint;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع الثالث'**
  String get weeklyPlanWeekThree;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'سبتمبر 2025'**
  String get weeklyPlanMonth;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خطة غذائية مفصلة'**
  String get weeklyPlanDetailed;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خطة يوم {day} • {date} سبتمبر'**
  String weeklyPlanDayPlan(Object day, Object date);

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'دهون صحية'**
  String get macroHealthyFatsShort;

  /// Short macro label in stat boxes (weekly plan, meal logged).
  ///
  /// In ar, this message translates to:
  /// **'بروتين'**
  String get macroProteinLabel;

  /// Short macro label in stat boxes (meal logged).
  ///
  /// In ar, this message translates to:
  /// **'دهون'**
  String get macroFatLabel;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'42 غ'**
  String get weeklyPlanFats;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'120 غ'**
  String get weeklyPlanCarbs;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'105 غ'**
  String get weeklyPlanProtein;

  /// UI text in presentation/screens/weekly_plan_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'خطة متوازنة لتعزيز الطاقة وحرق الدهون بإشراف أخصائي التغذية'**
  String get weeklyPlanSummary;

  /// UI text in presentation/widgets/connection_status_sheet.dart
  ///
  /// In ar, this message translates to:
  /// **'حالة الاتصال'**
  String get connectionStatusTitle;

  /// UI text in presentation/widgets/date_chip_picker.dart
  ///
  /// In ar, this message translates to:
  /// **'{value} س'**
  String datePickerKcal(Object value);

  /// UI text in presentation/widgets/live_metric_card.dart
  ///
  /// In ar, this message translates to:
  /// **'مباشر'**
  String get liveBadge;

  /// UI text in presentation/widgets/locked_feature_overlay.dart
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع أخصائي التغذية'**
  String get lockedContactSpecialist;

  /// UI text in presentation/widgets/meal_card.dart
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الوجبة'**
  String get mealCardLogged;

  /// UI text in presentation/widgets/meal_card.dart
  ///
  /// In ar, this message translates to:
  /// **'الوجبة القادمة / الحالية'**
  String get mealCardNextCurrent;

  /// UI text in presentation/widgets/meal_card.dart
  ///
  /// In ar, this message translates to:
  /// **'مجدولة لاحقاً'**
  String get mealCardScheduledLater;

  /// UI text in presentation/widgets/meal_card.dart
  ///
  /// In ar, this message translates to:
  /// **'سجّل هذه الوجبة الآن'**
  String get mealCardLogNow;

  /// UI text in presentation/widgets/offline_banner.dart
  ///
  /// In ar, this message translates to:
  /// **'جاري مزامنة بياناتك...'**
  String get offlineBannerSyncing;

  /// UI text in presentation/widgets/offline_banner.dart
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل بالإنترنت الآن'**
  String get offlineBannerOffline;

  /// UI text in presentation/widgets/offline_banner.dart
  ///
  /// In ar, this message translates to:
  /// **'يتم تحديث سجلاتك مع الخادم الآن'**
  String get offlineBannerUpdating;

  /// UI text in presentation/widgets/offline_banner.dart
  ///
  /// In ar, this message translates to:
  /// **'بياناتك محفوظة محلياً بأمان تام'**
  String get offlineBannerSavedLocally;

  /// UI text in presentation/widgets/offline_banner.dart
  ///
  /// In ar, this message translates to:
  /// **'{count} بانتظار المزامنة'**
  String offlineBannerPending(Object count);

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'تصفح خطة وجبات اليوم المخزنة'**
  String get offlinePanelBrowsePlan;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'جداول السعرات والمكونات متوفرة بدون اتصال'**
  String get offlinePanelBrowsePlanDesc;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'تسجيل قياسات الوزن والمحيط'**
  String get offlinePanelLogMeasurements;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'يتم حفظ التغييرات بقاعدة بيانات الهاتف المشفرة'**
  String get offlinePanelLogMeasurementsDesc;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'تدوين الملاحظات والوجبات السريعة'**
  String get offlinePanelNotes;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'تُدرج في قائمة الانتظار للمزامنة الفورية لاحقاً'**
  String get offlinePanelNotesDesc;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'حماية الخصوصية والتشفير المحلي'**
  String get offlinePanelPrivacy;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'تشفير متقدم يحمي سجلاتك الصحية دون الحاجة لسيرفر'**
  String get offlinePanelPrivacyDesc;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'بياناتك ووجباتك المسجلة محفوظة بأمان تام على جهازك. سنقوم بالمزامنة السحابية تلقائياً فور عودة الشبكة.'**
  String get offlinePanelSavedNote;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'محلياً'**
  String get offlinePanelLocally;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'الوضع غير المتصل نشط'**
  String get offlinePanelModeActive;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'يمكنك متابعة تصفح خطتك الغذائية وتسجيل وجباتك كالمعتاد بدون أي انقطاع.'**
  String get offlinePanelContinue;

  /// UI text in presentation/widgets/offline_capability_panel.dart
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يمكنك إنجازه الآن؟'**
  String get offlinePanelWhatNow;

  /// UI text in presentation/widgets/onboarding_step_header.dart
  ///
  /// In ar, this message translates to:
  /// **'خطوة {step} من {total} ({percent}%)'**
  String onboardingStepOf(Object step, Object total, Object percent);

  /// UI text in presentation/widgets/onboarding_step_header.dart
  ///
  /// In ar, this message translates to:
  /// **'HealthyLife • الملف الصحي'**
  String get onboardingStepBrand;

  /// UI text in presentation/widgets/pulsing_breathing_button.dart
  ///
  /// In ar, this message translates to:
  /// **'شهيق'**
  String get breathingInhale;

  /// UI text in presentation/widgets/pulsing_breathing_button.dart
  ///
  /// In ar, this message translates to:
  /// **'زفير'**
  String get breathingExhale;

  /// UI text in presentation/widgets/substitution_badges.dart
  ///
  /// In ar, this message translates to:
  /// **'({sign}{delta} سعرة)'**
  String substitutionKcalDelta(Object sign, Object delta);

  /// UI text in presentation/widgets/substitution_badges.dart
  ///
  /// In ar, this message translates to:
  /// **'الصنف الأصلي'**
  String get substitutionOriginal;

  /// UI text in presentation/widgets/substitution_badges.dart
  ///
  /// In ar, this message translates to:
  /// **'ثابت'**
  String get substitutionFixed;

  /// UI text in presentation/widgets/substitution_badges.dart
  ///
  /// In ar, this message translates to:
  /// **'صنف أساسي، بدون بديل'**
  String get substitutionCoreNoAlternative;

  /// UI text in presentation/screens/daily_log_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{وجبة واحدة} =2{وجبتان} other{{countText} وجبات}}'**
  String dailyLogMealsCount(num count, String countText);

  /// UI text in presentation/screens/food_search_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{طعام واحد} =2{طعامان} few{{countText} أطعمة} other{{countText} طعاماً}}'**
  String foodSearchFoodsCount(num count, String countText);

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{ثانية واحدة} =2{ثانيتان} other{{countText} ثوانٍ}}'**
  String mealLoggedCountdown(num count, String countText);

  /// UI text in presentation/screens/meal_log_success_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{وجبة واحدة} =2{وجبتين} other{{countText} وجبات}}'**
  String mealLoggedMealsCount(num count, String countText);

  /// UI text in presentation/screens/notifications_center_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, other{لديك {countText} إشعارات جديدة}}'**
  String notificationsNewCount(num count, String countText);

  /// UI text in presentation/widgets/auto_redirect_countdown.dart
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{جاري نقلك تلقائياً خلال {countText} ثانية…} other{جاري نقلك تلقائياً خلال {countText} ثوانٍ…}}'**
  String redirectCountdown(num count, String countText);

  /// UI text in presentation/screens/language_settings_screen.dart
  ///
  /// In ar, this message translates to:
  /// **'(اللغة الحالية للتطبيق) {languageName}'**
  String languageSubtitleCurrent(String languageName);

  /// No description provided for @commonShow.
  ///
  /// In ar, this message translates to:
  /// **'إظهار'**
  String get commonShow;

  /// No description provided for @commonHide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get commonHide;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استخدم اسم المستخدم وكلمة المرور اللذين أرسلهما لك أخصائيك عبر واتساب.'**
  String get loginSubtitle;

  /// No description provided for @loginUsername.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get loginUsername;

  /// No description provided for @loginUsernameHint.
  ///
  /// In ar, this message translates to:
  /// **'بالأحرف الإنجليزية فقط'**
  String get loginUsernameHint;

  /// No description provided for @loginPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPassword;

  /// No description provided for @loginCta.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginCta;

  /// No description provided for @loginErrorRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المستخدم وكلمة المرور.'**
  String get loginErrorRequired;

  /// No description provided for @loginErrorInvalid.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم أو كلمة المرور غير صحيحة.'**
  String get loginErrorInvalid;

  /// No description provided for @loginErrorLocked.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف الدخول مؤقتًا بعد عدة محاولات خاطئة. حاول بعد {time}.'**
  String loginErrorLocked(String time);

  /// No description provided for @loginErrorRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة خلال وقت قصير، انتظر قليلًا ثم حاول مجددًا.'**
  String get loginErrorRateLimited;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تسجيل الدخول. حاول مجددًا.'**
  String get loginErrorGeneric;

  /// No description provided for @loginForgotBody.
  ///
  /// In ar, this message translates to:
  /// **'اطلب من أخصائيك إعادة تعيين كلمة المرور. سيرسل لك اسم المستخدم وكلمة مرور جديدة عبر واتساب.'**
  String get loginForgotBody;

  /// No description provided for @sessionEndedMessage.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك. يرجى تسجيل الدخول مجددًا.'**
  String get sessionEndedMessage;

  /// No description provided for @passwordRuleLowercase.
  ///
  /// In ar, this message translates to:
  /// **'حرف صغير واحد على الأقل (a–z)'**
  String get passwordRuleLowercase;

  /// No description provided for @passwordErrorLowercase.
  ///
  /// In ar, this message translates to:
  /// **'أضف حرفًا صغيرًا واحدًا على الأقل'**
  String get passwordErrorLowercase;

  /// No description provided for @passwordCurrentWrong.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية غير صحيحة.'**
  String get passwordCurrentWrong;

  /// No description provided for @passwordWeakServer.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة لا تستوفي الشروط. اختر كلمة أخرى.'**
  String get passwordWeakServer;

  /// No description provided for @consentVersionChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث سياسة الخصوصية، اطّلع على النسخة الجديدة.'**
  String get consentVersionChanged;

  /// No description provided for @linkCouldNotOpen.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح الرابط.'**
  String get linkCouldNotOpen;

  /// No description provided for @followUpWeeksValue.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد أسابيع} one{أسبوع واحد} two{أسبوعان} few{{count} أسابيع} many{{count} أسبوعًا} other{{count} أسبوعًا}}'**
  String followUpWeeksValue(int count);

  /// No description provided for @followUpWeeksLabel.
  ///
  /// In ar, this message translates to:
  /// **'أسابيع المتابعة'**
  String get followUpWeeksLabel;

  /// No description provided for @followUpAdherenceValue.
  ///
  /// In ar, this message translates to:
  /// **'{value}%'**
  String followUpAdherenceValue(String value);

  /// No description provided for @passwordTemporaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور مؤقتة'**
  String get passwordTemporaryTitle;

  /// No description provided for @passwordTemporaryBody.
  ///
  /// In ar, this message translates to:
  /// **'غيّرها إلى كلمة مرور خاصة بك. يمكنك متابعة استخدام التطبيق.'**
  String get passwordTemporaryBody;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteWarningTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا'**
  String get accountDeleteWarningTitle;

  /// No description provided for @accountDeleteWarningBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف حسابك وكل بياناتك نهائياً.'**
  String get accountDeleteWarningBody;

  /// No description provided for @accountDeletePasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get accountDeletePasswordLabel;

  /// No description provided for @accountDeleteCta.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابي'**
  String get accountDeleteCta;

  /// No description provided for @accountDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب نهائياً؟'**
  String get accountDeleteConfirmTitle;

  /// No description provided for @accountDeleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف حسابك وكل بياناتك نهائياً. لا يمكن التراجع عن ذلك.'**
  String get accountDeleteConfirmMessage;

  /// No description provided for @accountDeleteWrongPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير صحيحة.'**
  String get accountDeleteWrongPassword;

  /// No description provided for @healthGoalNotSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يُحدَّد هدف بعد'**
  String get healthGoalNotSet;

  /// No description provided for @healthGoalWeightLoss.
  ///
  /// In ar, this message translates to:
  /// **'إنقاص الوزن'**
  String get healthGoalWeightLoss;

  /// No description provided for @healthGoalWeightGain.
  ///
  /// In ar, this message translates to:
  /// **'زيادة الوزن'**
  String get healthGoalWeightGain;

  /// No description provided for @healthGoalMuscleGain.
  ///
  /// In ar, this message translates to:
  /// **'بناء العضل'**
  String get healthGoalMuscleGain;

  /// No description provided for @healthGoalWeightMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت الوزن'**
  String get healthGoalWeightMaintenance;

  /// No description provided for @healthGoalHealthEnergy.
  ///
  /// In ar, this message translates to:
  /// **'صحة وطاقة'**
  String get healthGoalHealthEnergy;

  /// No description provided for @healthGoalMedicalCondition.
  ///
  /// In ar, this message translates to:
  /// **'حالة صحية'**
  String get healthGoalMedicalCondition;

  /// No description provided for @healthGoalOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get healthGoalOther;

  /// No description provided for @healthGoalTarget.
  ///
  /// In ar, this message translates to:
  /// **'المستهدف: {value}'**
  String healthGoalTarget(String value);

  /// No description provided for @healthGoalTargetDate.
  ///
  /// In ar, this message translates to:
  /// **'حتى {date}'**
  String healthGoalTargetDate(String date);

  /// No description provided for @healthNoMedications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أدوية مسجّلة'**
  String get healthNoMedications;

  /// No description provided for @healthTimingBefore.
  ///
  /// In ar, this message translates to:
  /// **'قبل الأكل'**
  String get healthTimingBefore;

  /// No description provided for @healthTimingWith.
  ///
  /// In ar, this message translates to:
  /// **'مع الأكل'**
  String get healthTimingWith;

  /// No description provided for @healthTimingAfter.
  ///
  /// In ar, this message translates to:
  /// **'بعد الأكل'**
  String get healthTimingAfter;

  /// No description provided for @healthTimingEmptyStomach.
  ///
  /// In ar, this message translates to:
  /// **'على معدة فارغة'**
  String get healthTimingEmptyStomach;

  /// No description provided for @healthTimingAny.
  ///
  /// In ar, this message translates to:
  /// **'في أي وقت'**
  String get healthTimingAny;

  /// No description provided for @healthMedStatusOngoing.
  ///
  /// In ar, this message translates to:
  /// **'مستمر'**
  String get healthMedStatusOngoing;

  /// No description provided for @healthMedStatusUntil.
  ///
  /// In ar, this message translates to:
  /// **'حتى {date}'**
  String healthMedStatusUntil(String date);

  /// No description provided for @healthMedReviewedBy.
  ///
  /// In ar, this message translates to:
  /// **'راجعها أخصائيك'**
  String get healthMedReviewedBy;

  /// No description provided for @healthMedReviewedOn.
  ///
  /// In ar, this message translates to:
  /// **'آخر مراجعة {date}'**
  String healthMedReviewedOn(String date);

  /// No description provided for @healthMedDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'هذه المعلومات لمتابعة أخصائيك فقط ولا تُعد نصيحة دوائية. لا تغيّر أدويتك دون استشارة طبيبك.'**
  String get healthMedDisclaimer;

  /// No description provided for @healthNoAllergies.
  ///
  /// In ar, this message translates to:
  /// **'لم تُسجَّل أي حساسية'**
  String get healthNoAllergies;

  /// No description provided for @healthAllergyFooter.
  ///
  /// In ar, this message translates to:
  /// **'تظهر تنبيهات على الأطعمة التي قد تحتوي على مسبباتها في خطتك.'**
  String get healthAllergyFooter;

  /// No description provided for @healthAllergyClassConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'حساسية مؤكدة'**
  String get healthAllergyClassConfirmed;

  /// No description provided for @healthAllergyClassIntolerance.
  ///
  /// In ar, this message translates to:
  /// **'عدم تحمّل'**
  String get healthAllergyClassIntolerance;

  /// No description provided for @healthAllergyClassAvoid.
  ///
  /// In ar, this message translates to:
  /// **'أتجنبه'**
  String get healthAllergyClassAvoid;

  /// No description provided for @healthRequestsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل'**
  String get healthRequestsTitle;

  /// No description provided for @healthRequestIntro.
  ///
  /// In ar, this message translates to:
  /// **'لن يُطبَّق أي تعديل قبل اعتماد أخصائيك.'**
  String get healthRequestIntro;

  /// No description provided for @healthRequestGoalSection.
  ///
  /// In ar, this message translates to:
  /// **'الهدف'**
  String get healthRequestGoalSection;

  /// No description provided for @healthRequestMedicationsSection.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get healthRequestMedicationsSection;

  /// No description provided for @healthRequestAllergiesSection.
  ///
  /// In ar, this message translates to:
  /// **'الحساسية'**
  String get healthRequestAllergiesSection;

  /// No description provided for @healthRequestMyRequestsSection.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get healthRequestMyRequestsSection;

  /// No description provided for @healthRequestChangeGoal.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل الهدف'**
  String get healthRequestChangeGoal;

  /// No description provided for @healthRequestAddMedication.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دواء'**
  String get healthRequestAddMedication;

  /// No description provided for @healthRequestAddAllergy.
  ///
  /// In ar, this message translates to:
  /// **'إضافة حساسية'**
  String get healthRequestAddAllergy;

  /// No description provided for @healthRequestGoalTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الهدف'**
  String get healthRequestGoalTitle;

  /// No description provided for @healthRequestMedicationTitleEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل دواء'**
  String get healthRequestMedicationTitleEdit;

  /// No description provided for @healthRequestAllergyTitleEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل حساسية'**
  String get healthRequestAllergyTitleEdit;

  /// No description provided for @healthRequestActionAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get healthRequestActionAdd;

  /// No description provided for @healthRequestActionEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get healthRequestActionEdit;

  /// No description provided for @healthRequestActionRemove.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get healthRequestActionRemove;

  /// No description provided for @healthRequestRemove.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get healthRequestRemove;

  /// No description provided for @healthRequestRemoveTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب حذف؟'**
  String get healthRequestRemoveTitle;

  /// No description provided for @healthRequestRemoveBody.
  ///
  /// In ar, this message translates to:
  /// **'سيراجع أخصائيك الحذف قبل أن يُطبَّق.'**
  String get healthRequestRemoveBody;

  /// No description provided for @healthRequestWithdraw.
  ///
  /// In ar, this message translates to:
  /// **'سحب الطلب'**
  String get healthRequestWithdraw;

  /// No description provided for @healthRequestWithdrawTitle.
  ///
  /// In ar, this message translates to:
  /// **'سحب هذا الطلب؟'**
  String get healthRequestWithdrawTitle;

  /// No description provided for @healthRequestWithdrawBody.
  ///
  /// In ar, this message translates to:
  /// **'لن يراه أخصائيك.'**
  String get healthRequestWithdrawBody;

  /// No description provided for @healthRequestStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار اعتماد الأخصائي'**
  String get healthRequestStatusPending;

  /// No description provided for @healthRequestStatusApproved.
  ///
  /// In ar, this message translates to:
  /// **'تمت الموافقة'**
  String get healthRequestStatusApproved;

  /// No description provided for @healthRequestStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'لم تُعتمد'**
  String get healthRequestStatusRejected;

  /// No description provided for @healthRequestStatusWithdrawn.
  ///
  /// In ar, this message translates to:
  /// **'سُحب'**
  String get healthRequestStatusWithdrawn;

  /// No description provided for @healthRequestPendingChip.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الاعتماد'**
  String get healthRequestPendingChip;

  /// No description provided for @healthRequestNoRequests.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات في آخر 60 يومًا.'**
  String get healthRequestNoRequests;

  /// No description provided for @healthRequestDecisionNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة أخصائيك: {note}'**
  String healthRequestDecisionNote(String note);

  /// No description provided for @healthRequestSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get healthRequestSend;

  /// No description provided for @healthRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلبك. لن يُطبَّق قبل اعتماد أخصائيك.'**
  String get healthRequestSent;

  /// No description provided for @healthRequestWithdrawnSnack.
  ///
  /// In ar, this message translates to:
  /// **'تم سحب الطلب.'**
  String get healthRequestWithdrawnSnack;

  /// No description provided for @healthRequestAlreadyPending.
  ///
  /// In ar, this message translates to:
  /// **'هناك طلب بانتظار الاعتماد لهذا العنصر بالفعل.'**
  String get healthRequestAlreadyPending;

  /// No description provided for @healthRequestAlreadyRecorded.
  ///
  /// In ar, this message translates to:
  /// **'هذه الحساسية مسجلة في ملفك بالفعل.'**
  String get healthRequestAlreadyRecorded;

  /// No description provided for @healthRequestNotPending.
  ///
  /// In ar, this message translates to:
  /// **'تم البتّ في هذا الطلب، ولا يمكن سحبه.'**
  String get healthRequestNotPending;

  /// No description provided for @healthRequestInvalid.
  ///
  /// In ar, this message translates to:
  /// **'راجع الحقول المحددة.'**
  String get healthRequestInvalid;

  /// No description provided for @healthRequestFieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get healthRequestFieldRequired;

  /// No description provided for @healthRequestFieldNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا'**
  String get healthRequestFieldNumber;

  /// No description provided for @healthRequestFieldRange.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا من {min} إلى {max}'**
  String healthRequestFieldRange(String min, String max);

  /// No description provided for @healthRequestFieldTooLong.
  ///
  /// In ar, this message translates to:
  /// **'{max} حرفًا كحد أقصى'**
  String healthRequestFieldTooLong(String max);

  /// No description provided for @healthRequestFieldNotAfterToday.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخًا بعد اليوم'**
  String get healthRequestFieldNotAfterToday;

  /// No description provided for @healthRequestFieldBeforeToday.
  ///
  /// In ar, this message translates to:
  /// **'اختر اليوم أو تاريخًا لاحقًا'**
  String get healthRequestFieldBeforeToday;

  /// No description provided for @healthRequestGoalType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الهدف'**
  String get healthRequestGoalType;

  /// No description provided for @healthRequestTargetWeight.
  ///
  /// In ar, this message translates to:
  /// **'الوزن المستهدف (كغ)'**
  String get healthRequestTargetWeight;

  /// No description provided for @healthRequestTargetDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الهدف'**
  String get healthRequestTargetDate;

  /// No description provided for @healthRequestChooseDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر تاريخًا'**
  String get healthRequestChooseDate;

  /// No description provided for @healthRequestActivity.
  ///
  /// In ar, this message translates to:
  /// **'مستوى النشاط'**
  String get healthRequestActivity;

  /// No description provided for @healthRequestTrainingDays.
  ///
  /// In ar, this message translates to:
  /// **'أيام التمرين في الأسبوع'**
  String get healthRequestTrainingDays;

  /// No description provided for @healthRequestTrainingLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى التمرين'**
  String get healthRequestTrainingLevel;

  /// No description provided for @healthRequestTrainingType.
  ///
  /// In ar, this message translates to:
  /// **'نوع التمرين'**
  String get healthRequestTrainingType;

  /// No description provided for @healthRequestDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل'**
  String get healthRequestDetails;

  /// No description provided for @healthRequestName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get healthRequestName;

  /// No description provided for @healthRequestDose.
  ///
  /// In ar, this message translates to:
  /// **'الجرعة'**
  String get healthRequestDose;

  /// No description provided for @healthRequestFrequency.
  ///
  /// In ar, this message translates to:
  /// **'عدد المرات'**
  String get healthRequestFrequency;

  /// No description provided for @healthRequestTiming.
  ///
  /// In ar, this message translates to:
  /// **'وقت التناول'**
  String get healthRequestTiming;

  /// No description provided for @healthRequestReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب الاستخدام'**
  String get healthRequestReason;

  /// No description provided for @healthRequestDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة الاستخدام'**
  String get healthRequestDuration;

  /// No description provided for @healthRequestUntilDate.
  ///
  /// In ar, this message translates to:
  /// **'حتى تاريخ'**
  String get healthRequestUntilDate;

  /// No description provided for @healthRequestAllergy.
  ///
  /// In ar, this message translates to:
  /// **'الحساسية'**
  String get healthRequestAllergy;

  /// No description provided for @healthRequestOtherText.
  ///
  /// In ar, this message translates to:
  /// **'صفها'**
  String get healthRequestOtherText;

  /// No description provided for @healthRequestClass.
  ///
  /// In ar, this message translates to:
  /// **'درجة الحساسية'**
  String get healthRequestClass;

  /// No description provided for @healthRequestNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get healthRequestNote;

  /// No description provided for @healthAllergyGroupTreeNuts.
  ///
  /// In ar, this message translates to:
  /// **'المكسرات'**
  String get healthAllergyGroupTreeNuts;

  /// No description provided for @healthAllergyGroupPeanuts.
  ///
  /// In ar, this message translates to:
  /// **'الفول السوداني'**
  String get healthAllergyGroupPeanuts;

  /// No description provided for @healthAllergyGroupMilk.
  ///
  /// In ar, this message translates to:
  /// **'الحليب ومشتقاته (اللاكتوز)'**
  String get healthAllergyGroupMilk;

  /// No description provided for @healthAllergyGroupEgg.
  ///
  /// In ar, this message translates to:
  /// **'البيض'**
  String get healthAllergyGroupEgg;

  /// No description provided for @healthAllergyGroupWheat.
  ///
  /// In ar, this message translates to:
  /// **'القمح والجلوتين'**
  String get healthAllergyGroupWheat;

  /// No description provided for @healthAllergyGroupSesame.
  ///
  /// In ar, this message translates to:
  /// **'السمسم'**
  String get healthAllergyGroupSesame;

  /// No description provided for @healthAllergyGroupFish.
  ///
  /// In ar, this message translates to:
  /// **'السمك'**
  String get healthAllergyGroupFish;

  /// No description provided for @healthAllergyGroupShellfish.
  ///
  /// In ar, this message translates to:
  /// **'القشريات والمأكولات البحرية'**
  String get healthAllergyGroupShellfish;

  /// No description provided for @healthAllergyGroupSoy.
  ///
  /// In ar, this message translates to:
  /// **'الصويا'**
  String get healthAllergyGroupSoy;

  /// No description provided for @healthAllergyGroupOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى (اكتبها)'**
  String get healthAllergyGroupOther;

  /// No description provided for @healthActivitySedentary.
  ///
  /// In ar, this message translates to:
  /// **'قليل الحركة'**
  String get healthActivitySedentary;

  /// No description provided for @healthActivityLight.
  ///
  /// In ar, this message translates to:
  /// **'نشاط خفيف'**
  String get healthActivityLight;

  /// No description provided for @healthActivityModerate.
  ///
  /// In ar, this message translates to:
  /// **'نشاط متوسط'**
  String get healthActivityModerate;

  /// No description provided for @healthActivityActive.
  ///
  /// In ar, this message translates to:
  /// **'نشيط'**
  String get healthActivityActive;

  /// No description provided for @healthActivityVeryActive.
  ///
  /// In ar, this message translates to:
  /// **'نشيط جدًا'**
  String get healthActivityVeryActive;

  /// No description provided for @healthTrainingBeginner.
  ///
  /// In ar, this message translates to:
  /// **'مبتدئ'**
  String get healthTrainingBeginner;

  /// No description provided for @healthTrainingIntermediate.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get healthTrainingIntermediate;

  /// No description provided for @healthTrainingAdvanced.
  ///
  /// In ar, this message translates to:
  /// **'متقدم'**
  String get healthTrainingAdvanced;

  /// No description provided for @healthTrainingStrength.
  ///
  /// In ar, this message translates to:
  /// **'تمارين قوة'**
  String get healthTrainingStrength;

  /// No description provided for @healthTrainingCardio.
  ///
  /// In ar, this message translates to:
  /// **'كارديو'**
  String get healthTrainingCardio;

  /// No description provided for @healthTrainingMixed.
  ///
  /// In ar, this message translates to:
  /// **'مختلط'**
  String get healthTrainingMixed;

  /// No description provided for @healthTrainingSports.
  ///
  /// In ar, this message translates to:
  /// **'رياضات'**
  String get healthTrainingSports;

  /// No description provided for @foodSearchTypeToSearch.
  ///
  /// In ar, this message translates to:
  /// **'اكتب حرفين على الأقل للبحث.'**
  String get foodSearchTypeToSearch;

  /// No description provided for @foodSearchResultsTitle.
  ///
  /// In ar, this message translates to:
  /// **'النتائج'**
  String get foodSearchResultsTitle;

  /// No description provided for @foodAllergyBadge.
  ///
  /// In ar, this message translates to:
  /// **'قد يحتوي مسبب حساسيتك'**
  String get foodAllergyBadge;

  /// No description provided for @reviewsTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات الأخصائي'**
  String get reviewsTitle;

  /// No description provided for @reviewsEntrySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ الملاحظات وأنجز المهام'**
  String get reviewsEntrySubtitle;

  /// No description provided for @reviewsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات بعد. ستظهر ملاحظات أخصائيك هنا.'**
  String get reviewsEmpty;

  /// No description provided for @reviewRatingOnTrack.
  ///
  /// In ar, this message translates to:
  /// **'على المسار'**
  String get reviewRatingOnTrack;

  /// No description provided for @reviewRatingSmallAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بسيط'**
  String get reviewRatingSmallAdjustment;

  /// No description provided for @reviewRatingReviewTogether.
  ///
  /// In ar, this message translates to:
  /// **'لنراجع معًا'**
  String get reviewRatingReviewTogether;

  /// No description provided for @reviewEdited.
  ///
  /// In ar, this message translates to:
  /// **'عدّلها أخصائيك'**
  String get reviewEdited;

  /// No description provided for @reviewKeyPointsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهم النقاط'**
  String get reviewKeyPointsTitle;

  /// No description provided for @reviewTasksTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهام'**
  String get reviewTasksTitle;

  /// No description provided for @reviewAcknowledge.
  ///
  /// In ar, this message translates to:
  /// **'فهمت'**
  String get reviewAcknowledge;

  /// No description provided for @reviewSeen.
  ///
  /// In ar, this message translates to:
  /// **'تم الاطلاع'**
  String get reviewSeen;

  /// Plan meal name (API meals[].name = breakfast).
  ///
  /// In ar, this message translates to:
  /// **'الفطور'**
  String get mealTypeBreakfast;

  /// Plan meal name (lunch).
  ///
  /// In ar, this message translates to:
  /// **'الغداء'**
  String get mealTypeLunch;

  /// Plan meal name (dinner).
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get mealTypeDinner;

  /// Plan meal name (snack).
  ///
  /// In ar, this message translates to:
  /// **'وجبة خفيفة'**
  String get mealTypeSnack;

  /// Plan meal of a type the app does not know.
  ///
  /// In ar, this message translates to:
  /// **'وجبة'**
  String get mealTypeOther;

  /// First alternative the nutritionist allowed in a meal.
  ///
  /// In ar, this message translates to:
  /// **'البديل المقترح: {food} ({grams} غرام)'**
  String homeSuggestedAlternative(String grams, String food);

  /// Shown when GET /me/meal-plan answers 204.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خطة مفعّلة بعد'**
  String get planEmptyTitle;

  /// Shown when there is no active plan.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر خطتك هنا فور تفعيلها من أخصائي التغذية.'**
  String get planEmptyBody;

  /// Log meal: the plan has no meal for today.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد وجبات في خطتك لهذا اليوم'**
  String get planNoMealToday;

  /// Week of the plan since its start date.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع {week} من الخطة'**
  String weeklyPlanWeekNumber(String week);

  /// Under the day totals on the weekly plan.
  ///
  /// In ar, this message translates to:
  /// **'خطتك كما وضعها أخصائي التغذية'**
  String get weeklyPlanFromNutritionist;

  /// Meal detail chip (the API has no meal times).
  ///
  /// In ar, this message translates to:
  /// **'من خطة أخصائي التغذية'**
  String get mealDetailFromPlan;

  /// Weekly plan: the selected day (date already localized).
  ///
  /// In ar, this message translates to:
  /// **'خطة يوم {date}'**
  String weeklyPlanDayOf(String date);

  /// Semantics label of the nutritionist avatar icon.
  ///
  /// In ar, this message translates to:
  /// **'صورة الأخصائي'**
  String get nutritionistAvatarLabel;

  /// Semantics label of the patient avatar icon.
  ///
  /// In ar, this message translates to:
  /// **'صورة الحساب'**
  String get patientAvatarLabel;

  /// Inbox day header for yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get notificationsYesterday;

  /// Inbox row time under a minute old.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get notificationsJustNow;

  /// Inbox row time in minutes. count drives the plural; countText is the number as shown.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منذ دقيقة} =2{منذ دقيقتين} few{منذ {countText} دقائق} other{منذ {countText} دقيقة}}'**
  String notificationsMinutesAgo(num count, String countText);

  /// Inbox row time in hours (same day). count drives the plural; countText is the number as shown.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منذ ساعة} =2{منذ ساعتين} few{منذ {countText} ساعات} other{منذ {countText} ساعة}}'**
  String notificationsHoursAgo(num count, String countText);

  /// Button under the inbox that reads the next, older page (API guide 10.2).
  ///
  /// In ar, this message translates to:
  /// **'عرض الإشعارات الأقدم'**
  String get notificationsLoadOlder;

  /// Android notification channel name for the weekly weigh-in reminder (API guide 10.6).
  ///
  /// In ar, this message translates to:
  /// **'تذكير القياس الأسبوعي'**
  String get weighInReminderChannel;

  /// Title of the local weekly weigh-in reminder.
  ///
  /// In ar, this message translates to:
  /// **'حان موعد قياسك الأسبوعي'**
  String get weighInReminderTitle;

  /// Body of the local weekly weigh-in reminder.
  ///
  /// In ar, this message translates to:
  /// **'سجّل وزنك الآن بعد الاستيقاظ لتبقى متابعتك دقيقة.'**
  String get weighInReminderBody;

  /// Notification settings: what the nutritionist category covers (API guide 10.3).
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات أخصائي التغذية الجديدة وتعديلاتها.'**
  String get notificationSettingsNutritionistDesc;

  /// Snack bar when a notification setting could not be saved on the server.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ الإعداد. تحقق من اتصالك ثم حاول مرة أخرى.'**
  String get notificationSettingsSaveFailed;
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
