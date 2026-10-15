// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'HealthyLife AI';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDone => 'تم';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get commonEmptyTitle => 'لا توجد بيانات لعرضها بعد';

  @override
  String get commonEmptyBody => 'ستظهر المعلومات هنا فور توفرها.';

  @override
  String get commonErrorTitle => 'حدث خطأ ما';

  @override
  String get commonErrorBody => 'تعذّر تحميل البيانات. حاول مرة أخرى.';

  @override
  String get commonOfflineTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get commonOfflineBody => 'تحقق من اتصالك بالشبكة ثم أعد المحاولة.';

  @override
  String get commonSuccess => 'تم بنجاح';

  @override
  String get failureNetwork =>
      'تعذّر الاتصال بالخادم. تحقّق من شبكة الإنترنت وحاول مجدداً.';

  @override
  String get failureTimeout => 'استغرق الاتصال وقتاً طويلاً. حاول مرة أخرى.';

  @override
  String get failureServer => 'خدمة غير متاحة حالياً. حاول لاحقاً.';

  @override
  String get failureUnauthorized => 'انتهت صلاحية الجلسة. سجّل الدخول مجدداً.';

  @override
  String get failureNotFound => 'العنصر المطلوب غير موجود.';

  @override
  String get failureValidation => 'تحقق من البيانات المدخلة وأعد المحاولة.';

  @override
  String get failureCache => 'تعذّر قراءة البيانات المحفوظة محلياً.';

  @override
  String get failureUnexpected => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get validationRequired => 'هذا الحقل مطلوب';

  @override
  String get validationInvalidEmail => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String validationTooShort(int min) {
    return 'يجب ألا يقل عن $min أحرف';
  }

  @override
  String validationTooLong(int max) {
    return 'يجب ألا يتجاوز $max حرفاً';
  }

  @override
  String get validationMissingUppercase => 'أضف حرفاً كبيراً واحداً على الأقل';

  @override
  String get validationMissingDigit => 'أضف رقماً واحداً على الأقل';

  @override
  String get validationMissingSpecial => 'أضف رمزاً خاصاً واحداً على الأقل';

  @override
  String get validationMismatch => 'القيمتان غير متطابقتين';

  @override
  String get validationInvalidNumber => 'أرقاماً صحيحة فقط';

  @override
  String validationOutOfRange(num min, num max) {
    return 'القيمة يجب أن تكون بين $min و $max';
  }

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج من الحساب';

  @override
  String get logoutConfirmMessage =>
      'سيتم إنهاء الجلسة بأمان من هذا الجهاز بعد التأكد من مزامنة قياساتك وسجلاتك الأخيرة.';

  @override
  String get commonLogout => 'تسجيل الخروج';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navPlan => 'الخطة';

  @override
  String get navProgress => 'التقدم';

  @override
  String get navAccount => 'حسابي';

  @override
  String get navLogMealTooltip => 'تسجيل وجبة جديدة';

  @override
  String get notificationCategoryAll => 'الكل';

  @override
  String get notificationCategoryMeals => 'الوجبات';

  @override
  String get notificationCategoryMeasurements => 'القياسات';

  @override
  String get notificationCategoryPlanUpdates => 'تحديثات الخطة';

  @override
  String get notificationCategoryNutritionist => 'الأخصائي';

  @override
  String get notificationCategoryOther => 'الأخرى';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String get aboutTransparencyTitle => 'الشفافية والمعايير الطبية';

  @override
  String get aboutCertifiedRegulations => 'لوائح معتمدة';

  @override
  String get aboutSessionAccountTitle => 'منطقة الجلسة والحساب';

  @override
  String get aboutCopyright =>
      'HealthyLife Clinical Suite © 2026 • جميع الحقوق محفوظة';

  @override
  String get aboutBrandName => 'حياة صحية';

  @override
  String get aboutTagline => 'منصة المتابعة والتغذية العلاجية للمرضى';

  @override
  String get aboutVersion => 'الإصدار 1.0.0 (Build 240)';

  @override
  String get aboutDescription =>
      'تطبيق معتمد ومصمم لدعمك بالتعاون المباشر مع أخصائيك المعتمدة لتحقيق أهدافك الصحية المستدامة.';

  @override
  String get aboutPrivacyPolicyTitle => 'سياسة الخصوصية وأمان البيانات الصحية';

  @override
  String get aboutPrivacyPolicySubtitle =>
      'تشفير سريري عالي المستوى لملفك الغذائي';

  @override
  String get aboutMedicalTermsTitle => 'الشروط والأحكام الطبية';

  @override
  String get aboutMedicalTermsSubtitle => 'إرشادات متابعة خطط الرعاية الصحية';

  @override
  String get aboutLicensesTitle => 'تراخيص الهيئة الطبية والاعتماد';

  @override
  String get aboutLicensesSubtitle => 'سجل الامتثال الطبي الموثق رقم #A-8841';

  @override
  String get aboutSupportTitle => 'الدعم الفني ومساعدة التطبيق';

  @override
  String get aboutSupportSubtitle => 'مساعدة متواصلة للاستفسارات التقنية';

  @override
  String get aboutStandardHealthProtection => 'حماية صحية قياسية';

  @override
  String get aboutEncryptionNote =>
      'بياناتك مشفرة ومحمية وفق معايير الخصوصية الصحية المعتمدة لمزامنة آمنة مع ملفك السريري.';

  @override
  String get aboutLogoutNote =>
      'سيتم إنهاء جلستك بأمان، مع الاحتفاظ بجميع سجلاتك وقياساتك في السجلات الطبية دون أي فقدان للبيانات.';

  @override
  String get achievementsFullWeek => 'أسبوع كامل من الالتزام';

  @override
  String get achievementsSevenDayStreak => '7 أيام تسجيل متواصل';

  @override
  String get achievementsFirstMeal => 'أول وجبة مسجّلة';

  @override
  String get achievementsHydration => 'شرب الماء بانتظام';

  @override
  String get achievementsThirtyDays => '30 يوم التزام';

  @override
  String get achievementsFirstWeightGoal => 'هدف الوزن الأول';

  @override
  String get achievementsTitle => 'إنجازاتك';

  @override
  String get achievementsEncouragement => 'استمري، كل خطوة صغيرة تُحسب';

  @override
  String get activationWelcome => 'مرحباً بك في HealthyLife';

  @override
  String get activationSubtitle =>
      'فعّلي وصولك الفوري إلى برنامج الرعاية السريرية';

  @override
  String get activationCertified => 'معتمدة';

  @override
  String get activationSpecialistRole => 'أخصائي التغذية العلاجية وإدارة الأيض';

  @override
  String get activationInvitedBy =>
      'تمت دعوتك بواسطة أخصائي التغذية لربط ملفك الصحي وبدء خطتك الغذائية العلاجية المخصصة مباشرة.';

  @override
  String get activationPrefilledNote =>
      'تم إدخال بياناتك الأساسية مسبقاً من قبل العيادة';

  @override
  String get activationNewPassword => 'كلمة المرور الجديدة';

  @override
  String get activationConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordRuleMinLength => '8 أحرف أو أكثر';

  @override
  String get passwordRuleUppercase => 'حرف كبير واحد على الأقل (A-Z)';

  @override
  String get passwordRuleDigit => 'رقم واحد على الأقل (0-9)';

  @override
  String get activationCta => 'تفعيل الحساب وبدء الخطة';

  @override
  String get activationEncryptedNote =>
      'بياناتك الصحية مشفرة ومحمية وفق لوائح الامتثال الطبي';

  @override
  String get activationLinkValid => 'رابط ساري وعامل';

  @override
  String get activationLinkExpired => 'رابط منتهٍ / مُستخدم';

  @override
  String get barcodeTitle => 'امسح باركود المنتج';

  @override
  String get barcodeFound => 'تم العثور على المنتج ✓';

  @override
  String get barcodeHint => 'وجّه الكاميرا نحو الباركود — اضغط للمحاكاة';

  @override
  String beetaiWelcome(String known, String name) {
    String _temp0 = intl.Intl.selectLogic(
      known,
      {
        'yes':
            'أهلاً $name! أنا BeetAI، اسألني عن أي شيء يخص خطتك الغذائية أو سجّل وجبة بسرعة 🌿',
        'other':
            'أهلاً! أنا BeetAI، اسألني عن أي شيء يخص خطتك الغذائية أو سجّل وجبة بسرعة 🌿',
      },
    );
    return '$_temp0';
  }

  @override
  String get beetaiLoggedReply =>
      'تم تسجيل ذلك في سجلك، هل تودين إضافة أي تفاصيل أخرى؟';

  @override
  String get beetaiSubtitle => 'مساعدك الذكي';

  @override
  String get beetaiVoiceInput => 'إدخال صوتي';

  @override
  String get beetaiInputHint => 'اسأل BeetAI أو سجّل وجبة…';

  @override
  String get beetaiVoiceMessage => 'رسالة صوتية';

  @override
  String get dailyLogMealDeleted => 'تم حذف الوجبة من سجل اليوم';

  @override
  String get commonUndo => 'تراجع';

  @override
  String get dailyLogTitle => 'سجل اليوم';

  @override
  String get commonNotifications => 'الإشعارات';

  @override
  String get dailyLogWeeklyPlanTooltip => 'استعراض الخطة الأسبوعية';

  @override
  String get dailyLogActiveDay => 'اليوم النشط';

  @override
  String get demoDateSunday21Sep2025 => 'الأحد، 21 سبتمبر 2025';

  @override
  String get dailyLogLoggedMeals => 'الوجبات المسجلة';

  @override
  String get dailyLogTotalEnergy => 'مجموع الطاقة المستهلكة';

  @override
  String commonKcalValue(Object value) {
    return '$value سعرة';
  }

  @override
  String dailyLogOverGoal(Object value) {
    return 'تجاوزت الهدف بـ $value سعرة';
  }

  @override
  String get dailyLogBalancedEnergy => 'توازن الطاقة اليومي المتزن';

  @override
  String dailyLogPercentOfRecommended(Object percent) {
    return '$percent٪ من الموصى به';
  }

  @override
  String get dailyLogOverGoalReassurance =>
      'لا بأس، الأرقام مرشد هادئ وليست حكماً، وغداً يوم جديد.';

  @override
  String get dailyLogVariedChoices =>
      'خياراتك اليوم متنوعة ومغذية، تذكّر أن الأرقام مرشد هادئ لدعم نشاطك وصحتك.';

  @override
  String get dailyLogTimeline => 'التسلسل الزمني';

  @override
  String get dailyLogPreviewEmpty => 'معاينة السجل الفارغ';

  @override
  String get dailyLogOffPlanFree => 'خارج الخطة • إضافة حرة';

  @override
  String get dailyLogFromPlan => 'من الخطة الغذائية';

  @override
  String commonGramsValue(Object value) {
    return '$value غرام';
  }

  @override
  String get dailyLogDeleteMeal => 'حذف الوجبة';

  @override
  String get dailyLogDietitianReminder => 'تذكير أخصائي التغذية';

  @override
  String get dailyLogFlexibilityNote =>
      'المرونة جزء أساسي من النجاح المستدام. تدوينك اليومي بصدق هو الخطوة الأهم لدعم رعايتك الذاتية.';

  @override
  String get dailyLogNoMealsYet => 'لم تُسجّل أي وجبة بعد';

  @override
  String get errorStateTitle => 'حدث خطأ';

  @override
  String get errorStateQuickCheck => 'قيد الفحص السريع';

  @override
  String get errorStateServerStatus => 'حالة خوادم HealthyLife';

  @override
  String get errorStateUnexpected => 'حدث خطأ غير متوقع';

  @override
  String get errorStateMessage =>
      'عذراً، لم نتمكن من مزامنة هذه الصفحة في الوقت الراهن. خذ نفساً هادئاً، ونرجو منك المحاولة مرة أخرى.';

  @override
  String get errorStateDataSafeTitle => 'بياناتك الصحية بأمان تام';

  @override
  String get errorStateDataSafeBody =>
      'سجلات الوجبات، تتبع السعرات، وتاريخك الحيوي لم تتأثر إطلاقاً ومحفوظة سحابياً بنجاح.';

  @override
  String get errorStateTipsTitle => 'إرشادات سريعة للحل';

  @override
  String get errorStateTipsBody =>
      'يُرجى التحقق من اتصال شبكة الإنترنت أو تكرار الطلب بعد بضع ثوانٍ ليستجيب النظام.';

  @override
  String get errorStateRetryNow => 'إعادة المحاولة الآن';

  @override
  String get commonBackToHome => 'العودة للرئيسية';

  @override
  String get measurementGuideTitle => 'دليل القياسات';

  @override
  String get firstMeasurementHeadline => 'سجّل قياسك التالي لنرسم لك خط التقدم';

  @override
  String get firstMeasurementExplanation =>
      'يتطلب رسم منحنى التقدم قياسين على الأقل لإظهار اتجاه التغير الحقيقي بدقة وموضوعية. تسجيلك القادم سيفعّل المخطط البياني فوراً.';

  @override
  String get firstMeasurementLogNew => 'سجّل قياساً جديداً';

  @override
  String get firstMeasurementBackToPlan => 'العودة إلى خطتي اليومية';

  @override
  String get firstMeasurementBaseline => 'نقطة البداية المعتمدة';

  @override
  String get firstMeasurementInitial => 'القياس الأولي المسجل';

  @override
  String commonKgValue(Object value) {
    return '$value كغ';
  }

  @override
  String get demoDateFriday19Sep2025 => 'الجمعة، ١٩ سبتمبر ٢٠٢٥';

  @override
  String get firstMeasurementBaselineSaved =>
      'تم توثيق نقطة البداية بنجاح في ملفك الصحي.';

  @override
  String get firstMeasurementJourneyNote =>
      'قياس واحد يحدد نقطة انطلاقك، والقياس القادم هو ما يرسم رحلتك مع أخصائي التغذية خطوة بخطوة.';

  @override
  String get firstMeasurementSuggestedTime => 'توقيت القياس المقترح';

  @override
  String get firstMeasurementMorningTip =>
      'صباحاً بعد الاستيقاظ مباشرة لقراءة مستقرة';

  @override
  String get firstMeasurementIllustratedGuide => 'دليل القياس المصوّر 📐';

  @override
  String get firstMeasurementAwaitingSecond => 'بانتظار القياس الثاني';

  @override
  String get measurementPromptFirstHeadline =>
      'سجّل قياسك الأول لنحدد نقطة انطلاقك';

  @override
  String get measurementPromptFirstBody =>
      'قياسك الأول هو نقطة البداية، وبعده يكفي قياس واحد كل أسبوع لنرسم منحنى تقدّمك.';

  @override
  String get measurementPromptAwaitingFirst => 'بانتظار القياس الأول';

  @override
  String get measurementPromptWeeklyBadge => 'موعد القياس الأسبوعي';

  @override
  String get measurementPromptLatest => 'آخر قياس مسجل';

  @override
  String get measurementPromptWeeklyNote =>
      'مرّ أسبوع على هذا القياس، وحان وقت القياس التالي.';

  @override
  String get measurementPromptWeeklyHeadline => 'حان موعد قياسك الأسبوعي';

  @override
  String get measurementPromptWeeklyBody =>
      'قياس واحد كل أسبوع يُبقي منحنى تقدّمك دقيقاً ومحدّثاً.';

  @override
  String get measurementPromptAwaitingNew => 'بانتظار القياس الجديد';

  @override
  String get measurementPromptViewProgress => 'عرض تقدّمي الآن';

  @override
  String get followUpSuccessfully => 'بنجاح';

  @override
  String get followUpStatus => 'حالة المتابعة';

  @override
  String get followUpTwelveWeeks => '12 أسبوع';

  @override
  String get followUpMeasurementsLogged => 'القياسات المسجلة';

  @override
  String get followUpMealAdherence => 'الالتزام بالوجبات';

  @override
  String get followUpEndedTitle => 'انتهت المتابعة';

  @override
  String get followUpPlanCompleted => 'اكتمال خطة المتابعة السريرية';

  @override
  String get followUpPeriodEnded => 'انتهت فترة متابعتك الحالية';

  @override
  String get followUpEndedMessage =>
      'نتمنى أنك استمتعت بخطتك الصحية وحققت أهدافك! لقد انتهت فترة المتابعة الحالية مع أخصائي التغذية. للتجديد أو لاستكمال رحلتك العلاجية والحصول على خطة جديدة، يمكنك التواصل مباشرة وبكل سهولة.';

  @override
  String get followUpSupervisor => 'مشرفك';

  @override
  String get followUpSupervisingSpecialist =>
      'أخصائي التغذية العلاجية المشرف عليك';

  @override
  String get followUpRecordsSafe =>
      'سجلاتك وقياساتك السابقة محفوظة بأمان تام في ملفك الصحي، ويمكن استئناف الخطة والمتابعة فوراً بمجرد التجديد.';

  @override
  String get followUpContactWhatsApp => 'التواصل مع أخصائي التغذية عبر واتساب';

  @override
  String get followUpViewFinalReport => 'استعراض ملخص التقرير النهائي للمتابعة';

  @override
  String get followUpTerms => 'شروط الخدمة وسياسة الخصوصية للملفات الطبية';

  @override
  String get foodSearchFilterFruitVeg => 'فواكه وخضار';

  @override
  String get foodSearchFilterCarbsGrains => 'نشويات وحبوب';

  @override
  String get foodSearchFilterProteins => 'بروتينات';

  @override
  String get foodSearchAteOffPlan => 'أكلت شيئاً خارج الخطة';

  @override
  String get foodSearchNoWorries => 'لا داعي للقلق، نحن معك';

  @override
  String get foodSearchSafeFollowUp => 'متابعة آمنة';

  @override
  String get foodSearchHonestLogging =>
      'تسجيل كل ما تناولته بصدق يمكّن أخصائي التغذية من المتابعة الدقيقة وضبط خطتك بسلاسة دون حرمان.';

  @override
  String get foodSearchHint => 'ابحث بالاسم العربي أو الإنجليزي';

  @override
  String get foodSearchClear => 'مسح البحث';

  @override
  String get foodSearchScanBarcode => 'مسح الباركود';

  @override
  String get foodSearchSuggested => 'الأطعمة المقترحة';

  @override
  String foodSearchPer100g(Object amount) {
    return 'لكل $amount غ';
  }

  @override
  String get foodSearchEmptyCategory => 'لا توجد أطعمة في هذا التصنيف';

  @override
  String foodSearchNoResults(Object query) {
    return 'لا نتائج مطابقة لـ \"$query\"';
  }

  @override
  String get foodSearchTryAnother =>
      'جرّبي كلمة أخرى أو اطلبي إضافة الصنف من الأسفل';

  @override
  String get foodSearchNotFound => 'لم تجد ما تبحث عنه؟';

  @override
  String get foodAllergyCheckUnavailable =>
      'تنبيهات الحساسية متوقفة الآن: تعذّرت قراءة ملفك الصحي.';

  @override
  String foodSearchSpecialistWaiting(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'أخصائيك $name بانتظارك',
        'female': 'أخصائيتك $name بانتظارك',
        'unknown': 'أخصائي التغذية بانتظارك',
        'other': '$name بانتظارك',
      },
    );
    return '$_temp0';
  }

  @override
  String get foodSearchSendItemNote =>
      'يمكنك إرسال اسم الصنف أو صورته لأخصائي التغذية ليضيفه إلى قاعدة بياناتك فوراً، أو ليقدّر مكوناته الأساسية دون انقطاع عن أهدافك.';

  @override
  String get foodSearchRequestViaWhatsApp => 'طلب إضافة صنف جديد عبر واتساب';

  @override
  String get foodSearchManualEstimate => 'تقدير السعرات يدوياً (سريع)';

  @override
  String get foodSearchManualEstimateName => 'تقدير يدوي';

  @override
  String get foodSearchRequestNewItem => 'طلب إضافة صنف جديد';

  @override
  String get foodSearchWhatsAppSheetBody =>
      'أرسل اسم الصنف أو صورته لأخصائي التغذية عبر واتساب، وستتم إضافته إلى قاعدة بياناتك بأسرع وقت ممكن.';

  @override
  String get commonOpenWhatsApp => 'فتح واتساب';

  @override
  String get consentClauseStorageTitle => 'كيف تُحفظ بياناتك الصحية؟';

  @override
  String get consentClauseStorageBody =>
      'تشفير كامل وفق أعلى معايير الخصوصية الصحية السريرية (HIPAA standards). تُخزَّن السجلات على خوادم طبية معزولة لا يمكن لأي طرف ثالث أو شركة إعلانات الوصول إليها تحت أي ظرف.';

  @override
  String get consentClauseAccessTitle => 'من يمكنه الاطلاع عليها؟';

  @override
  String get consentClauseAccessBody =>
      'أخصائي التغذية العلاجية المعتمد على حسابك فقط، عبر نظام مراجعة سريري مشفر. لا تُشارك بياناتك مع أي جهة أخرى، ولا تُستخدم لأي غرض تسويقي.';

  @override
  String get consentClauseRevokeTitle => 'حقك الكامل في إلغاء الموافقة';

  @override
  String get consentClauseRevokeBody =>
      'يمكنك سحب موافقتك في أي وقت من الحساب ← الخصوصية. سيؤدي ذلك إلى إيقاف تخصيص الخطة الغذائية تلقائياً حتى تجديد الموافقة، دون التأثير على سجلاتك المحفوظة.';

  @override
  String get consentExitTitle => 'الخروج من إعداد ملفك الصحي؟';

  @override
  String get consentExitMessage =>
      'لن تتمكني من متابعة رحلتك العلاجية أو الوصول لخطتك الغذائية قبل الموافقة على شروط الخصوصية الصحية.';

  @override
  String get consentExitConfirm => 'الخروج الآن';

  @override
  String get consentExitCancel => 'متابعة الموافقة';

  @override
  String get consentClausesHeader => 'بنود الخصوصية ومسؤولية الحفظ';

  @override
  String consentClausesCount(Object count) {
    return '$count بنود رئيسية';
  }

  @override
  String get consentReadFullDocument => 'قراءة وثيقة الخصوصية السريرية الكاملة';

  @override
  String get consentVerified => 'موثّق';

  @override
  String get consentCta => 'متابعة إعداد خطتي الصحية';

  @override
  String get consentPleaseAgree =>
      'يُرجى الموافقة على الشروط السريرية للمتابعة';

  @override
  String get consentCharterTitle => 'ميثاق الخصوصية التغذوية';

  @override
  String get consentConfidentialVerified => 'موثّق سري';

  @override
  String get consentDataUseNote =>
      'بياناتك (سجل الوجبات، القياسات، والحالة الصحية) تصل لأخصائي التغذية المتابع لك فقط وتُستخدم لبناء خطتك الغذائية ومتابعة تقدمك السريري بأمان.';

  @override
  String get consentEncryptionShort =>
      'مشفّرة بنظام bit-256 ومتوافقة مع المعايير الصحية السريرية (HIPAA).';

  @override
  String get consentTitle => 'الموافقة على استخدام البيانات الصحية';

  @override
  String get consentProtectionSystem => 'منظومة الحماية السريرية الذكية';

  @override
  String get consentBeforeWeStart => 'قبل أن نبدأ رحلتك الصحية';

  @override
  String get consentCommitment =>
      'نحن نلتزم بحماية خصوصية بياناتك الصحية والسريرية بأقصى درجات الشفافية والأمان.';

  @override
  String get consentAesNote =>
      'بياناتك الطبية مشفرة بنظام bit AES-256 من لحظة إدخالها';

  @override
  String get consentCheckbox =>
      'قرأت ووافقت على شروط مشاركة البيانات بسياسة الخصوصية الصحية.';

  @override
  String get consentRevocable =>
      'موافقتك قابلة للتعديل أو الإلغاء فوراً في أي وقت.';

  @override
  String get healthRecordTitle => 'السجل الطبي';

  @override
  String get healthRecordAllergies => 'الحساسية والموانع';

  @override
  String get healthRecordBadges => 'الأوسمة وسجل الإنجازات';

  @override
  String get healthRecordBadgesUnlocked => '3 أوسمة مفتوحة';

  @override
  String get healthRecordBadgeFirstGoal => 'الهدف الأول';

  @override
  String get healthRecordBadgeFirstGoalDesc => 'تسجيل أول قياس وزني بنجاح';

  @override
  String get healthRecordBadgeIronCommitment => 'التزام حديدي';

  @override
  String get healthRecordBadgeIronCommitmentDesc => '7 أيام متواصلة من التوثيق';

  @override
  String get healthRecordBadgeWaterFriend => 'صديق الماء';

  @override
  String get healthRecordBadgeWaterFriendDesc =>
      'شرب 2.5 لتر لـ 5 أيام متتالية';

  @override
  String get healthRecordBadgeLose5kg => 'خسارة 5 كجم';

  @override
  String get healthRecordBadgeLose5kgDesc => 'باقي 1.2 كجم للفتح';

  @override
  String get healthRecordShareSummary => 'مشاركة الملخص والإنجازات مع الأخصائي';

  @override
  String get healthRecordActiveNow => 'نشط الآن';

  @override
  String get healthRecordAgeFileCode => '26 سنة • كود الملف: ';

  @override
  String get healthRecordLevel => 'المستوى 3: بطل الالتزام';

  @override
  String get healthRecordExcellentWeek => 'أداء ممتاز خلال الأسبوع الحالي';

  @override
  String healthRecordPoints(Object points) {
    return '$points / 1000 ن';
  }

  @override
  String get healthRecordPointsToNext => 'باقي 250 نقطة للوصول للمستوى الرابع';

  @override
  String healthRecordPercentComplete(Object percent) {
    return '$percent% مكتمل';
  }

  @override
  String get healthRecordCurrentGoal => 'الهدف الصحي الاستراتيجي الحالي';

  @override
  String get healthRecordMedications => 'الأدوية والمكملات اليومية المعتمدة';

  @override
  String get healthRecordActive => 'نشط';

  @override
  String get commonViewDetails => 'عرض التفاصيل';

  @override
  String get offlineWriteDropped =>
      'لم يقبل الخادم قياساً سجّلته دون اتصال، ولم يُحفظ.';

  @override
  String get healthRecordCertified => 'السجل الطبي المعتمد';

  @override
  String get healthRecordDiagnosesNote =>
      'التشخيصات والمحاذير لتخصيص خطتك بدقة';

  @override
  String get healthRecordRequestChange =>
      'طلب تعديل أو إضافة تقرير إلى السجل الطبي';

  @override
  String healthRecordStreakDays(Object days) {
    return '$days يوماً متتالياً من الالتزام التام!';
  }

  @override
  String get healthRecordStreakNote =>
      'تسجيل الوجبات والنشاط الحركي اليومي بدقة، حافظ على شعلة الحماس!';

  @override
  String get healthRecordDone => 'تم الإنجاز';

  @override
  String get healthSyncTitle => 'ربط تطبيق الصحة';

  @override
  String get healthSyncConnected => 'تم الربط بنجاح';

  @override
  String get healthSyncConnectPrompt => 'اربطي تطبيق الصحة';

  @override
  String get healthSyncBody =>
      'ربط Apple Health أو Google Fit يتيح لأخصائي التغذية متابعة نشاطك ومعدل ضربات قلبك تلقائياً دون إدخال يدوي، ويحسّن دقة خطتك الغذائية.';

  @override
  String get healthSyncConnectNow => 'ربط الآن';

  @override
  String get healthSyncBackToProgress => 'العودة للتقدّم';

  @override
  String get homeMealBreakfast => 'الفطور';

  @override
  String get homeBreakfastTime => '08:00 صباحاً';

  @override
  String get homeBreakfastAlternative => 'البديل المقترح: 100g جبنة قريش';

  @override
  String get homeItemTwoBoiledEggs => '2 بيضة مسلوقة';

  @override
  String get homeItemOatBread => '1 رغيف خبز شوفان';

  @override
  String get homeItemCucumberTomatoes => 'خيار وطماطم كرزية';

  @override
  String get homeItemFresh => 'طازج';

  @override
  String get homeMealLunch => 'الغداء';

  @override
  String get homeLunchTime => '02:30 ظهراً';

  @override
  String get homeItemGrilledChicken => 'صدر دجاج مشوي';

  @override
  String get homeItemBrownRice => 'أرز أسمر مطبوخ على البخار';

  @override
  String get homeItemGreenSalad => 'سلطة خضراء مع متبلة زيت زيتون';

  @override
  String get homeItemLargePlate => 'طبق كبير';

  @override
  String get homeDinnerTitle => 'العشاء - 08:00 مساءً';

  @override
  String get homeDinnerSubtitle => 'خفيف وخالٍ - 320 سعرة حرارية تقريباً';

  @override
  String get homeItemGreekYogurt => 'زبادي يوناني';

  @override
  String get homeItemSauteedVeg => 'خضار سوتيه';

  @override
  String get homeItemBrownToast => 'خبز توست أسمر';

  @override
  String get homeEveningSnack => 'سناك المساء';

  @override
  String get homeEveningSnackSubtitle => 'فاكهة موسمية (120g)';

  @override
  String homeSyncedItems(Object count) {
    return 'تمت مزامنة $count عنصر بنجاح';
  }

  @override
  String get homeOnlineNow => 'أنت متصل الآن';

  @override
  String get homeTapToSync => 'اضغط للمزامنة والعودة للاتصال';

  @override
  String get homeOnlineTapPreview => 'متصل — اضغط لمعاينة وضع عدم الاتصال';

  @override
  String homeGreeting(String known, String name) {
    String _temp0 = intl.Intl.selectLogic(
      known,
      {
        'yes': 'مرحباً $name 👋',
        'other': 'مرحباً 👋',
      },
    );
    return '$_temp0';
  }

  @override
  String get homeAdherenceToday => 'الالتزام اليوم';

  @override
  String get homeDailyMealPath => 'المسار اليومي للوجبات';

  @override
  String homeMealsLogged(Object logged, Object total) {
    return '$logged من $total وجبات مسجلة';
  }

  @override
  String get homeMealSchedule => 'جدول الوجبات';

  @override
  String homeTargetKcal(Object value) {
    return '$value سعرة مستهدفة';
  }

  @override
  String get homeAwaitingSync => 'بانتظار المزامنة';

  @override
  String get homeAwaitingLog => 'بانتظار التسجيل';

  @override
  String get homeLogged => 'تم التسجيل';

  @override
  String get homeAlternativeAvailable => 'بديل متاح';

  @override
  String commonCaloriesValue(Object value) {
    return '$value سعرة حرارية';
  }

  @override
  String get homeCompletedOnTime => 'مكتمل في الموعد';

  @override
  String get homeLogMeal => 'تسجيل الوجبة';

  @override
  String get homeHydrationTip =>
      'شرب كوبين من الماء قبل كل وجبة يدعم الحرق المنتظم ويساعدك على الشعور بالشبع الهادئ. أنت تسيرين بوتيرة ممتازة!';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageSave => 'حفظ اللغة المختارة';

  @override
  String get languageFooter => 'HealthyLife Care Portal — النسخة 2.4.0';

  @override
  String get languageCustomizeInterface => 'تخصيص الواجهة';

  @override
  String get languageChooseTitle => 'اختر لغة التطبيق';

  @override
  String get languageChooseBody =>
      'اختر لغة العرض المفضلة لمتابعة خطتك الغذائية، مواعيد الاستشارات، وسجلاتك الصحية بكل وضوح وسهولة.';

  @override
  String get languageCurrentBadge => 'اللغة الحالية';

  @override
  String get languageEffectTitle => 'تأثير التغيير على تجربة الاستخدام';

  @override
  String get languageEffectBody =>
      'عند تغيير اللغة، سيتم تحديث اتجاه واجهة التطبيق بالكامل تلقائياً (RTL للغة العربية و LTR للغة الإنجليزية) لضمان تجربة تصفح طبيعية ومريحة.';

  @override
  String get logMealTitle => 'تسجيل وجبة';

  @override
  String get logMealIntro =>
      'تسجيل ما تناولته بصدق هو خطوتك الأولى نحو نتائج مستدامة. أخصائي التغذية هنا لدعمك دائماً دون أي تقييم.';

  @override
  String get logMealPlannedBadge => 'الوجبات المعتمدة';

  @override
  String get logMealFromPlanTitle => 'سجّلت وجبة من خطتي';

  @override
  String get logMealFromPlanDesc =>
      'تأكيد سريع لتناول إحدى وجباتك المجدولة في جدول اليوم (فطور، سناك، غداء، عشاء) مع إمكانية تعديل البدائل المعتمدة.';

  @override
  String get logMealFromPlanNote => 'مطابقة تلقائية للسعرات والمكونات المجدولة';

  @override
  String get logMealFromPlanNote2 =>
      'استبدال ذكي للبدائل المتكافئة بنقرة واحدة';

  @override
  String get logMealFromPlanFooter => 'المتابعة لاختيار الوجبة (P-21)';

  @override
  String get logMealFlexibleBadge => 'بحث وتوثيق مرن';

  @override
  String get logMealOffPlanDesc =>
      'تناولت طعاماً أو وجبة خفيفة لم تكن مدرجة في جدولك؟ سجّلها بسهولة بالبحث المباشر أو تحديد الغرامات التقريبية.';

  @override
  String get logMealOffPlanNote =>
      'قاعدة بيانات غنية بالأطعمة العربية والوجبات الشائعة';

  @override
  String get logMealOffPlanNote2 =>
      'لا داعي للشعور بالذنب، المرونة جزء أساسي من النجاح';

  @override
  String get logMealOffPlanFooter => 'المتابعة للبحث وحساب الغرامات (P-22)';

  @override
  String get logMealPrivacyNote =>
      'بياناتك الغذائية مشفرة وتُعامل بخصوصية طبية تامة';

  @override
  String get logMealEncouragementLabel => 'إضاءة تشجيعية: ';

  @override
  String get logMealEncouragementBody =>
      'التسجيل الدقيق يساعد أخصائي التغذية على ضبط سعراتك وملاءمة الوجبات القادمة حسب استجابة جسمك الطبيعية وتفضيلاتك اليومية.';

  @override
  String get mealDetailTitle => 'تفاصيل الوجبة';

  @override
  String get mealDetailIngredients => 'مكونات الوجبة والبدائل';

  @override
  String mealDetailItemsCount(Object count) {
    return '$count أصناف غذائية';
  }

  @override
  String get mealDetailUpdateNote => 'سيتم تحديث سجل اليوم ونسبة التزامك فوراً';

  @override
  String mealDetailCurrentMeal(Object time) {
    return 'الوجبة الحالية • $time';
  }

  @override
  String get mealDetailSmartSwap => 'مرونة الاستبدال الذكي';

  @override
  String get mealDetailSwapNote =>
      'اختر البديل إذا لم يتوفر الصنف الأصلي، والبديل يستبدل الصنف ولا يُضاف إليه لتحقيق التوازن التغذوي الدقيق.';

  @override
  String get mealDetailTotalCalories => 'إجمالي السعرات النشطة';

  @override
  String get commonCaloriesUnit => 'سعرة حرارية';

  @override
  String mealDetailApprovedBy(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'وجبة متوازنة معتمدة من أخصائي التغذية $name',
        'female': 'وجبة متوازنة معتمدة من أخصائية التغذية $name',
        'unknown': 'وجبة متوازنة معتمدة من أخصائي التغذية',
        'other': 'وجبة متوازنة معتمدة من $name',
      },
    );
    return '$_temp0';
  }

  @override
  String get macroProtein => 'البروتين';

  @override
  String get macroCarbs => 'الكارب';

  @override
  String get macroHealthyFats => 'الدهون الصحية';

  @override
  String commonGramsShortValue(Object value) {
    return '$value غ';
  }

  @override
  String get mealDetailNoAlternative => 'صنف أساسي بدون بديل';

  @override
  String get mealDetailChooseOne => 'اختر صنفاً واحداً';

  @override
  String get mealDetailOriginalItem => 'الصنف المجدول الأصلي';

  @override
  String mealDetailReplaces(Object item) {
    return 'يستبدل $item';
  }

  @override
  String get mealDetailLoggedNow => 'سجّلت هذه الوجبة الآن';

  @override
  String get mealLoggedOffPlan => 'وجبة خارج الخطة';

  @override
  String get mealLoggedFromPlan => 'وجبة من خطتك الغذائية';

  @override
  String get mealLoggedTitle => 'تم تسجيل الوجبة بنجاح';

  @override
  String get mealLoggedBody =>
      'تم تحديث سجل اليوم ومستوى التزامك الغذائي بنجاح وبدقة سريرية.';

  @override
  String get mealLoggedYourMeal => 'وجبتك المسجلة';

  @override
  String mealLoggedMealLine(Object plan, Object grams) {
    return '$plan  •  $grams غرام';
  }

  @override
  String get mealLoggedGoToPlan => 'الانتقال فوراً لخطتي اليومية';

  @override
  String get mealLoggedLogAnother => 'تسجيل وجبة أخرى';

  @override
  String get mealLoggedInstantUpdate => 'تحديث فوري';

  @override
  String get mealLoggedDailyAdherence => 'الالتزام بالوجبات اليومية';

  @override
  String mealLoggedSummary(Object logged, Object planned, Object percent) {
    return 'سجّلت $logged من $planned ($percent٪)';
  }

  @override
  String get macroCarbohydrates => 'كربوهيدرات';

  @override
  String get mealLoggedRedirecting => 'جارٍ نقلك تلقائياً لخطتي اليومية...';

  @override
  String get guideNeedHelp =>
      'هل تحتاج مساعدة إضافية؟ تواصل مع أخصائي التغذية عبر المحادثة';

  @override
  String get guideHeadline => 'إرشادات أخذ القياسات بدقة';

  @override
  String get guideIntro =>
      'الرسوم التوضيحية التالية توضح بدقة المكان الصحيح لوضع شريط القياس لضمان الحصول على قراءات دقيقة ومتسقة تساعد أخصائي التغذية.';

  @override
  String get guideGeneralTips =>
      'نصائح عامة: قف باسترخاء، تنفس طبيعياً، ولا تشد شريط القياس بقوة على الجلد';

  @override
  String get guideComingFeature => 'ميزة قيد الإعداد';

  @override
  String get guideVideoComingSoon =>
      '🎬 قريباً: فيديو إرشادي قصير (١٠ ثوان) لكل قياس لتسهيل المتابعة العملية المباشرة.';

  @override
  String get guideDoneBack => 'فهمت، العودة لتسجيل القياسات';

  @override
  String get guideZoom => 'تكبير الرسم';

  @override
  String get measurementsTitle => 'الوزن ومحيط الجسم';

  @override
  String get measurementsDateLabel => 'الجمعة، 19 سبتمبر 2025';

  @override
  String get measurementsCurrentWeight => 'الوزن الحالي';

  @override
  String get commonKgUnit => 'كغ';

  @override
  String measurementsDeltaVsLast(Object delta) {
    return '$delta كغ مقارنة بآخر قياس';
  }

  @override
  String measurementsClinicVerified(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'تم التحقق أثناء زيارة العيادة مع الأخصائي $name',
        'female': 'تم التحقق أثناء زيارة العيادة مع الأخصائية $name',
        'unknown': 'تم التحقق أثناء زيارة العيادة',
        'other': 'تم التحقق أثناء زيارة العيادة مع $name',
      },
    );
    return '$_temp0';
  }

  @override
  String get measurementsRange30 => '30 يوم';

  @override
  String get measurementsRange90 => '90 يوم';

  @override
  String get measurementsNoReadingsYet =>
      'لا توجد قياسات بعد. ستظهر أول قياساتك هنا.';

  @override
  String get measurementsNoReadingsInRange => 'لا توجد قياسات في هذه الفترة.';

  @override
  String get measurementsSmoothStable => 'انسيابي ومستقر';

  @override
  String get measurementsTrend => 'مسار التغيير';

  @override
  String get measurementsClinicReading => 'قياس العيادة (معتمد)';

  @override
  String get measurementsHomeReading => 'قياس منزلي';

  @override
  String get measurementsSyncNote =>
      'تحديث البيانات متزامن مع قياسات العيادة وسجلك الشخصي بكل موثوقية.';

  @override
  String get measurementsLastUpdated => 'آخر تحديث: 19 سبتمبر';

  @override
  String get measurementsBodyCircumference => 'محيط الجسم';

  @override
  String get measurementsOngoingStep => 'خطوة مستمرة';

  @override
  String get measurementsLoggingCommitment => 'الالتزام بالتسجيل';

  @override
  String measurementsDaysThisWeek(Object days) {
    return 'سجّلتِ $days أيام من 7 أيام هذا الأسبوع';
  }

  @override
  String measurementsDaysThisMonth(Object days) {
    return '(إجمالي $days يوماً مسجلاً هذا الشهر)';
  }

  @override
  String get measurementsRegularNote =>
      'تسجيلك المنتظم يمكّن أخصائي التغذية من تحليل نمطك بدقة ودعمك بالخيارات الأنسب دون أي ضغط أو تسرّع.';

  @override
  String get measurementsLogDaily => 'سجّل قياساتك اليومية';

  @override
  String commonCmValue(Object value) {
    return '$value سم';
  }

  @override
  String get measurementsSteady => 'ثابت ومستقر';

  @override
  String get measurementEntryTitle => 'تفاصيل القياس';

  @override
  String get measurementEntrySave => 'حفظ القياسات';

  @override
  String get measurementEntryCancel => 'إلغاء والعودة للتقدّم';

  @override
  String get measurementEntryView => 'عرض';

  @override
  String get measurementEntryGuideTitle => 'دليل القياس المصوّر';

  @override
  String get measurementEntryGuideSubtitle =>
      'خطوات بسيطة للحصول على قراءة دقيقة';

  @override
  String get measurementEntryDate => 'تاريخ تسجيل القياس';

  @override
  String get measurementEntryNoFuture => 'لا يمكن تحديد موعد مستقبلي';

  @override
  String get measurementEntryToday => 'اليوم، الأحد 21 سبتمبر 2025';

  @override
  String get measurementEntrySuggestedTime =>
      'توقيت التسجيل المقترح: صباحاً قبل الإفطار';

  @override
  String get measurementEntryRequired => 'مطلوب';

  @override
  String get measurementEntryRegularNote =>
      'يساعد قياس الوزن المنتظم صباحاً بعد الاستيقاظ على تزويد أخصائي التغذية ببيانات موثوقة تعكس تطورك الحقيقي.';

  @override
  String get measurementEntryCircumferenceTitle => 'قياسات المحيط بشريط القياس';

  @override
  String get commonOptional => 'اختياري';

  @override
  String get measurementEntryOptionalNote =>
      'سجّل ما يتوفر لديك فقط دون أي إلزام';

  @override
  String get measurementEntryHowToMeasure => 'كيف أقيس بدقة؟';

  @override
  String get measurementEntryUnitCm => 'القياسات بالسنتيمتر (سم)';

  @override
  String get measurementWaist => 'محيط الخصر';

  @override
  String get measurementWaistHint => 'عند أضيق نقطة فوق السرة';

  @override
  String get measurementHip => 'محيط الورك';

  @override
  String get measurementHipHint => 'عند أعرض نقطة في الحوض';

  @override
  String get measurementThigh => 'محيط الفخذ';

  @override
  String get measurementThighHint => 'منتصف المسافة بين الورك والركبة';

  @override
  String get measurementArm => 'محيط الذراع';

  @override
  String get measurementArmHint => 'منتصف العضد مع استرخاء اليد';

  @override
  String get measurementEntryPrivacyTitle => 'خصوصيتك الصحية أمانة';

  @override
  String measurementEntryPrivacyBody(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'unknown':
            'جميع بياناتك محمية وتصل بأمان لملفك الطبي المباشر لدى أخصائي التغذية دون أي أحكام أو تقييمات مسبقة، لتعديل خطتك بما يناسبك.',
        'other':
            'جميع بياناتك محمية وتصل بأمان لملفك الطبي المباشر لدى $name دون أي أحكام أو تقييمات مسبقة، لتعديل خطتك بما يناسبك.',
      },
    );
    return '$_temp0';
  }

  @override
  String measurementEntryLastValueHint(Object value) {
    return 'آخر قياس: $value';
  }

  @override
  String get commonCmUnit => 'سم';

  @override
  String get timeAm => 'ص';

  @override
  String get timePm => 'م';

  @override
  String get notificationSettingsHeading => 'تخصيص التنبيهات الصحية';

  @override
  String get notificationSettingsIntro =>
      'يمكنك تحديد الإشعارات التي ترغب في استلامها بكل دقة، لتبقى على اتصال دائم بأهدافك دون أي إزعاج.';

  @override
  String get notificationSettingsMeals => 'تذكير الوجبات';

  @override
  String get notificationSettingsMealsDesc =>
      'تذكير بمواعيد وجبات خطتك اليومية وتسجيلها في وقتها المناسب.';

  @override
  String get notificationSettingsMeasurements => 'تذكير القياسات';

  @override
  String get notificationSettingsMeasurementsDesc =>
      'تنبيه لطيف صباح كل أسبوع لأخذ قياس الوزن ومحيط الجسم وتحديث تقدمك.';

  @override
  String get notificationSettingsPlanUpdatesDesc =>
      'إشعار فوري عند مراجعة أخصائي التغذية لخطتك وتعديل الوجبات أو البدائل.';

  @override
  String notificationSettingsQuietRange(Object start, Object end) {
    return 'من $start حتى $end تلقائياً';
  }

  @override
  String get notificationSettingsPhoneDisabled => 'إشعارات الهاتف معطلة';

  @override
  String get notificationSettingsSystemSettings => 'إعدادات النظام';

  @override
  String get notificationSettingsPermissionOff =>
      'تم إيقاف صلاحية الإشعارات لتطبيق HealthyLife من إعدادات جهازك. لتلقي التذكيرات ومتابعة خطتك الغذائية، يرجى تفعيلها من إعدادات النظام.';

  @override
  String get notificationSettingsOpenPhoneSettings => 'فتح إعدادات الهاتف';

  @override
  String get notificationSettingsEnableTitle => 'إشعارات الهاتف غير مفعّلة';

  @override
  String get notificationSettingsEnableDesc =>
      'لا تظهر تذكيرات الوجبات ورسائل أخصائي التغذية حتى تسمح بها. تفعيلها يستغرق لحظة ويمكنك إيقافها في أي وقت.';

  @override
  String get notificationSettingsEnable => 'تفعيل الإشعارات الآن';

  @override
  String get notificationSettingsEnabledTitle => 'إشعارات الهاتف مفعّلة';

  @override
  String get notificationSettingsEnabledDesc =>
      'ستصلك تذكيرات الوجبات ورسائل أخصائي التغذية ومواعيد القياس.';

  @override
  String get notificationSettingsCalm => 'هدوء وتوازن بدون تشويش';

  @override
  String get notificationSettingsRoutine =>
      'ننظم إشعاراتك بما يلائم روتينك اليومي';

  @override
  String get commonOff => 'معطل';

  @override
  String get notificationSettingsQuietHours => 'أوقات عدم الإزعاج';

  @override
  String get notificationSettingsPromise =>
      'نلتزم بإرسال التنبيهات الضرورية فقط لمساعدتك على الالتزام، دون أي إزعاج أو إشعارات ترويجية.';

  @override
  String get notificationSettingsNightQuiet => 'الهدوء الليلي';

  @override
  String commonFromTo(Object start, Object end) {
    return 'من $start حتى $end';
  }

  @override
  String get notificationSettingsStarts => 'يبدأ';

  @override
  String get notificationSettingsEnds => 'ينتهي';

  @override
  String get notificationsTitle => 'التنبيهات';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsAllInOne => 'كل جديدك في مكان واحد';

  @override
  String get notificationsSubtitle => 'تحديثات خطتك وتذكيراتك الصحية';

  @override
  String get notificationsRead => 'مقروء';

  @override
  String notificationsMealMacros(Object protein, Object carbs) {
    return 'بروتين $protein جم  •  كربوهيدرات $carbs جم';
  }

  @override
  String get notificationsClinicalUpdate => 'تحديث سريري';

  @override
  String get notificationsLogNow => 'تسجيل الآن';

  @override
  String get notificationsEmptyCategory =>
      'لا توجد إشعارات في هذا التصنيف حالياً';

  @override
  String get notificationsPersonalized => 'تنبيهاتك مخصصة لراحتك';

  @override
  String get notificationsEditMealTimes =>
      'يمكنك تعديل أوقات الوجبات من الإعدادات';

  @override
  String get offlineTitle => 'لا يوجد اتصال';

  @override
  String get offlineRetry => 'إعادة محاولة الاتصال';

  @override
  String get offlineSavedMeals => 'عرض الوجبات المحفوظة أوفلاين';

  @override
  String get offlineCheckWifi =>
      'تحقق من تفعيل Wi-Fi أو بيانات الهاتف من إعدادات جهازك';

  @override
  String get onboardingHealthAsPrescribed => 'حسب الوصفة';

  @override
  String get onboardingHealthTitle => 'البيانات الصحية';

  @override
  String get onboardingHealthConditions => 'الحالات الصحية والأمراض';

  @override
  String get onboardingHealthConditionsNote =>
      'حدد أي حالات صحية تم تشخيصك بها لتكييف برنامجك الغذائي ومكوناته والوجبات المقترحة وفق استجابة تامة وآمنة لجسمك.';

  @override
  String get onboardingHealthConfidentialNote =>
      'سرية سريرية مشفرة ومعتمدة طبياً — تساعد هذه التفاصيل أخصائي التغذية في استبعاد أي مكونات قد تتعارض مع مؤشراتك الحيوية أو أدويتك الموصوفة.';

  @override
  String get onboardingHealthAllergies => 'الحساسية الغذائية والتفضيلات';

  @override
  String get onboardingHealthAllergiesNote =>
      'حدد مسببات الحساسية المعتمدة ليقوم النظام باستبعادها تلقائياً من جداول الوجبات والوصفات المقترحة.';

  @override
  String get onboardingHealthMedications => 'الأدوية والمكملات المنتظمة';

  @override
  String get onboardingHealthDoseAccuracy => 'دقة الجرعات';

  @override
  String get onboardingHealthMedicationsNote =>
      'اكتب أي أدوية موصوفة أو فيتامينات تتناولها لضمان عدم حدوث تداخلات كيميائية مع توقيت ومكونات الوجبات.';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get onboardingHealthMedicationHint =>
      'أدخل اسم الدواء والجرعة (مثال: أوميغا 3)';

  @override
  String get onboardingHealthReviewNote =>
      'تخضع كافة الملاحظات والأدوية لمراجعة برمجية واستشارية دقيقة لملاءمة النظام الغذائي واستبعاد أي تداخلات غذائية مع أدويتك الموصوفة.';

  @override
  String get onboardingHealthOtherNotes =>
      'ملاحظات صحية أخرى للأخصائي (اختياري)';

  @override
  String get onboardingHealthOtherNotesHint =>
      'مثال: أتناول مكملات فيتامين د يومياً، إجراء جراحة مرارة سابقة، أو أي أدوية منتظمة...';

  @override
  String get onboardingHealthContinue => 'متابعة والتالي';

  @override
  String get onboardingMeasurementsPickWeight => 'اختر وزنك';

  @override
  String commonKilogramsValue(Object value) {
    return '$value كجم';
  }

  @override
  String get onboardingMeasurementsTitle => 'القياسات الأولية';

  @override
  String get onboardingMeasurementsYours => 'قياساتك الأولية';

  @override
  String get onboardingMeasurementsIntro =>
      'أدخل وزنك وقياساتك اليوم لنبدأ بتتبع رحلتك الصحية مع الأخصائي بدقة واحترافية.';

  @override
  String get onboardingMeasurementsMandatory => 'إلزامي';

  @override
  String get commonKilogramsUnit => 'كجم';

  @override
  String get onboardingMeasurementsTapToChoose => 'اضغط للاختيار';

  @override
  String get onboardingMeasurementsMaxWeight => '160 كجم';

  @override
  String get onboardingMeasurementsIdealRange => 'المثالي التقديري: 65-72';

  @override
  String get onboardingMeasurementsMinWeight => '40 كجم';

  @override
  String get onboardingMeasurementsTip =>
      'نصيحة الأخصائي: يُفضل أخذ القياس صباحاً بعد الاستيقاظ مباشرة، بملابس خفيفة وقبل تناول الإفطار.';

  @override
  String get onboardingMeasurementsHowTo => 'كيف آخذ قياساتي بشكل دقيق؟';

  @override
  String get onboardingMeasurementsIllustratedGuide => 'دليل مصور';

  @override
  String get onboardingMeasurementsExtraNote =>
      'قياسات إضافية تدعم دقة متابعة الأخصائي لمحيط الجسم ونسب توزيع الدهون بدقة.';

  @override
  String get onboardingMeasurementsWaistHint => 'عند أضيق نقطة';

  @override
  String get onboardingMeasurementsHipHint => 'المنطقة الأكبر حجماً';

  @override
  String get onboardingMeasurementsThighHint => 'أعلى الفخذ الأيمن';

  @override
  String get onboardingMeasurementsPrivacyNote =>
      'بياناتك وقياساتك مشفرة بالكامل بمعايير أمان صحية معتمدة، وتُعرض حصرياً لأخصائي التغذية المعتمد لتصميم خطتك الغذائية الفردية.';

  @override
  String get onboardingMeasurementsSaveContinue => 'حفظ والمتابعة';

  @override
  String get onboardingNotificationsTitle => 'لا تفوّت مواعيد وجباتك';

  @override
  String get onboardingNotificationsIntro =>
      'فعّل الإشعارات لتصلك تذكيرات الوجبات المخصصة، وتنبيهات الأخصائي لمتابعة التزامك أولاً بأول وبكل سلاسة.';

  @override
  String get onboardingNotificationsMealReminders =>
      'تذكيرات بمواعيد الوجبات المحددة';

  @override
  String get onboardingNotificationsMealRemindersDesc =>
      'تنبيه لطيف قبل موعد الوجبة لمساعدتك على تنظيم يومك وتناول طعامك الصحي في التوقيت الأنسب لجسمك.';

  @override
  String get onboardingNotificationsSpecialistMessages =>
      'رسائل وتوجيهات مباشرة من الأخصائي';

  @override
  String get onboardingNotificationsSpecialistMessagesDesc =>
      'استلم تعليقات أخصائي التغذية وتعديلات الخطة فور إرسالها دون الحاجة لتفقد التطبيق باستمرار.';

  @override
  String get onboardingNotificationsWeightReminders =>
      'تنبيهات لموعد تسجيل الوزن أسبوعياً';

  @override
  String get onboardingNotificationsWeightRemindersDesc =>
      'تذكير أسبوعي في الوقت الصباحي المثالي للقياس لمتابعة تطور نتائجك ومؤشراتك الحيوية بدقة.';

  @override
  String get onboardingNotificationsEnable => 'تفعيل الإشعارات الآن';

  @override
  String get onboardingNotificationsLater => 'ليس الآن، سأضبطها لاحقاً';

  @override
  String onboardingStepProgress(Object percent) {
    return 'خطوة ٣ من ٣ ($percent%)';
  }

  @override
  String get onboardingNotificationsHeader => 'إعداد التنبيهات • HealthyLife';

  @override
  String get onboardingNotificationsRespectLabel => 'نحترم هدوءك وخصوصيتك: ';

  @override
  String get onboardingNotificationsRespectBody =>
      'لن نرسل أي إعلانات ترويجية، ويمكنك دائماً ضبط أو كتم أوقات التنبيهات من الإعدادات.';

  @override
  String get onboardingTrackTitle => 'تتبع وجباتك ووزنك بلمسة واحدة';

  @override
  String get onboardingTrackDescription =>
      'سجّل وجباتك اليومية ووزنك بدقة بالغرامات، واستفد من البدائل المتاحة لتسهيل التزامك بالنظام الغذائي دون حرمان.';

  @override
  String get onboardingBadgeSmartScan => 'مسح ذكي فوري';

  @override
  String get onboardingBadgeDetailedAccuracy => 'دقة تفصيلية';

  @override
  String get onboardingPlanTitle => 'خطتك الغذائية بإشراف أخصائيك';

  @override
  String get onboardingPlanDescription =>
      'احصل على نظام غذائي مخصص بالكامل يناسب طبيعة جسمك وحالتك الصحية، ومصمم مباشرة من أخصائي التغذية المتابع لك.';

  @override
  String get onboardingBadgeApproved => '١٠٠٪ معتمد طبياً ومبني على التحاليل';

  @override
  String get onboardingStartNow => 'ابدأ الآن';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get passwordErrorEnterCurrent => 'أدخل كلمة المرور الحالية';

  @override
  String get passwordErrorMinLength => 'اجعلي كلمة المرور 8 أحرف على الأقل';

  @override
  String get passwordErrorUppercase => 'أضيفي حرفًا كبيرًا واحدًا على الأقل';

  @override
  String get passwordErrorDigit => 'أضيفي رقمًا واحدًا على الأقل';

  @override
  String get passwordErrorSpecial => 'أضيفي رمزًا خاصًا واحدًا على الأقل';

  @override
  String get passwordErrorMismatch => 'أكدي كلمة المرور الجديدة بشكل مطابق';

  @override
  String get passwordSaved => 'تم حفظ كلمة المرور بنجاح';

  @override
  String get passwordResetLinkSent =>
      'سيتم إرسال رابط استعادة كلمة المرور إلى رقمك أو بريدك المسجل';

  @override
  String get passwordTitle => 'كلمة المرور';

  @override
  String get passwordCurrent => 'كلمة المرور الحالية';

  @override
  String get passwordForgot => 'نسيت كلمة المرور؟';

  @override
  String get passwordConfirmNew => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordMatches => 'تطابق كلمة المرور الجديدة تماماً';

  @override
  String get passwordNoMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordRequirements => 'شروط كلمة المرور:';

  @override
  String get passwordRuleMinLength8 => '٨ أحرف على الأقل';

  @override
  String get passwordRuleSpecial => 'رمز خاص واحد على الأقل (!@#\$%)';

  @override
  String get passwordLogoutOthersNote =>
      'بعد تغيير كلمة المرور بنجاح، سيتم تسجيل خروجك من الأجهزة الأخرى تلقائياً لحماية حسابك الطبي وصحتك.';

  @override
  String get passwordProtectionTitle => 'حماية الحساب والبيانات الصحية';

  @override
  String get passwordProtectionBody =>
      'احرص على اختيار كلمة مرور قوية وغير مكررة لضمان خصوصية خطتك وسجلاتك الصحية.';

  @override
  String get passwordStrengthEnter => 'أدخل كلمة المرور';

  @override
  String get passwordStrengthWeak => 'ضعيفة';

  @override
  String get passwordStrengthFair => 'متوسطة';

  @override
  String get passwordStrengthGood => 'جيدة ومقبولة';

  @override
  String get passwordStrengthVeryStrong => 'قوية جداً';

  @override
  String get passwordStrengthLabel => 'قوة كلمة المرور:';

  @override
  String get commonSaved => 'تم الحفظ';

  @override
  String get passwordSave => 'حفظ كلمة المرور';

  @override
  String get planPreparingTitle => 'خطتكِ قيد التحضير بعناية';

  @override
  String get planPreparingBody =>
      'أخصائي التغذية العلاجية يُعدّ الآن جدولك الغذائي المخصص بدقة ليلائم أهدافك الصحية ونتائج قياساتك الأولية. سنرسل لك إشعاراً فور اعتماد الخطة لتجدها هنا.';

  @override
  String get planPreparingExpectedTime => 'الوقت المتوقع للاعتماد';

  @override
  String get planPreparingWithin24h =>
      'خلال ٢٤ ساعة عمل من تسجيل قياساتك الأولية';

  @override
  String get planPreparingReview => 'مراجعة طبية سريرية موثقة';

  @override
  String planPreparingManualPercent(Object percent) {
    return '$percent٪ يدوي ومخصص';
  }

  @override
  String get planPreparingUrgentQuestion => 'استفسار أو تفضيل غذائي طارئ؟';

  @override
  String get planPreparingTeamAvailable =>
      'فريقنا وأخصائي التغذية متاحون للمساعدة الفورية';

  @override
  String get planPreparingContactWhatsApp =>
      'تواصل مع أخصائي التغذية عبر واتساب';

  @override
  String get planPreparingHours =>
      'متاح طوال أيام العمل الرسمية من ٩:٠٠ ص حتى ٦:٠٠ م';

  @override
  String planPreparingClinic(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'unknown': 'عيادة التغذية العلاجية',
        'other': 'عيادة التغذية العلاجية • $name',
      },
    );
    return '$_temp0';
  }

  @override
  String get planPreparingAdvanced => 'تخصيص متقدم';

  @override
  String get commonEnabled => 'مفعّل';

  @override
  String get privacyScopeTitle => '١. نطاق البيانات المجمّعة';

  @override
  String get privacyScopeBody =>
      'نجمع فقط ما يلزم لبناء خطتك الغذائية العلاجية: قياساتك الحيوية (الوزن، محيط الجسم)، سجلات وجباتك اليومية، حالاتك الصحية المشخصة، حساسياتك الغذائية، والأدوية والمكملات التي تخبرينا بها. لا نطلب أو نُخزّن أي بيانات مالية أو بيانات موقع دائم.';

  @override
  String get privacyEncryptionTitle => '٢. التشفير وأماكن التخزين';

  @override
  String get privacyEncryptionBody =>
      'تُشفّر جميع البيانات الصحية أثناء النقل والتخزين بنظام bit AES-256، وتُحفظ على خوادم طبية معزولة متوافقة مع معايير HIPAA. لا تُستخدم بياناتك في تدريب نماذج عامة ولا تُشارك مع أي شركة إعلانات تحت أي ظرف.';

  @override
  String get privacyAccessTitle => '٣. من يستطيع الاطلاع على ملفك';

  @override
  String get privacyAccessBody =>
      'فريق الرعاية المخصص لك فقط — أخصائي التغذية العلاجية المعتمد على حسابك — يستطيع الاطلاع على سجلك الكامل. أي تحديث أو تعديل على خطتك يُسجَّل باسم صاحبه ووقته في سجل تدقيق لا يمكن حذفه.';

  @override
  String get privacyRightsTitle => '٤. حقك في التعديل والإلغاء';

  @override
  String get privacyRightsBody =>
      'يمكنك سحب موافقتك في أي وقت من الحساب ← الخصوصية، وسيؤدي ذلك إلى إيقاف تخصيص الخطة تلقائياً حتى تجديد الموافقة. يمكنك أيضاً طلب نسخة كاملة من بياناتك أو حذفها نهائياً بالتواصل مع أخصائي التغذية.';

  @override
  String get privacyRetentionTitle =>
      '٥. الاحتفاظ بالبيانات بعد انتهاء المتابعة';

  @override
  String get privacyRetentionBody =>
      'عند انتهاء فترة المتابعة السريرية، تبقى سجلاتك وقياساتك محفوظة بأمان لاستئناف الخطة فور التجديد، ولا تُحذف تلقائياً إلا بطلب صريح منك.';

  @override
  String get privacyTitle => 'الخصوصية السريرية الكاملة';

  @override
  String get privacyLastUpdated =>
      'آخر تحديث لهذه الوثيقة: يناير 2026 — متوافقة مع معايير HIPAA السريرية';

  @override
  String get profileMeasurementsSubtitle => 'سجّل قياساتك وتابع مسار تغيّرك';

  @override
  String get profileHealthRecordSubtitle =>
      'المستوى، الهدف، الأدوية والتشخيصات المعتمدة';

  @override
  String get profileAchievements => 'إنجازاتي';

  @override
  String get profileWellbeing => 'النوم والإجهاد والمزاج';

  @override
  String get profileAppointments => 'المواعيد والمتابعة';

  @override
  String get profileNotificationLog => 'سجل الإشعارات';

  @override
  String get profileTitle => 'الحساب';

  @override
  String get commonSettings => 'الإعدادات';

  @override
  String get profileAccountSettings => 'إعدادات الحساب والمتابعة';

  @override
  String get profileDietitian => 'الأخصائي الغذائي';

  @override
  String profileDietitianName(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': '$name (أخصائي التغذية العلاجية)',
        'female': '$name (أخصائية التغذية العلاجية)',
        'unknown': 'أخصائي التغذية العلاجية',
        'other': '$name',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileNotificationsSubtitle => 'التذكير بالوجبات والقياسات';

  @override
  String get profilePasswordSubtitle => 'تحديث وحماية الحساب';

  @override
  String get profileLanguageCurrent => 'العربية (الحالية)';

  @override
  String get profileLanguageBadge => 'عربي';

  @override
  String get profileVersion => 'الإصدار 1.0.0';

  @override
  String get profileUpgradeRequired =>
      'هذه الميزة تتطلب باقة أعلى — تواصل مع أخصائي التغذية للترقية';

  @override
  String get profileHealthCv => 'الملف الصحي (Health CV)';

  @override
  String get profileHealthCvSubtitle => 'سجل صحي شامل يعدّه أخصائيك';

  @override
  String get profileLogoutCaption =>
      'يتطلب تأكيد تسجيل الخروج لضمان مزامنة قياساتك الأخيرة';

  @override
  String get profilePatientCode => 'كود المريض: HL-0042';

  @override
  String get profileFollowingClinic => 'العيادة المتابعة';

  @override
  String get profileMore => 'المزيد';

  @override
  String get profileMoreSubtitle =>
      'القياسات، السجل الطبي، الإنجازات والمواعيد';

  @override
  String get profileLogoutSubtitle => 'إنهاء الجلسة بأمان من هذا الجهاز';

  @override
  String get progressNextConsultation =>
      'الموعد الاستشاري القادم: الأحد القادم، الساعة 5:00 مساءً';

  @override
  String progressNextAppointment(String date) {
    return 'موعدك القادم: $date';
  }

  @override
  String get progressTitle => 'متابعة التقدم والتقييم';

  @override
  String get progressActiveFile => 'ملف نشط';

  @override
  String get progressLiveSync => 'مزامنة مباشرة مع العيادة';

  @override
  String get progressOnlineNow => 'متصل الآن';

  @override
  String get progressAndMeasurements => 'التقدّم والقياسات';

  @override
  String get progressSpecialistNotes => 'ملاحظات الأخصائي';

  @override
  String get commonNew => 'جديد';

  @override
  String get progressCurrentWeight => 'الوزن الحالي المسجل';

  @override
  String get progressLogWeightToday => 'تسجيل وزن جديد اليوم';

  @override
  String get progressWeightTrend => 'مسار الوزن';

  @override
  String get progressClinicVsHome => 'مقارنة بين قياس العيادة والمنزل';

  @override
  String get progressRange30 => '30 يوماً';

  @override
  String get progressRange90 => '90 يوماً';

  @override
  String get commonToday => 'اليوم';

  @override
  String get progressClinicReading => 'قياس العيادة المعتمد';

  @override
  String get progressHomeReading => 'قياس بيتي دوري';

  @override
  String get progressVitalCircumference => 'محيط القياسات الحيوية';

  @override
  String progressUpdatedOn(String date) {
    return 'آخر تحديث $date';
  }

  @override
  String get progressNoCircumference =>
      'لم تُسجَّل قياسات المحيط بعد. أضفها مع قياس وزنك القادم.';

  @override
  String progressCmChange(String value) {
    return '$value سم';
  }

  @override
  String get progressUpdatedTwoDaysAgo => 'آخر تحديث قبل يومين';

  @override
  String get progressWaist => 'الخصر';

  @override
  String get progressWaistDelta => '-4 سم';

  @override
  String get progressHip => 'الورك';

  @override
  String get progressHipDelta => '-2 سم';

  @override
  String get progressThigh => 'الفخذ';

  @override
  String get progressThighDelta => '-1 سم';

  @override
  String get progressArm => 'الذراع';

  @override
  String get progressGuideLink => 'دليل القياس المصوّر';

  @override
  String get progressWeeklyEvaluation => 'تقييم الأسبوع الحالي';

  @override
  String get progressLatestReview => 'آخر تقييم من أخصائي التغذية';

  @override
  String progressAdherencePercent(String percent) {
    return 'التزام $percent%';
  }

  @override
  String get progressNoReadings => 'لا توجد قراءات وزن في هذه الفترة بعد.';

  @override
  String progressReviewedBy(String name) {
    return 'تمت المراجعة من $name';
  }

  @override
  String get progressExcellent => 'أداء ممتاز';

  @override
  String get progressEvaluationBody =>
      'استجابة ممتازة لمقاومة الإنسولين، مع تحسن ملموس في توازن الطاقة الحيوية أثناء ساعات الصباح وثبات ملحوظ في قياسات الخصر.';

  @override
  String get progressEncouragementTitle => 'رسالة تشجيعية خاصة';

  @override
  String get progressEncouragementQuote =>
      '“فخورة جداً بوعيك والتزامك هذا الأسبوع! النزول تدريجي وصحي ومحيط الخصر تحسن بشكل ملحوظ. حافظي على نمط النوم الحالي وسنصل لهدف الشهر بكل سهولة”';

  @override
  String get progressVoiceNote => 'ملاحظة صوتية من الدكتورة';

  @override
  String get progressTaskWater => 'زيادة شرب الماء لـ 2.5 لتر يومياً';

  @override
  String get progressTaskWaterDesc =>
      'توزيع منتظم بمعدل كوب كل ساعتين بين الوجبات لتعزيز الأيض.';

  @override
  String get progressTaskCottageCheese => 'بديل جبنة القريش مع زيت الزيتون';

  @override
  String get progressTaskCottageCheeseDesc =>
      'اعتمادك كوجبة عشاء رئيسية لدعم الشبع البطيء وموازنة سكر الدم ليلاً.';

  @override
  String get progressTaskWalk => '15 دقيقة مشي خفيف بعد العشاء';

  @override
  String get progressTaskWalkDesc =>
      'تنشيط الدورة الدموية وتفريغ مخازن الجليكوجين قبل النوم.';

  @override
  String get progressNextWeekGuidance => 'توجيهات الأسبوع القادم';

  @override
  String progressTaskCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText مهمة',
      few: '$countText مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get progressAllNotes => 'عرض كل الملاحظات';

  @override
  String get progressThreeTasks => '3 مهام محددة';

  @override
  String get progressDiscussWhatsApp => 'مناقشة التقييم عبر الواتساب مباشرة';

  @override
  String get quantityFreshFruit => 'فاكهة طازجة';

  @override
  String quantityKcalPerGrams(Object kcal, Object grams) {
    return '$kcal سعرة حرارية لكل $grams غرام';
  }

  @override
  String quantityKcalTimesPortions(Object kcal, Object portions) {
    return '$kcal سعرة × $portions حصة';
  }

  @override
  String get quantityCalculatedNote =>
      'القيمة محسوبة بالكامل وتُضاف بدقة إلى خطتك اليومية';

  @override
  String quantityRange(Object min, Object max) {
    return 'المدى المتاح: $min غرام حتى $max غرام';
  }

  @override
  String get quantityGramsUnit => 'غرام (g)';

  @override
  String get quantityCommonAmounts => 'كميات شائعة وسريعة:';

  @override
  String get quantityOneTap => 'اختر بلمسة واحدة';

  @override
  String get quantityFineSlider => 'شريط الضبط الدقيق';

  @override
  String get quantityEstimateHint => 'تلميح للمساعدة في التقدير';

  @override
  String quantityEstimateBody(Object apple, Object palm) {
    return 'تفاحة متوسطة الحجم تعادل تقريباً $apple غرام، بينما كف اليد المنبسط يعادل حوالي $palm غرام من اللحوم أو الأرز المطبوخ، يمكنك دوماً التقدير بالتقريب دون قلق.';
  }

  @override
  String quantityStepAdd(String value) {
    return '$value+';
  }

  @override
  String quantityStepSubtract(String value) {
    return '$value-';
  }

  @override
  String get quantityReassuring => 'نهج مطمئن وصحي';

  @override
  String get quantityFlexibility =>
      'المرونة في التسجيل هي أساس استمرارية العادات الصحية';

  @override
  String get quantityConfirm => 'تأكيد الكمية وتسجيل الطعام';

  @override
  String get weekdayShortSunday => 'الأحد';

  @override
  String get weekdayShortMonday => 'الإثنين';

  @override
  String get weekdayShortTuesday => 'الثلاثاء';

  @override
  String get weekdayShortWednesday => 'الأربعاء';

  @override
  String get weekdayShortThursday => 'الخميس';

  @override
  String get callsResultsReview => 'مراجعة نتائج القياسات';

  @override
  String get callsCompleted => 'مكتملة';

  @override
  String get callsPast => 'السابقة';

  @override
  String get callsUpcoming => 'القادمة';

  @override
  String get callsBookNew => 'حجز موعد جديد';

  @override
  String callsWithNutritionist(String name) {
    return 'مع $name';
  }

  @override
  String get appointmentReminderChannel => 'تذكيرات المواعيد';

  @override
  String get appointmentReminderTitle => 'موعد قادم';

  @override
  String get appointmentReminderDay => 'موعدك بعد ٢٤ ساعة';

  @override
  String get appointmentReminderHour => 'موعدك بعد ساعة';

  @override
  String get appointmentReminderFiveMinutes => 'موعدك يبدأ بعد ٥ دقائق';

  @override
  String get callsTypeFollowUp => 'جلسة متابعة';

  @override
  String get callsTypeQuickConsult => 'استشارة سريعة';

  @override
  String get callsTypeOther => 'موعد';

  @override
  String get callsChannelWhatsapp => 'واتساب';

  @override
  String get callsChannelPhone => 'مكالمة هاتفية';

  @override
  String get callsChannelVideo => 'مكالمة فيديو';

  @override
  String get callsStatusBooked => 'محجوز';

  @override
  String get callsStatusCancelled => 'ملغى';

  @override
  String get callsStatusNoShow => 'لم يحضر';

  @override
  String get callsEmptyUpcoming => 'لا توجد مواعيد قادمة.';

  @override
  String get callsEmptyPast => 'لا توجد مواعيد سابقة بعد.';

  @override
  String get wellbeingSleepQuality => 'جودة نومك الليلة الماضية';

  @override
  String get wellbeingHours => 'ساعات';

  @override
  String get wellbeingGoodSleep => 'نوم جيد — استمري على نفس الروتين';

  @override
  String get wellbeingStressLevel => 'مستوى الإجهاد';

  @override
  String get wellbeingLow => 'منخفض';

  @override
  String get wellbeingBreathingMoment => 'لحظة تنفّس';

  @override
  String get specialistTitle => 'ملف الأخصائي';

  @override
  String get specialistAboutTitle => 'عن أخصائي التغذية';

  @override
  String get specialistProfileActive => 'الملف الغذائي العلاجي نشط';

  @override
  String get specialistCertified => 'معتمد';

  @override
  String get specialistLicensed => 'مرخصة';

  @override
  String get specialistLicensedByAuthority => 'مرخصة من الهيئة الصحية';

  @override
  String get specialistDirectCare => 'رعاية فردية مباشرة';

  @override
  String get specialistHoursTitle => 'أوقات الرد والمتابعة المعتادة';

  @override
  String get specialistQuickConsult => 'استشارة سريعة مع أخصائي التغذية';

  @override
  String get specialistQuickConsultBody =>
      'تواصل في أي وقت لمناقشة تعديلات الوجبات والشعور العام';

  @override
  String get specialistContactWhatsApp => 'تواصل عبر واتساب';

  @override
  String get specialistContactNote =>
      'يفتح محادثة مباشرة مع أخصائي التغذية لمتابعة حالتك';

  @override
  String get splashTagline => 'خطوة صغيرة نحو صحة أفضل';

  @override
  String get splashSubtitle => 'نرافقك نحو حياة أكثر توازنًا، يومًا بعد يوم.';

  @override
  String get splashCaringEveryDay => 'نعتني بصحتك، كل يوم';

  @override
  String get splashPreparing => 'جاري تجهيز تجربتك الصحية';

  @override
  String get weekdayShortSaturday => 'السبت';

  @override
  String get weekdayShortFriday => 'الجمعة';

  @override
  String get weeklyPlanPreviewScreen => 'شاشة استعراض الخطة والتحضير المسبق';

  @override
  String get weeklyPlanLoggingHint =>
      'لتسجيل الوجبات وتأكيد تناولها يرجى التوجه لتبويب خطتي اليومية';

  @override
  String get weeklyPlanWeekThree => 'الأسبوع الثالث';

  @override
  String get weeklyPlanMonth => 'سبتمبر 2025';

  @override
  String get weeklyPlanDetailed => 'خطة غذائية مفصلة';

  @override
  String weeklyPlanDayPlan(Object day, Object date) {
    return 'خطة يوم $day • $date سبتمبر';
  }

  @override
  String get macroHealthyFatsShort => 'دهون صحية';

  @override
  String get macroProteinLabel => 'بروتين';

  @override
  String get macroFatLabel => 'دهون';

  @override
  String get weeklyPlanFats => '42 غ';

  @override
  String get weeklyPlanCarbs => '120 غ';

  @override
  String get weeklyPlanProtein => '105 غ';

  @override
  String get weeklyPlanSummary =>
      'خطة متوازنة لتعزيز الطاقة وحرق الدهون بإشراف أخصائي التغذية';

  @override
  String get connectionStatusTitle => 'حالة الاتصال';

  @override
  String datePickerKcal(Object value) {
    return '$value س';
  }

  @override
  String get liveBadge => 'مباشر';

  @override
  String get lockedContactSpecialist => 'تواصل مع أخصائي التغذية';

  @override
  String get mealCardLogged => 'تم تسجيل الوجبة';

  @override
  String get mealCardNextCurrent => 'الوجبة القادمة / الحالية';

  @override
  String get mealCardScheduledLater => 'مجدولة لاحقاً';

  @override
  String get mealCardLogNow => 'سجّل هذه الوجبة الآن';

  @override
  String get offlineBannerSyncing => 'جاري مزامنة بياناتك...';

  @override
  String get offlineBannerOffline => 'أنت غير متصل بالإنترنت الآن';

  @override
  String get offlineBannerUpdating => 'يتم تحديث سجلاتك مع الخادم الآن';

  @override
  String get offlineBannerSavedLocally => 'بياناتك محفوظة محلياً بأمان تام';

  @override
  String offlineBannerPending(Object count) {
    return '$count بانتظار المزامنة';
  }

  @override
  String get offlinePanelBrowsePlan => 'تصفح خطة وجبات اليوم المخزنة';

  @override
  String get offlinePanelBrowsePlanDesc =>
      'جداول السعرات والمكونات متوفرة بدون اتصال';

  @override
  String get offlinePanelLogMeasurements => 'تسجيل قياسات الوزن والمحيط';

  @override
  String get offlinePanelLogMeasurementsDesc =>
      'يتم حفظ التغييرات بقاعدة بيانات الهاتف المشفرة';

  @override
  String get offlinePanelNotes => 'تدوين الملاحظات والوجبات السريعة';

  @override
  String get offlinePanelNotesDesc =>
      'تُدرج في قائمة الانتظار للمزامنة الفورية لاحقاً';

  @override
  String get offlinePanelPrivacy => 'حماية الخصوصية والتشفير المحلي';

  @override
  String get offlinePanelPrivacyDesc =>
      'تشفير متقدم يحمي سجلاتك الصحية دون الحاجة لسيرفر';

  @override
  String get offlinePanelSavedNote =>
      'بياناتك ووجباتك المسجلة محفوظة بأمان تام على جهازك. سنقوم بالمزامنة السحابية تلقائياً فور عودة الشبكة.';

  @override
  String get offlinePanelLocally => 'محلياً';

  @override
  String get offlinePanelModeActive => 'الوضع غير المتصل نشط';

  @override
  String get offlinePanelContinue =>
      'يمكنك متابعة تصفح خطتك الغذائية وتسجيل وجباتك كالمعتاد بدون أي انقطاع.';

  @override
  String get offlinePanelWhatNow => 'ما الذي يمكنك إنجازه الآن؟';

  @override
  String onboardingStepOf(Object step, Object total, Object percent) {
    return 'خطوة $step من $total ($percent%)';
  }

  @override
  String get onboardingStepBrand => 'HealthyLife • الملف الصحي';

  @override
  String get breathingInhale => 'شهيق';

  @override
  String get breathingExhale => 'زفير';

  @override
  String substitutionKcalDelta(Object sign, Object delta) {
    return '($sign$delta سعرة)';
  }

  @override
  String get substitutionOriginal => 'الصنف الأصلي';

  @override
  String get substitutionFixed => 'ثابت';

  @override
  String get substitutionCoreNoAlternative => 'صنف أساسي، بدون بديل';

  @override
  String dailyLogMealsCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText وجبات',
      two: 'وجبتان',
      one: 'وجبة واحدة',
    );
    return '$_temp0';
  }

  @override
  String foodSearchFoodsCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText طعاماً',
      few: '$countText أطعمة',
      two: 'طعامان',
      one: 'طعام واحد',
    );
    return '$_temp0';
  }

  @override
  String mealLoggedCountdown(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText ثوانٍ',
      two: 'ثانيتان',
      one: 'ثانية واحدة',
    );
    return '$_temp0';
  }

  @override
  String mealLoggedMealsCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText وجبات',
      two: 'وجبتين',
      one: 'وجبة واحدة',
    );
    return '$_temp0';
  }

  @override
  String notificationsNewCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لديك $countText إشعارات جديدة',
    );
    return '$_temp0';
  }

  @override
  String redirectCountdown(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جاري نقلك تلقائياً خلال $countText ثوانٍ…',
      one: 'جاري نقلك تلقائياً خلال $countText ثانية…',
    );
    return '$_temp0';
  }

  @override
  String languageSubtitleCurrent(String languageName) {
    return '(اللغة الحالية للتطبيق) $languageName';
  }

  @override
  String get commonShow => 'إظهار';

  @override
  String get commonHide => 'إخفاء';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle =>
      'استخدم اسم المستخدم وكلمة المرور اللذين أرسلهما لك أخصائيك عبر واتساب.';

  @override
  String get loginUsername => 'اسم المستخدم';

  @override
  String get loginUsernameHint => 'بالأحرف الإنجليزية فقط';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginCta => 'تسجيل الدخول';

  @override
  String get loginErrorRequired => 'أدخل اسم المستخدم وكلمة المرور.';

  @override
  String get loginErrorInvalid => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String loginErrorLocked(String time) {
    return 'تم إيقاف الدخول مؤقتًا بعد عدة محاولات خاطئة. حاول بعد $time.';
  }

  @override
  String get loginErrorRateLimited =>
      'محاولات كثيرة خلال وقت قصير، انتظر قليلًا ثم حاول مجددًا.';

  @override
  String get loginErrorGeneric => 'تعذّر تسجيل الدخول. حاول مجددًا.';

  @override
  String get loginForgotBody =>
      'اطلب من أخصائيك إعادة تعيين كلمة المرور. سيرسل لك اسم المستخدم وكلمة مرور جديدة عبر واتساب.';

  @override
  String get sessionEndedMessage => 'انتهت جلستك. يرجى تسجيل الدخول مجددًا.';

  @override
  String get passwordRuleLowercase => 'حرف صغير واحد على الأقل (a–z)';

  @override
  String get passwordErrorLowercase => 'أضف حرفًا صغيرًا واحدًا على الأقل';

  @override
  String get passwordCurrentWrong => 'كلمة المرور الحالية غير صحيحة.';

  @override
  String get passwordWeakServer =>
      'كلمة المرور الجديدة لا تستوفي الشروط. اختر كلمة أخرى.';

  @override
  String get consentVersionChanged =>
      'تم تحديث سياسة الخصوصية، اطّلع على النسخة الجديدة.';

  @override
  String get linkCouldNotOpen => 'تعذّر فتح الرابط.';

  @override
  String followUpWeeksValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أسبوعًا',
      many: '$count أسبوعًا',
      few: '$count أسابيع',
      two: 'أسبوعان',
      one: 'أسبوع واحد',
      zero: 'لا توجد أسابيع',
    );
    return '$_temp0';
  }

  @override
  String get followUpWeeksLabel => 'أسابيع المتابعة';

  @override
  String followUpAdherenceValue(String value) {
    return '$value%';
  }

  @override
  String get passwordTemporaryTitle => 'كلمة المرور مؤقتة';

  @override
  String get passwordTemporaryBody =>
      'غيّرها إلى كلمة مرور خاصة بك. يمكنك متابعة استخدام التطبيق.';

  @override
  String get accountDeleteTitle => 'حذف الحساب';

  @override
  String get accountDeleteWarningTitle => 'لا يمكن التراجع عن هذا';

  @override
  String get accountDeleteWarningBody => 'سيُحذف حسابك وكل بياناتك نهائياً.';

  @override
  String get accountDeletePasswordLabel => 'كلمة المرور الحالية';

  @override
  String get accountDeleteCta => 'حذف حسابي';

  @override
  String get accountDeleteConfirmTitle => 'حذف الحساب نهائياً؟';

  @override
  String get accountDeleteConfirmMessage =>
      'سيُحذف حسابك وكل بياناتك نهائياً. لا يمكن التراجع عن ذلك.';

  @override
  String get accountDeleteWrongPassword => 'كلمة المرور غير صحيحة.';

  @override
  String get healthGoalNotSet => 'لم يُحدَّد هدف بعد';

  @override
  String get healthGoalWeightLoss => 'إنقاص الوزن';

  @override
  String get healthGoalWeightGain => 'زيادة الوزن';

  @override
  String get healthGoalMuscleGain => 'بناء العضل';

  @override
  String get healthGoalWeightMaintenance => 'تثبيت الوزن';

  @override
  String get healthGoalHealthEnergy => 'صحة وطاقة';

  @override
  String get healthGoalMedicalCondition => 'حالة صحية';

  @override
  String get healthGoalOther => 'أخرى';

  @override
  String healthGoalTarget(String value) {
    return 'المستهدف: $value';
  }

  @override
  String healthGoalTargetDate(String date) {
    return 'حتى $date';
  }

  @override
  String get healthNoMedications => 'لا توجد أدوية مسجّلة';

  @override
  String get healthTimingBefore => 'قبل الأكل';

  @override
  String get healthTimingWith => 'مع الأكل';

  @override
  String get healthTimingAfter => 'بعد الأكل';

  @override
  String get healthTimingEmptyStomach => 'على معدة فارغة';

  @override
  String get healthTimingAny => 'في أي وقت';

  @override
  String get healthMedStatusOngoing => 'مستمر';

  @override
  String healthMedStatusUntil(String date) {
    return 'حتى $date';
  }

  @override
  String get healthMedReviewedBy => 'راجعها أخصائيك';

  @override
  String healthMedReviewedOn(String date) {
    return 'آخر مراجعة $date';
  }

  @override
  String get healthMedDisclaimer =>
      'هذه المعلومات لمتابعة أخصائيك فقط ولا تُعد نصيحة دوائية. لا تغيّر أدويتك دون استشارة طبيبك.';

  @override
  String get healthNoAllergies => 'لم تُسجَّل أي حساسية';

  @override
  String get healthAllergyFooter =>
      'تظهر تنبيهات على الأطعمة التي قد تحتوي على مسبباتها في خطتك.';

  @override
  String get healthAllergyClassConfirmed => 'حساسية مؤكدة';

  @override
  String get healthAllergyClassIntolerance => 'عدم تحمّل';

  @override
  String get healthAllergyClassAvoid => 'أتجنبه';

  @override
  String get healthRequestsTitle => 'طلب تعديل';

  @override
  String get healthRequestIntro => 'لن يُطبَّق أي تعديل قبل اعتماد أخصائيك.';

  @override
  String get healthRequestGoalSection => 'الهدف';

  @override
  String get healthRequestMedicationsSection => 'الأدوية';

  @override
  String get healthRequestAllergiesSection => 'الحساسية';

  @override
  String get healthRequestMyRequestsSection => 'طلباتي';

  @override
  String get healthRequestChangeGoal => 'طلب تعديل الهدف';

  @override
  String get healthRequestAddMedication => 'إضافة دواء';

  @override
  String get healthRequestAddAllergy => 'إضافة حساسية';

  @override
  String get healthRequestGoalTitle => 'تعديل الهدف';

  @override
  String get healthRequestMedicationTitleEdit => 'تعديل دواء';

  @override
  String get healthRequestAllergyTitleEdit => 'تعديل حساسية';

  @override
  String get healthRequestActionAdd => 'إضافة';

  @override
  String get healthRequestActionEdit => 'تعديل';

  @override
  String get healthRequestActionRemove => 'حذف';

  @override
  String get healthRequestRemove => 'حذف';

  @override
  String get healthRequestRemoveTitle => 'طلب حذف؟';

  @override
  String get healthRequestRemoveBody => 'سيراجع أخصائيك الحذف قبل أن يُطبَّق.';

  @override
  String get healthRequestWithdraw => 'سحب الطلب';

  @override
  String get healthRequestWithdrawTitle => 'سحب هذا الطلب؟';

  @override
  String get healthRequestWithdrawBody => 'لن يراه أخصائيك.';

  @override
  String get healthRequestStatusPending => 'بانتظار اعتماد الأخصائي';

  @override
  String get healthRequestStatusApproved => 'تمت الموافقة';

  @override
  String get healthRequestStatusRejected => 'لم تُعتمد';

  @override
  String get healthRequestStatusWithdrawn => 'سُحب';

  @override
  String get healthRequestPendingChip => 'بانتظار الاعتماد';

  @override
  String get healthRequestNoRequests => 'لا توجد طلبات في آخر 60 يومًا.';

  @override
  String healthRequestDecisionNote(String note) {
    return 'ملاحظة أخصائيك: $note';
  }

  @override
  String get healthRequestSend => 'إرسال الطلب';

  @override
  String get healthRequestSent =>
      'تم إرسال طلبك. لن يُطبَّق قبل اعتماد أخصائيك.';

  @override
  String get healthRequestWithdrawnSnack => 'تم سحب الطلب.';

  @override
  String get healthRequestAlreadyPending =>
      'هناك طلب بانتظار الاعتماد لهذا العنصر بالفعل.';

  @override
  String get healthRequestAlreadyRecorded =>
      'هذه الحساسية مسجلة في ملفك بالفعل.';

  @override
  String get healthRequestNotPending => 'تم البتّ في هذا الطلب، ولا يمكن سحبه.';

  @override
  String get healthRequestInvalid => 'راجع الحقول المحددة.';

  @override
  String get healthRequestFieldRequired => 'مطلوب';

  @override
  String get healthRequestFieldNumber => 'أدخل رقمًا';

  @override
  String healthRequestFieldRange(String min, String max) {
    return 'أدخل رقمًا من $min إلى $max';
  }

  @override
  String healthRequestFieldTooLong(String max) {
    return '$max حرفًا كحد أقصى';
  }

  @override
  String get healthRequestFieldNotAfterToday => 'اختر تاريخًا بعد اليوم';

  @override
  String get healthRequestFieldBeforeToday => 'اختر اليوم أو تاريخًا لاحقًا';

  @override
  String get healthRequestGoalType => 'نوع الهدف';

  @override
  String get healthRequestTargetWeight => 'الوزن المستهدف (كغ)';

  @override
  String get healthRequestTargetDate => 'تاريخ الهدف';

  @override
  String get healthRequestChooseDate => 'اختر تاريخًا';

  @override
  String get healthRequestActivity => 'مستوى النشاط';

  @override
  String get healthRequestTrainingDays => 'أيام التمرين في الأسبوع';

  @override
  String get healthRequestTrainingLevel => 'مستوى التمرين';

  @override
  String get healthRequestTrainingType => 'نوع التمرين';

  @override
  String get healthRequestDetails => 'تفاصيل';

  @override
  String get healthRequestName => 'الاسم';

  @override
  String get healthRequestDose => 'الجرعة';

  @override
  String get healthRequestFrequency => 'عدد المرات';

  @override
  String get healthRequestTiming => 'وقت التناول';

  @override
  String get healthRequestReason => 'سبب الاستخدام';

  @override
  String get healthRequestDuration => 'مدة الاستخدام';

  @override
  String get healthRequestUntilDate => 'حتى تاريخ';

  @override
  String get healthRequestAllergy => 'الحساسية';

  @override
  String get healthRequestOtherText => 'صفها';

  @override
  String get healthRequestClass => 'درجة الحساسية';

  @override
  String get healthRequestNote => 'ملاحظة';

  @override
  String get healthAllergyGroupTreeNuts => 'المكسرات';

  @override
  String get healthAllergyGroupPeanuts => 'الفول السوداني';

  @override
  String get healthAllergyGroupMilk => 'الحليب ومشتقاته (اللاكتوز)';

  @override
  String get healthAllergyGroupEgg => 'البيض';

  @override
  String get healthAllergyGroupWheat => 'القمح والجلوتين';

  @override
  String get healthAllergyGroupSesame => 'السمسم';

  @override
  String get healthAllergyGroupFish => 'السمك';

  @override
  String get healthAllergyGroupShellfish => 'القشريات والمأكولات البحرية';

  @override
  String get healthAllergyGroupSoy => 'الصويا';

  @override
  String get healthAllergyGroupOther => 'أخرى (اكتبها)';

  @override
  String get healthActivitySedentary => 'قليل الحركة';

  @override
  String get healthActivityLight => 'نشاط خفيف';

  @override
  String get healthActivityModerate => 'نشاط متوسط';

  @override
  String get healthActivityActive => 'نشيط';

  @override
  String get healthActivityVeryActive => 'نشيط جدًا';

  @override
  String get healthTrainingBeginner => 'مبتدئ';

  @override
  String get healthTrainingIntermediate => 'متوسط';

  @override
  String get healthTrainingAdvanced => 'متقدم';

  @override
  String get healthTrainingStrength => 'تمارين قوة';

  @override
  String get healthTrainingCardio => 'كارديو';

  @override
  String get healthTrainingMixed => 'مختلط';

  @override
  String get healthTrainingSports => 'رياضات';

  @override
  String get foodSearchTypeToSearch => 'اكتب حرفين على الأقل للبحث.';

  @override
  String get foodSearchResultsTitle => 'النتائج';

  @override
  String get foodAllergyBadge => 'قد يحتوي مسبب حساسيتك';

  @override
  String get reviewsTitle => 'ملاحظات الأخصائي';

  @override
  String get reviewsEntrySubtitle => 'اقرأ الملاحظات وأنجز المهام';

  @override
  String get reviewsEmpty => 'لا توجد ملاحظات بعد. ستظهر ملاحظات أخصائيك هنا.';

  @override
  String get reviewRatingOnTrack => 'على المسار';

  @override
  String get reviewRatingSmallAdjustment => 'تعديل بسيط';

  @override
  String get reviewRatingReviewTogether => 'لنراجع معًا';

  @override
  String get reviewEdited => 'عدّلها أخصائيك';

  @override
  String get reviewKeyPointsTitle => 'أهم النقاط';

  @override
  String get reviewTasksTitle => 'المهام';

  @override
  String get reviewAcknowledge => 'فهمت';

  @override
  String get reviewSeen => 'تم الاطلاع';

  @override
  String get mealTypeBreakfast => 'الفطور';

  @override
  String get mealTypeLunch => 'الغداء';

  @override
  String get mealTypeDinner => 'العشاء';

  @override
  String get mealTypeSnack => 'وجبة خفيفة';

  @override
  String get mealTypeOther => 'وجبة';

  @override
  String homeSuggestedAlternative(String grams, String food) {
    return 'البديل المقترح: $food ($grams غرام)';
  }

  @override
  String get planEmptyTitle => 'لا توجد خطة مفعّلة بعد';

  @override
  String get planEmptyBody => 'ستظهر خطتك هنا فور تفعيلها من أخصائي التغذية.';

  @override
  String get planNoMealToday => 'لا توجد وجبات في خطتك لهذا اليوم';

  @override
  String weeklyPlanWeekNumber(String week) {
    return 'الأسبوع $week من الخطة';
  }

  @override
  String get weeklyPlanFromNutritionist => 'خطتك كما وضعها أخصائي التغذية';

  @override
  String get mealDetailFromPlan => 'من خطة أخصائي التغذية';

  @override
  String weeklyPlanDayOf(String date) {
    return 'خطة يوم $date';
  }

  @override
  String get nutritionistAvatarLabel => 'صورة الأخصائي';

  @override
  String get patientAvatarLabel => 'صورة الحساب';

  @override
  String get notificationsYesterday => 'أمس';

  @override
  String get notificationsJustNow => 'الآن';

  @override
  String notificationsMinutesAgo(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $countText دقيقة',
      few: 'منذ $countText دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة',
    );
    return '$_temp0';
  }

  @override
  String notificationsHoursAgo(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $countText ساعة',
      few: 'منذ $countText ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة',
    );
    return '$_temp0';
  }

  @override
  String get notificationsLoadOlder => 'عرض الإشعارات الأقدم';

  @override
  String get weighInReminderChannel => 'تذكير القياس الأسبوعي';

  @override
  String get weighInReminderTitle => 'حان موعد قياسك الأسبوعي';

  @override
  String get weighInReminderBody =>
      'سجّل وزنك الآن بعد الاستيقاظ لتبقى متابعتك دقيقة.';

  @override
  String get notificationSettingsNutritionistDesc =>
      'ملاحظات أخصائي التغذية الجديدة وتعديلاتها.';

  @override
  String get notificationSettingsSaveFailed =>
      'تعذّر حفظ الإعداد. تحقق من اتصالك ثم حاول مرة أخرى.';
}
