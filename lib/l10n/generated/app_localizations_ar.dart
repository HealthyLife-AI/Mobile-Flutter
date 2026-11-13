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
  String get commonErrorBody => 'تعذّر تحميل البيانات. حاول مرة أخرى.';

  @override
  String get commonOfflineTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get commonOfflineBody => 'تحقق من اتصالك بالشبكة ثم أعد المحاولة.';

  @override
  String get validationRequired => 'هذا الحقل مطلوب';

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
  String get aboutCertifiedRegulations => 'السياسات والشروط';

  @override
  String get aboutSessionAccountTitle => 'منطقة الجلسة والحساب';

  @override
  String get aboutCopyright =>
      'HealthyLife Clinical Suite © 2026 • جميع الحقوق محفوظة';

  @override
  String get aboutBrandName => 'حياة صحية';

  @override
  String get aboutTagline => 'متابعة التغذية مع أخصائي التغذية';

  @override
  String aboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutDescription =>
      'تطبيق يساعدك على متابعة خطتك الغذائية مع أخصائي التغذية.';

  @override
  String get aboutPrivacyPolicyTitle => 'سياسة الخصوصية وأمان البيانات الصحية';

  @override
  String get aboutPrivacyPolicySubtitle => 'اقرأ السياسة المنشورة على موقعنا';

  @override
  String get aboutMedicalTermsTitle => 'شروط الاستخدام';

  @override
  String get aboutMedicalTermsSubtitle =>
      'إرشادات استخدام التطبيق ومتابعة الخطة';

  @override
  String get aboutLicensesTitle => 'تراخيص البرمجيات';

  @override
  String get aboutLicensesSubtitle =>
      'المكتبات مفتوحة المصدر المستخدمة في التطبيق';

  @override
  String get aboutSupportTitle => 'الدعم الفني ومساعدة التطبيق';

  @override
  String get aboutSupportSubtitle => 'تواصل مع أخصائيك عبر واتساب';

  @override
  String get aboutSupportNoNumber => 'لا يوجد رقم واتساب لأخصائيك بعد.';

  @override
  String get aboutStandardHealthProtection => 'حماية بياناتك';

  @override
  String get aboutEncryptionNote =>
      'الاتصال بين التطبيق وخوادمنا مشفّر، ونأخذ نسخة احتياطية مشفّرة يوميًا.';

  @override
  String get aboutLogoutNote =>
      'سيتم إنهاء جلستك بأمان، وتبقى سجلاتك وقياساتك محفوظة في حسابك.';

  @override
  String get achievementsTitle => 'إنجازاتك';

  @override
  String get activationNewPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordRuleUppercase => 'حرف كبير واحد على الأقل (A-Z)';

  @override
  String get passwordRuleDigit => 'رقم واحد على الأقل (0-9)';

  @override
  String get activationEncryptedNote => 'الاتصال بين التطبيق وخوادمنا مشفّر.';

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
  String get entryEditLocked =>
      'مرّ أكثر من 7 أيام على تسجيل هذا الإدخال، فلا يمكن تعديله.';

  @override
  String get dailyLogDeleteOffline =>
      'لم تُحذف الوجبة: الحذف يحتاج اتصالًا بالإنترنت. حاول مجددًا عند الاتصال.';

  @override
  String get dailyLogDeleteFailed => 'تعذّر حذف الوجبة. حاول مرة أخرى.';

  @override
  String get dailyLogEditGramsTitle => 'تعديل الكمية';

  @override
  String get dailyLogEditGramsLabel => 'الكمية (غرام)';

  @override
  String get dailyLogEditGramsRange => 'أدخل كمية بين 1 و5000 غرام.';

  @override
  String get dailyLogGramsChanged => 'تم تعديل الكمية';

  @override
  String get dailyLogEditOffline =>
      'لم تُحفظ الكمية: التعديل يحتاج اتصالًا بالإنترنت. حاول مجددًا عند الاتصال.';

  @override
  String get dailyLogEditGone => 'لم يعد هذا الإدخال موجودًا، فأُزيل من سجلك.';

  @override
  String get dailyLogEditFailed => 'تعذّر حفظ الكمية. حاول مرة أخرى.';

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
      'يتطلب رسم منحنى التقدم قياسين على الأقل لإظهار اتجاه التغيّر. تسجيلك القادم سيفعّل المخطط البياني.';

  @override
  String get firstMeasurementLogNew => 'سجّل قياساً جديداً';

  @override
  String get firstMeasurementBackToPlan => 'العودة إلى خطتي اليومية';

  @override
  String get firstMeasurementBaseline => 'نقطة البداية';

  @override
  String get firstMeasurementInitial => 'القياس الأولي المسجل';

  @override
  String commonKgValue(Object value) {
    return '$value كغ';
  }

  @override
  String get firstMeasurementBaselineSaved =>
      'تم توثيق نقطة البداية بنجاح في ملفك الصحي.';

  @override
  String get firstMeasurementJourneyNote =>
      'قياس واحد يحدد نقطة البداية، والقياس القادم يبدأ برسم تقدمك مع أخصائي التغذية خطوة بخطوة.';

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
  String get followUpMealAdherence => 'الالتزام بالوجبات';

  @override
  String get followUpEndedTitle => 'انتهت المتابعة';

  @override
  String get followUpPlanCompleted => 'اكتمال خطة المتابعة';

  @override
  String get followUpPeriodEnded => 'انتهت فترة متابعتك الحالية';

  @override
  String get followUpEndedMessage =>
      'انتهت فترة المتابعة الحالية مع أخصائي التغذية. للتجديد أو لمتابعة نظامك الغذائي والحصول على خطة جديدة، يمكنك التواصل مباشرة.';

  @override
  String get followUpSupervisor => 'مشرفك';

  @override
  String get followUpSupervisingSpecialist => 'أخصائي التغذية المشرف عليك';

  @override
  String get followUpRecordsSafe =>
      'سجلاتك وقياساتك السابقة محفوظة بأمان تام في ملفك الصحي، ويمكن استئناف الخطة والمتابعة فوراً بمجرد التجديد.';

  @override
  String get followUpContactWhatsApp => 'التواصل مع أخصائي التغذية عبر واتساب';

  @override
  String get followUpTerms => 'شروط الخدمة وسياسة الخصوصية للبيانات الصحية';

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
      'جرّب كلمة أخرى أو اطلب إضافة الصنف من الأسفل';

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
        'male': 'أخصائي التغذية $name بانتظارك',
        'female': 'أخصائية التغذية $name بانتظارك',
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
  String get consentClauseStorageTitle => 'كيف نحمي بياناتك؟';

  @override
  String get consentClauseStorageBody =>
      'الاتصال بين التطبيق وخوادمنا مشفّر، ونأخذ نسخة احتياطية مشفّرة يوميًا.';

  @override
  String get consentClauseAccessTitle => 'من يمكنه الاطلاع عليها؟';

  @override
  String get consentClauseAccessBody =>
      'بياناتك الصحية يطّلع عليها أخصائيك فقط، ولا نبيعها ولا نستخدمها للإعلانات.';

  @override
  String get consentClauseRevokeTitle => 'حقك في حذف بياناتك';

  @override
  String get consentClauseRevokeBody =>
      'يمكنك حذف بياناتك أو حسابك من التطبيق في أي وقت.';

  @override
  String get privacyOnWebsite => 'سياسة الخصوصية متوفرة على موقعنا.';

  @override
  String get consentExitTitle => 'الخروج من إعداد ملفك الصحي؟';

  @override
  String get consentExitMessage =>
      'لا يمكن متابعة الخطة الغذائية أو الوصول إليها قبل الموافقة على شروط الخصوصية الصحية.';

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
  String get consentReadFullDocument => 'قراءة وثيقة الخصوصية الكاملة';

  @override
  String get consentVerified => 'موثّق';

  @override
  String get consentCta => 'متابعة إعداد خطتي الصحية';

  @override
  String get consentPleaseAgree => 'يُرجى الموافقة على شروط الخصوصية للمتابعة';

  @override
  String get consentCharterTitle => 'ميثاق الخصوصية التغذوية';

  @override
  String get consentConfidentialVerified => 'موثّق سري';

  @override
  String get consentDataUseNote =>
      'بياناتك (سجل الوجبات، القياسات، والحالة الصحية) تصل إلى أخصائي التغذية المتابع لك فقط، وتُستخدم لبناء خطتك الغذائية ومتابعة تقدمك.';

  @override
  String get consentTitle => 'الموافقة على استخدام البيانات الصحية';

  @override
  String get consentBeforeWeStart => 'قبل أن نبدأ';

  @override
  String get consentCommitment => 'نلتزم بحماية خصوصية بياناتك الصحية.';

  @override
  String get consentCheckbox =>
      'قرأت ووافقت على شروط مشاركة البيانات بسياسة الخصوصية الصحية.';

  @override
  String get consentRevocable =>
      'موافقتك قابلة للتعديل أو الإلغاء فوراً في أي وقت.';

  @override
  String get healthRecordTitle => 'السجل الصحي';

  @override
  String get healthRecordAllergies => 'الحساسية والموانع';

  @override
  String get healthRecordCurrentGoal => 'الهدف الصحي الاستراتيجي الحالي';

  @override
  String get healthRecordMedications => 'الأدوية والمكملات اليومية المسجّلة';

  @override
  String get healthRecordActive => 'نشط';

  @override
  String get commonViewDetails => 'عرض التفاصيل';

  @override
  String get offlineWriteDropped =>
      'لم يقبل الخادم قياساً سجّلته دون اتصال، ولم يُحفظ.';

  @override
  String get healthRecordCertified => 'السجل الصحي';

  @override
  String get healthRecordDiagnosesNote =>
      'الحالات الصحية والمحاذير التي تُراعى في خطتك';

  @override
  String get healthRecordRequestChange =>
      'طلب تعديل أو إضافة تقرير إلى السجل الصحي';

  @override
  String get healthSyncTitle => 'ربط تطبيق الصحة';

  @override
  String get homeItemTwoBoiledEggs => '2 بيضة مسلوقة';

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
      'شرب كوبين من الماء قبل الوجبة قد يساعد على الشعور بالشبع، والاستمرار على الخطة خطوة بعد خطوة.';

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
  String get logMealPlannedBadge => 'وجبات الخطة';

  @override
  String get logMealFromPlanTitle => 'سجّلت وجبة من خطتي';

  @override
  String get logMealFromPlanDesc =>
      'تأكيد سريع لتناول إحدى وجبات جدول اليوم (فطور، سناك، غداء، عشاء) مع إمكانية اختيار البدائل المتاحة في الخطة.';

  @override
  String get logMealFromPlanNote => 'مطابقة تلقائية للسعرات والمكونات المجدولة';

  @override
  String get logMealFromPlanNote2 =>
      'استبدال ذكي للبدائل المتكافئة بنقرة واحدة';

  @override
  String get logMealFromPlanFooter => 'المتابعة لاختيار الوجبة';

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
  String get logMealOffPlanFooter => 'المتابعة للبحث وحساب الغرامات';

  @override
  String get logMealPrivacyNote => 'سجل وجباتك يطّلع عليه أخصائيك فقط.';

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
        'male': 'وجبة ضمن خطة أخصائي التغذية $name',
        'female': 'وجبة ضمن خطة أخصائية التغذية $name',
        'unknown': 'وجبة ضمن خطة أخصائي التغذية',
        'other': 'وجبة ضمن خطة $name',
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
  String get mealLoggedBody => 'تم تحديث سجل اليوم.';

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
      '🎬 قريباً: فيديو إرشادي قصير (10 ثوان) لكل قياس لتسهيل المتابعة العملية المباشرة.';

  @override
  String get guideDoneBack => 'فهمت، العودة لتسجيل القياسات';

  @override
  String get guideZoom => 'تكبير الرسم';

  @override
  String get measurementsTitle => 'الوزن ومحيط الجسم';

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
  String get measurementsClinicReading => 'قياس العيادة';

  @override
  String get measurementsHomeReading => 'قياس منزلي';

  @override
  String get measurementsHistoryTitle => 'سجل القراءات';

  @override
  String get measurementsDeleteReading => 'حذف القراءة';

  @override
  String get measurementsDeleteConfirmTitle => 'حذف هذه القراءة؟';

  @override
  String get measurementsDeleteConfirmBody =>
      'ستُحذف من سجلّك، ولن يراها أخصائيك بعد الآن.';

  @override
  String get measurementsDeleted => 'تم حذف القراءة';

  @override
  String get measurementsDeleteClinic =>
      'سجّل أخصائيك هذه القراءة في العيادة، فلا يمكن حذفها من التطبيق.';

  @override
  String get measurementsDeleteOffline =>
      'لم تُحذف القراءة: الحذف يحتاج اتصالًا بالإنترنت. حاول مجددًا عند الاتصال.';

  @override
  String get measurementsDeleteFailed => 'تعذّر حذف القراءة. حاول مرة أخرى.';

  @override
  String get measurementsSyncNote =>
      'بياناتك متزامنة مع قياسات العيادة وسجلك الشخصي.';

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
      'التسجيل المنتظم يساعد أخصائي التغذية على متابعة نمطك واقتراح الخيارات الأنسب لك.';

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
  String measurementEntryToday(String date) {
    return 'اليوم، $date';
  }

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
            'بياناتك محمية وتصل إلى ملفك الصحي لدى أخصائي التغذية، ليُعدّل خطتك بما يناسبك.',
        'other':
            'بياناتك محمية وتصل إلى ملفك الصحي لدى $name، ليُعدّل خطتك بما يناسبك.',
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
  String get notificationsClinicalUpdate => 'تحديث من الأخصائي';

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
  String get onboardingHealthTitle => 'البيانات الصحية';

  @override
  String get onboardingHealthConditions => 'الحالات الصحية والأمراض';

  @override
  String get onboardingHealthConditionsNote =>
      'اختيار الحالات الصحية المشخّصة يوصلها إلى الأخصائي لمراعاتها في الخطة.';

  @override
  String get onboardingHealthConfidentialNote =>
      'يطّلع على هذه التفاصيل أخصائيك فقط، وتساعده في استبعاد أي مكونات قد تتعارض مع حالتك أو أدويتك.';

  @override
  String get onboardingHealthAllergies => 'الحساسية الغذائية والتفضيلات';

  @override
  String get onboardingHealthAllergiesNote =>
      'حدّد ما يسبب لك حساسية، ليراجعه أخصائيك ويضيفه إلى ملفك. بعد اعتماده تظهر علامة تنبيه على الأطعمة التي قد تحتويه.';

  @override
  String get onboardingHealthMedications => 'الأدوية والمكملات المنتظمة';

  @override
  String get onboardingHealthDoseAccuracy => 'دقة الجرعات';

  @override
  String get onboardingHealthMedicationsNote =>
      'اكتب الأدوية أو الفيتامينات التي تتناولها، ليراعيها أخصائيك في توقيت وجباتك ومكوناتها.';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get onboardingHealthMedicationHint =>
      'أدخل اسم الدواء والجرعة (مثال: أوميغا 3)';

  @override
  String get onboardingHealthReviewNote =>
      'يراجع أخصائيك الأدوية والحساسيات قبل إضافتها إلى ملفك.';

  @override
  String get onboardingHealthAllergyClass => 'كيف تؤثر عليك هذه الأطعمة؟';

  @override
  String onboardingHealthRequestConditions(String list) {
    return 'الحالات الصحية (من الإعداد الأولي): $list';
  }

  @override
  String onboardingHealthRequestNotes(String notes) {
    return 'ملاحظات: $notes';
  }

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
      'أدخل وزنك وقياساتك اليوم لنبدأ متابعة تقدمك مع أخصائي التغذية.';

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
      'قياسات إضافية تساعد أخصائي التغذية على متابعة محيط الجسم.';

  @override
  String get onboardingMeasurementsWaistHint => 'عند أضيق نقطة';

  @override
  String get onboardingMeasurementsHipHint => 'المنطقة الأكبر حجماً';

  @override
  String get onboardingMeasurementsThighHint => 'أعلى الفخذ الأيمن';

  @override
  String get onboardingMeasurementsPrivacyNote =>
      'قياساتك يطّلع عليها أخصائيك فقط، ليصمّم خطتك الغذائية بناءً عليها.';

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
      'تذكير أسبوعي في الصباح لقياس الوزن ومتابعة تطوره.';

  @override
  String get onboardingNotificationsEnable => 'تفعيل الإشعارات الآن';

  @override
  String get onboardingNotificationsLater => 'ليس الآن، سأضبطها لاحقاً';

  @override
  String onboardingStepProgress(Object percent) {
    return 'خطوة 3 من 3 ($percent%)';
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
      'تسجيل الوجبات اليومية والوزن بالغرام، مع البدائل التي أتاحها أخصائي التغذية في خطتك.';

  @override
  String get onboardingBadgeSmartScan => 'مسح ذكي فوري';

  @override
  String get onboardingBadgeDetailedAccuracy => 'دقة تفصيلية';

  @override
  String get onboardingPlanTitle => 'خطتك الغذائية بإشراف أخصائيك';

  @override
  String get onboardingPlanDescription =>
      'نظام غذائي يعدّه لك أخصائي التغذية المتابع لك بحسب بياناتك وأهدافك.';

  @override
  String get onboardingBadgeApproved => 'خطة يعدّها أخصائي التغذية المتابع لك';

  @override
  String get onboardingStartNow => 'ابدأ الآن';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get passwordErrorEnterCurrent => 'أدخل كلمة المرور الحالية';

  @override
  String get passwordErrorMinLength => 'اجعلي كلمة المرور 8 أحرف على الأقل';

  @override
  String get passwordErrorUppercase => 'أضف حرفًا كبيرًا واحدًا على الأقل';

  @override
  String get passwordErrorDigit => 'أضف رقمًا واحدًا على الأقل';

  @override
  String get passwordErrorMismatch => 'أكدي كلمة المرور الجديدة بشكل مطابق';

  @override
  String get passwordSaved => 'تم حفظ كلمة المرور بنجاح';

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
  String get passwordRuleMinLength8 => '8 أحرف على الأقل';

  @override
  String get passwordLogoutOthersNote =>
      'بعد تغيير كلمة المرور بنجاح، سيتم تسجيل خروجك من الأجهزة الأخرى تلقائياً لحماية حسابك.';

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
      'يُعدّ أخصائي التغذية الآن جدولك الغذائي بحسب أهدافك وقياساتك الأولية. سنرسل لك إشعاراً فور اعتماد الخطة لتجدها هنا.';

  @override
  String get planPreparingExpectedTime => 'الوقت المتوقع للاعتماد';

  @override
  String get planPreparingWithin24h =>
      'خلال 24 ساعة عمل من تسجيل قياساتك الأولية';

  @override
  String get planPreparingReview => 'يراجعها أخصائي التغذية';

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
      'متاح طوال أيام العمل الرسمية من 9:00 ص حتى 6:00 م';

  @override
  String planPreparingClinic(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'unknown': 'عيادة التغذية',
        'other': 'عيادة التغذية • $name',
      },
    );
    return '$_temp0';
  }

  @override
  String get planPreparingAdvanced => 'تخصيص متقدم';

  @override
  String get commonEnabled => 'مفعّل';

  @override
  String get profileMeasurementsSubtitle => 'سجّل قياساتك وتابع مسار تغيّرك';

  @override
  String get profileHealthRecordSubtitle =>
      'المستوى، الهدف، الأدوية والحالات المسجّلة';

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
        'male': '$name (أخصائي التغذية)',
        'female': '$name (أخصائية التغذية)',
        'unknown': 'أخصائي التغذية',
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
  String profileVersion(String version) {
    return 'الإصدار $version';
  }

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
  String profilePatientCode(String code) {
    return 'كود المريض: $code';
  }

  @override
  String get profileFollowingClinic => 'العيادة المتابعة';

  @override
  String get profileMore => 'المزيد';

  @override
  String get profileMoreSubtitle =>
      'القياسات، السجل الصحي، الإنجازات والمواعيد';

  @override
  String get profileLogoutSubtitle => 'إنهاء الجلسة بأمان من هذا الجهاز';

  @override
  String progressNextAppointment(String date) {
    return 'موعدك القادم: $date';
  }

  @override
  String get progressTitle => 'متابعة التقدم والتقييم';

  @override
  String get progressActiveFile => 'ملف نشط';

  @override
  String get progressLiveSync => 'متزامن مع العيادة';

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
  String get progressClinicReading => 'قياس العيادة';

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
  String get progressWaist => 'الخصر';

  @override
  String get progressHip => 'الورك';

  @override
  String get progressThigh => 'الفخذ';

  @override
  String get progressArm => 'الذراع';

  @override
  String get progressGuideLink => 'دليل القياس المصوّر';

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
  String quantityKcalPerGrams(Object kcal, Object grams) {
    return '$kcal سعرة حرارية لكل $grams غرام';
  }

  @override
  String quantityKcalTimesPortions(Object kcal, Object portions) {
    return '$kcal سعرة × $portions حصة';
  }

  @override
  String get quantityCalculatedNote => 'القيمة محسوبة وتُضاف إلى سجل اليوم.';

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
  String get appointmentReminderDay => 'موعدك بعد 24 ساعة';

  @override
  String get appointmentReminderHour => 'موعدك بعد ساعة';

  @override
  String get appointmentReminderFifteenMinutes => 'موعدك يبدأ بعد 15 دقيقة';

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
  String get specialistTitle => 'ملف الأخصائي';

  @override
  String get specialistAboutTitle => 'عن أخصائي التغذية';

  @override
  String get specialistProfileActive => 'الملف الغذائي نشط';

  @override
  String get specialistCertified => 'أخصائي التغذية المتابع لك';

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
  String get weeklyPlanDetailed => 'خطة غذائية مفصلة';

  @override
  String get macroHealthyFatsShort => 'دهون صحية';

  @override
  String get macroProteinLabel => 'بروتين';

  @override
  String get macroFatLabel => 'دهون';

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
      'تُحفظ التغييرات على هاتفك، وتُرسل عند عودة الاتصال.';

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
  String rateLimitedWaitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ثانية',
      many: '$count ثانية',
      few: '$count ثوانٍ',
      two: 'ثانيتين',
      one: 'ثانية',
    );
    return 'محاولات كثيرة خلال وقت قصير. حاول مجددًا بعد $_temp0.';
  }

  @override
  String rateLimitedWaitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      many: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتين',
      one: 'دقيقة',
    );
    return 'محاولات كثيرة خلال وقت قصير. حاول مجددًا بعد $_temp0.';
  }

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
  String get pushChannelName => 'إشعارات أخصائيك وخطتك';

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

  @override
  String get commonShowAll => 'عرض الكل';

  @override
  String get commonShowLess => 'عرض أقل';

  @override
  String get commonYesterday => 'أمس';

  @override
  String commonCharCount(String count, String max) {
    return '$count / $max';
  }

  @override
  String get planInstructionsTitle => 'تعليمات أخصائي التغذية';

  @override
  String get planActivitiesTitle => 'النشاط البدني';

  @override
  String get planRefreshFailed =>
      'تعذّر تحديث الخطة، تحقّق من اتصالك بالإنترنت';

  @override
  String durationMinutes(int count, String n) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$n دقيقة',
      many: '$n دقيقة',
      few: '$n دقائق',
      two: 'دقيقتين',
      one: 'دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String timesPerDay(int count, String n) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$n مرة يوميًا',
      many: '$n مرة يوميًا',
      few: '$n مرات يوميًا',
      two: 'مرتين يوميًا',
      one: 'مرة يوميًا',
    );
    return '$_temp0';
  }

  @override
  String daysPerWeek(int count, String n) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$n يوم بالأسبوع',
      many: '$n يومًا بالأسبوع',
      few: '$n أيام بالأسبوع',
      two: 'يومين بالأسبوع',
      one: 'يوم واحد بالأسبوع',
    );
    return '$_temp0';
  }

  @override
  String get scheduleWeekly => 'كل أسبوع';

  @override
  String get scheduleBiweekly => 'كل أسبوعين';

  @override
  String get scheduleMonthly => 'كل شهر';

  @override
  String scheduleEveryDays(int count, String n) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل $n يوم',
      many: 'كل $n يومًا',
      few: 'كل $n أيام',
      two: 'كل يومين',
      one: 'كل يوم',
    );
    return '$_temp0';
  }

  @override
  String get scheduleDueTitle => 'حان موعد تسجيل قياساتك';

  @override
  String scheduleYourInterval(String interval) {
    return 'موعدك $interval';
  }

  @override
  String scheduleLastAgo(int count, String n) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'آخر قياس قبل $n يوم',
      many: 'آخر قياس قبل $n يومًا',
      few: 'آخر قياس قبل $n أيام',
      two: 'آخر قياس قبل يومين',
      one: 'آخر قياس أمس',
      zero: 'آخر قياس اليوم',
    );
    return '$_temp0';
  }

  @override
  String get scheduleRecordNow => 'سجّل قياساتك الآن';

  @override
  String get scheduleNextTitle => 'موعد قياسك القادم';

  @override
  String get scheduleDueTodayTitle => 'موعد قياسك اليوم';

  @override
  String scheduleSetBy(String interval) {
    return 'حدّده أخصائي التغذية: $interval';
  }

  @override
  String scheduleInDays(int count, String n) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بعد $n يوم',
      many: 'بعد $n يومًا',
      few: 'بعد $n أيام',
      two: 'بعد يومين',
      one: 'غدًا',
    );
    return '$_temp0';
  }

  @override
  String scheduleLastReading(String date) {
    return 'آخر قياس: $date';
  }

  @override
  String scheduleLateTitle(int count, String n) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قياسك متأخر $n يوم',
      many: 'قياسك متأخر $n يومًا',
      few: 'قياسك متأخر $n أيام',
      two: 'قياسك متأخر يومين',
      one: 'قياسك متأخر يومًا واحدًا',
    );
    return '$_temp0';
  }

  @override
  String scheduleWasDue(String date) {
    return 'كان موعدك $date';
  }

  @override
  String get scheduleLateBody =>
      'سجّل وزنك الآن ليتابع أخصائي التغذية تقدمك بدقة.';

  @override
  String get quickContactTitle => 'هل طرأ ظرف خاص؟';

  @override
  String get quickContactSubtitle =>
      'مناسبة، أو طعام غير متوفر، أو شهية مفاجئة…';

  @override
  String get quickContactBody =>
      'أرسل طلباً سريعاً إلى أخصائي التغذية، وسيردّ عليك بتعديل أو بديل يناسب ظرفك.';

  @override
  String get quickContactButton => 'تواصل سريع مع أخصائي التغذية';

  @override
  String get myRequestsLink => 'طلباتي';

  @override
  String requestsAwaiting(String n) {
    return '$n بانتظار الرد';
  }

  @override
  String get quickRequestTitle => 'تواصل سريع';

  @override
  String get quickRequestQuestion => 'ما الذي حدث؟';

  @override
  String get quickRequestIntro =>
      'اختر سبباً واحداً، وسيردّ أخصائي التغذية بتعديل أو بديل.';

  @override
  String get reasonSpecialOccasion => 'مناسبة خاصة';

  @override
  String get reasonSpecialOccasionHint => 'عرس، جمعة عيلة، عزومة';

  @override
  String get reasonFoodUnavailable => 'الطعام غير متوفر';

  @override
  String get reasonFoodUnavailableHint => 'بدي بديل سريع من الموجود عندي';

  @override
  String get reasonCraving => 'شراهة مفاجئة';

  @override
  String get reasonCravingHint => 'جوع قوي أو رغبة بأكل معين';

  @override
  String get reasonCannotContinue => 'لا أستطيع الالتزام';

  @override
  String get reasonCannotContinueHint => 'الخطة صعبة عليّ هالفترة';

  @override
  String get reasonOther => 'سبب آخر';

  @override
  String get reasonOtherHint => 'اكتب لأخصائي التغذية باختصار';

  @override
  String get reasonUnknown => 'طلب';

  @override
  String get quickRequestOccasionDate => 'موعد المناسبة';

  @override
  String get quickRequestPickDate => 'اختر التاريخ';

  @override
  String get quickRequestNote => 'تفاصيل قصيرة (اختياري)';

  @override
  String get quickRequestNoteHint =>
      'مثلًا: عرس صديقتي، والعشا متأخر وفيه حلويات.';

  @override
  String get quickRequestResponseTime =>
      'يردّ أخصائي التغذية عادة خلال يوم. للحالات الطارئة أو الأعراض المقلقة، راجع الطبيب مباشرة.';

  @override
  String get quickRequestSend => 'إرسال الطلب';

  @override
  String get quickRequestSent => 'وصل طلبك إلى أخصائي التغذية';

  @override
  String get quickRequestLimit =>
      'بلغت حدّ الطلبات اليوم (5). جرّب غداً أو ناقش الأمر في موعدك القادم.';

  @override
  String get quickRequestOffline =>
      'لا يوجد اتصال. لم يُرسل الطلب، جرّب عند عودة الإنترنت.';

  @override
  String get myRequestsTitle => 'طلباتي';

  @override
  String get requestStatusOpen => 'بانتظار الرد';

  @override
  String get requestStatusAnswered => 'تم الرد';

  @override
  String get requestStatusClosed => 'مغلق';

  @override
  String requestSentOn(String date) {
    return 'أُرسل $date';
  }

  @override
  String requestOccasionOn(String date) {
    return 'المناسبة $date';
  }

  @override
  String get requestAwaitingReply => 'بانتظار ردّ أخصائي التغذية';

  @override
  String requestReplyFrom(String date) {
    return 'ردّ أخصائي التغذية • $date';
  }

  @override
  String get requestReplyLabel => 'ردّ أخصائي التغذية';

  @override
  String get myRequestsEmpty => 'ما أرسلت أي طلب بعد';

  @override
  String get myRequestsEmptyBody =>
      'عند حدوث ظرف خاص، يمكنك إرسال طلب سريع من هنا.';

  @override
  String get checkinTitle => 'استبيان قصير';

  @override
  String checkinProgress(String current, String total) {
    return 'سؤال $current من $total';
  }

  @override
  String checkinChooseUpTo(String max) {
    return 'اختر لحد $max إجابات';
  }

  @override
  String get checkinChooseAny => 'اختر كل ما ينطبق عليك';

  @override
  String checkinLimitReached(String max) {
    return 'وصلت للحد ($max)';
  }

  @override
  String get checkinTextHint => 'اكتب لأخصائي التغذية باختصار…';

  @override
  String get checkinSubmit => 'إرسال الاستبيان';

  @override
  String get checkinThanks => 'شكراً! وصلت إجاباتك إلى أخصائي التغذية';

  @override
  String get checkinExpired =>
      'انتهت مدة هذا الاستبيان، وسيصلك التالي في موعده.';

  @override
  String get checkinNone => 'لا يوجد استبيان حالياً';

  @override
  String get checkinNoneBody =>
      'عندما يرسل أخصائي التغذية استبياناً جديداً سيصلك تذكير.';

  @override
  String get foodPrefsTitle => 'أكلاتي';

  @override
  String get foodPrefsNotAllergy => 'ليست حساسية';

  @override
  String get foodPrefsNotAllergyBody =>
      'فقط لتكون خطتك أقرب إلى ذوقك وأسهل عليك';

  @override
  String get foodPrefsSearchHint => 'ابحث عن أكلة…';

  @override
  String get foodPrefsLikes => 'أكلات بحبها';

  @override
  String get foodPrefsDislikes => 'أكلات ما بحبها';

  @override
  String get foodPrefsLike => 'بحبها';

  @override
  String get foodPrefsDislike => 'ما بحبها';

  @override
  String foodPrefsCount(String count, String max) {
    return '$count من $max';
  }

  @override
  String get foodPrefsEmpty => 'ما ضفت شي بعد';

  @override
  String get foodPrefsFromNutritionist => 'من أخصائي التغذية';

  @override
  String foodPrefsRemove(String name) {
    return 'إزالة $name';
  }

  @override
  String get foodPrefsSuggestions => 'اقتراحات سريعة';

  @override
  String get foodPrefsAlreadyAdded => 'هالأكلة موجودة بقوائمك';

  @override
  String foodPrefsListFull(String max) {
    return 'وصلت لحد $max أكلة بهالقائمة';
  }

  @override
  String get projectionTitle => 'متى بتوصل لهدفك؟';

  @override
  String projectionRemainingLoss(String kg) {
    return 'باقي لهدفك $kg كغ';
  }

  @override
  String projectionRemainingGain(String kg) {
    return 'باقي لهدفك $kg كغ زيادة';
  }

  @override
  String get projectionHigh => 'التزام عالي';

  @override
  String get projectionMedium => 'التزام متوسط';

  @override
  String get projectionLow => 'التزام قليل';

  @override
  String get projectionYourLevel => 'التزامك الحالي';

  @override
  String get projectionHard => 'صعب توصل بهالمستوى';

  @override
  String projectionAbout(String date) {
    return 'تقريبًا $date';
  }

  @override
  String get projectionFaster => 'كل ما زاد التزامك، بتوصل أسرع.';

  @override
  String weeksCount(int count, String n) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$n أسبوع',
      many: '$n أسبوعًا',
      few: '$n أسابيع',
      two: 'أسبوعين',
      one: 'أسبوع واحد',
    );
    return '$_temp0';
  }

  @override
  String get todayTitle => 'يومك اليوم';

  @override
  String get reminderActionMeasure => 'سجّل الآن';

  @override
  String get reminderActionStart => 'ابدأ';

  @override
  String get reminderActionAppointments => 'مواعيدي';

  @override
  String get reminderActionPosts => 'النصائح';

  @override
  String get reminderActionLog => 'سجّل';

  @override
  String get postsTitle => 'نصائح أخصائي التغذية';

  @override
  String get postsEmpty => 'لا توجد نصائح من أخصائي التغذية بعد';

  @override
  String get postsNew => 'جديدة';

  @override
  String get postsPinned => 'مثبّتة';

  @override
  String get postFromNutritionist => 'من أخصائي التغذية';

  @override
  String get postUnavailable => 'هذه النصيحة غير متوفرة';

  @override
  String get weightInsightTitle => 'تفسير تغيّر الوزن';

  @override
  String get weightInsightDisclaimer => 'شرح مبني على تسجيلاتك، وليس تشخيصاً.';

  @override
  String weightDown(String kg) {
    return '−$kg كغ';
  }

  @override
  String weightUp(String kg) {
    return '+$kg كغ';
  }

  @override
  String get weightStable => 'ثابت';

  @override
  String get notificationSettingsMorning => 'رسالة الصباح';

  @override
  String get notificationSettingsMorningDesc => 'ملخص يومك وتذكيراته كل صباح';

  @override
  String get notificationSettingsEducation => 'نصائح أخصائي التغذية';

  @override
  String get notificationSettingsEducationDesc =>
      'عند نشر أخصائي التغذية نصيحة جديدة لك';

  @override
  String get reportsTitle => 'تقاريري الطبية';

  @override
  String get reportsUploadNew => 'رفع تقرير جديد';

  @override
  String reportsCount(String count, String max) {
    return '$count من $max تقرير';
  }

  @override
  String reportsLimitReached(String max) {
    return 'وصلت لحد $max تقرير، احذف تقريرًا قديمًا';
  }

  @override
  String get reportsLoadFailed => 'تعذّر تحميل تقاريرك الطبية.';

  @override
  String get reportsConsentTitle => 'قبل ما ترفع تقاريرك';

  @override
  String get reportsConsentOnce => 'مرة واحدة فقط';

  @override
  String get reportsConsentEncrypted => 'تقاريرك بتنحفظ مشفّرة.';

  @override
  String get reportsConsentOnlyNutritionist =>
      'لا يراه أحد غير أخصائي التغذية.';

  @override
  String get reportsConsentDelete => 'يمكنك حذف أي تقرير في أي وقت.';

  @override
  String get reportsConsentNoAi => 'ما بنستعملها بأي ذكاء اصطناعي.';

  @override
  String get reportsConsentReadFull => 'اقرأ النص الكامل ‹';

  @override
  String get reportsConsentAgree => 'موافق، كمّل';

  @override
  String get reportCategoryLab => 'فحص مخبري';

  @override
  String get reportCategoryImaging => 'صورة أشعة';

  @override
  String get reportCategoryPrescription => 'وصفة طبية';

  @override
  String get reportCategoryLetter => 'تقرير طبي';

  @override
  String get reportCategoryOther => 'أخرى';

  @override
  String get reportKindPdf => 'PDF';

  @override
  String get reportKindImage => 'صورة';

  @override
  String fileSizeKb(String size) {
    return '$size ك.ب';
  }

  @override
  String fileSizeMb(String size) {
    return '$size م.ب';
  }

  @override
  String get reportReviewed => 'راجعه أخصائي التغذية';

  @override
  String get reportAwaitingReview => 'بانتظار المراجعة';

  @override
  String get reportNutritionistNote => 'ملاحظة أخصائي التغذية';

  @override
  String get reportDelete => 'حذف';

  @override
  String get reportDeleteTitle => 'حذف التقرير؟';

  @override
  String get reportCannotShow => 'ما قدرنا نعرض هالملف';

  @override
  String get reportUploadTitle => 'رفع تقرير';

  @override
  String get reportCategory => 'نوع التقرير';

  @override
  String get reportTitleLabel => 'العنوان';

  @override
  String get reportTitleHint => 'مثلًا: فحص السكر التراكمي';

  @override
  String get reportTitleRequired => 'اكتب عنوانًا للتقرير';

  @override
  String get reportDateLabel => 'تاريخ التقرير (اختياري)';

  @override
  String get reportFileLabel => 'الملف';

  @override
  String get reportFromCamera => 'صوّر';

  @override
  String get reportFromGallery => 'من الصور';

  @override
  String get reportFromPdf => 'ملف PDF';

  @override
  String get reportFileHint => 'صور (JPG، PNG، WebP) أو PDF، لحد 10 ميغابايت.';

  @override
  String get reportPickFailed => 'ما قدرنا نفتح الملف، جرّب مرة ثانية.';

  @override
  String get reportUpload => 'رفع التقرير';

  @override
  String get reportUploaded => 'رُفع التقرير إلى أخصائي التغذية';

  @override
  String get reportErrorTooLarge =>
      'الملف أكبر من 10 ميغابايت. صوّر بدقة أقل أو اختر ملفًا أصغر.';

  @override
  String get reportErrorType => 'نوع الملف غير مدعوم.';

  @override
  String get reportErrorInvalidImage => 'الصورة تالفة، جرّب مرة ثانية.';

  @override
  String get reportErrorLimit => 'وصلت لحد 30 تقرير، احذف تقريرًا قديمًا.';

  @override
  String get tagEconomical => 'اقتصادي';

  @override
  String get tagNoCook => 'بدون طبخ';

  @override
  String get tagEasyPrep => 'تحضير سهل';

  @override
  String get wellbeingTitle => 'النوم والمزاج';

  @override
  String get wellbeingLastNight => 'الليلة الماضية';

  @override
  String get wellbeingTonight => 'الليلة';

  @override
  String get wellbeingPreviousNight => 'الليلة السابقة';

  @override
  String get wellbeingNextNight => 'الليلة التالية';

  @override
  String get wellbeingHoursQuestion => 'كم ساعة نمت؟';

  @override
  String get wellbeingHoursUnit => 'ساعات';

  @override
  String get wellbeingLessSleep => 'نص ساعة أقل';

  @override
  String get wellbeingMoreSleep => 'نص ساعة أكثر';

  @override
  String get wellbeingQualityQuestion => 'كيف كان نومك؟';

  @override
  String get wellbeingQualityGood => 'جيدة';

  @override
  String get wellbeingQualityOk => 'عادي';

  @override
  String get wellbeingQualityPoor => 'متقطع';

  @override
  String get wellbeingStressQuestion => 'التوتر';

  @override
  String get wellbeingStressLow => 'قليل';

  @override
  String get wellbeingStressMedium => 'متوسط';

  @override
  String get wellbeingStressHigh => 'عالي';

  @override
  String get wellbeingMoodQuestion => 'مزاجك';

  @override
  String get wellbeingMoodGood => 'جيد';

  @override
  String get wellbeingMoodOk => 'عادي';

  @override
  String get wellbeingMoodLow => 'منخفض';

  @override
  String get wellbeingNote => 'ملاحظة (اختياري)';

  @override
  String get wellbeingNoteHint => 'مثلًا: ضغط شغل هالأسبوع.';

  @override
  String get wellbeingDeleteNight => 'حذف تسجيل هذه الليلة';

  @override
  String get wellbeingDeleteTitle => 'حذف تسجيل هذه الليلة؟';

  @override
  String get wellbeingErrorFuture => 'لا يمكن التسجيل ليوم لم يأتِ بعد.';

  @override
  String get wellbeingErrorOld => 'يمكن تعديل آخر 7 أيام فقط.';

  @override
  String get wellbeingLast7 => 'آخر 7 ليالي';

  @override
  String get wellbeingHoursOfSleep => 'ساعات النوم';

  @override
  String wellbeingShortNight(String hours) {
    return 'ليلة أقل من $hours ساعات';
  }

  @override
  String get wellbeingWeekdayLetters => 'ن ث ر خ ج س ح';

  @override
  String get profilePostsSubtitle => 'نصائح كتبها أخصائي التغذية لك';

  @override
  String get profileRequestsSubtitle => 'طلبات التواصل السريع وردودها';

  @override
  String get profileFoodPrefsSubtitle => 'أكلات بتحبها وما بتحبها';

  @override
  String get profileWellbeingSubtitle => 'سجّل نومك وتوترك ومزاجك';

  @override
  String get profileAppointmentsSubtitle => 'مواعيدك مع أخصائي التغذية';

  @override
  String get profileAchievementsSubtitle => 'إنجازاتك من تسجيلاتك الفعلية';

  @override
  String get profileHealthSyncSubtitle => 'ربط التطبيق بتطبيق الصحة';

  @override
  String healthRecordFileCode(String code) {
    return 'كود الملف: $code';
  }

  @override
  String get achvSectionTitle => 'كل الإنجازات';

  @override
  String achvEarnedOf(String earned, String total) {
    return '$earned من $total إنجاز';
  }

  @override
  String get achvHeroStart =>
      'سجّل وجبتك الأولى وقياسك الأول، وستبدأ إنجازاتك بالظهور هنا.';

  @override
  String get achvHeroKeepGoing =>
      'كمّل على نفس الطريق، كل تسجيل بيقرّبك من الإنجاز الجاي.';

  @override
  String get achvHeroAll => 'حققت كل الإنجازات، يعطيك العافية!';

  @override
  String get achvStreakTitle => 'سلسلة تسجيلك الحالية';

  @override
  String get achvStreakNone => 'سجّل وجبة اليوم لتبدأ سلسلتك';

  @override
  String achvBestStreak(String n) {
    return 'أطول سلسلة: $n';
  }

  @override
  String achvDaysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يوم',
      many: 'يومًا',
      few: 'أيام',
      two: 'يومين',
      one: 'يوم',
      zero: 'يوم',
    );
    return '$_temp0';
  }

  @override
  String get achvEarned => 'تم';

  @override
  String get achvFirstMeal => 'أول وجبة';

  @override
  String get achvFirstMealBody => 'سجّلت أول وجبة';

  @override
  String get achvStreak3 => '3 أيام ورا بعض';

  @override
  String get achvStreak3Body => 'سجّلت وجباتك 3 أيام متتالية';

  @override
  String get achvStreak7 => 'أسبوع كامل';

  @override
  String get achvStreak7Body => 'سجّلت وجباتك 7 أيام متتالية';

  @override
  String get achvDays30 => '30 يوم تسجيل';

  @override
  String get achvDays30Body => 'سجّلت وجباتك بـ30 يومًا مختلفًا';

  @override
  String get achvFirstReading => 'أول قياس';

  @override
  String get achvFirstReadingBody => 'سجّلت وزنك لأول مرة';

  @override
  String get achvFiveReadings => 'ملتزم بالقياس';

  @override
  String get achvFiveReadingsBody => 'سجّلت 5 قياسات';

  @override
  String get achvFirstKilosLoss => 'أول 2 كغ';

  @override
  String get achvFirstKilosGain => 'أول 2 كغ زيادة';

  @override
  String get achvFirstKilosBody => 'تغيّر وزنك 2 كغ باتجاه هدفك';

  @override
  String get achvHalfway => 'نص الطريق';

  @override
  String get achvHalfwayBody => 'قطعت نص المسافة لوزنك المستهدف';

  @override
  String get achvGoalReached => 'وصلت لهدفك';

  @override
  String get achvGoalReachedBody => 'وصلت لوزنك المستهدف';

  @override
  String get achvFootnote =>
      'محسوبة من وجباتك المسجّلة على هالجهاز ومن قياساتك وهدفك.';

  @override
  String get callsNextTitle => 'موعدك القادم';

  @override
  String get callsLaterTitle => 'المواعيد الجاية';

  @override
  String get shoppingListTitle => 'قائمة التسوق';

  @override
  String get shoppingDayTab => 'هذا اليوم';

  @override
  String get shoppingWeekTab => 'الأسبوع كاملًا';

  @override
  String get shoppingWeekNote =>
      'الوجبات اليومية لسبعة أيام، ووجبات الأيام المحددة مرة واحدة.';

  @override
  String get shoppingNote => 'الكميات من خطتك، والبدائل مذكورة تحت كل صنف.';

  @override
  String get shoppingEmpty => 'لا يوجد ما تشتريه في هذه الفترة.';

  @override
  String shoppingAlternatives(String names) {
    return 'أو: $names';
  }

  @override
  String get shoppingSectionProduce => 'خضار وفواكه';

  @override
  String get shoppingSectionMeat => 'لحوم ودواجن وأسماك';

  @override
  String get shoppingSectionDairy => 'ألبان وبيض';

  @override
  String get shoppingSectionGrains => 'حبوب ونشويات';

  @override
  String get shoppingSectionLegumes => 'بقوليات ومكسرات';

  @override
  String get shoppingSectionOils => 'زيوت وتوابل';

  @override
  String get shoppingSectionOther => 'أخرى';

  @override
  String get callsBookTitle => 'حجز موعد';

  @override
  String get callsChangeTitle => 'تغيير الموعد';

  @override
  String get callsCancelAction => 'إلغاء الموعد';

  @override
  String get callsJoinCall => 'الانضمام إلى المكالمة';

  @override
  String get callsTypeSection => 'نوع الموعد';

  @override
  String callsMinutes(String minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get callsTimeSection => 'اختر الوقت';

  @override
  String get callsTimesLocal => 'الأوقات بتوقيت جهازك.';

  @override
  String get callsNoSlots => 'لا توجد أوقات متاحة حاليًا.';

  @override
  String get callsNoSlotsBody => 'تواصل مع أخصائيك لتحديد موعد.';

  @override
  String get callsChannelSection => 'طريقة التواصل';

  @override
  String get callsTopicsSection => 'ما الذي تودّ مناقشته؟ (اختياري)';

  @override
  String get callsTopicWeight => 'الوزن';

  @override
  String get callsTopicMeals => 'الوجبات';

  @override
  String get callsTopicPlanChange => 'تعديل الخطة';

  @override
  String get callsTopicResults => 'النتائج';

  @override
  String get callsTopicMedications => 'الأدوية';

  @override
  String get callsTopicOther => 'أخرى';

  @override
  String get callsNoteSection => 'ملاحظة لأخصائيك (اختياري)';

  @override
  String get callsConfirmBooking => 'تأكيد الحجز';

  @override
  String get callsConfirmChange => 'تأكيد الموعد الجديد';

  @override
  String get callsCurrentAppointment => 'الموعد الحالي';

  @override
  String get callsBooked => 'تم حجز موعدك';

  @override
  String get callsRescheduled => 'تم تغيير موعدك';

  @override
  String get callsCancelled => 'تم إلغاء موعدك';

  @override
  String get callsCancelConfirmTitle => 'إلغاء هذا الموعد؟';

  @override
  String get callsCancelConfirmBody =>
      'سيُلغى الموعد، ويمكنك حجز موعد جديد لاحقًا.';

  @override
  String get callsKeep => 'إبقاء الموعد';

  @override
  String get callsErrorExists =>
      'لديك موعد قادم بالفعل. يمكنك تعديله أو إلغاؤه.';

  @override
  String get callsErrorSlotTaken => 'هذا الوقت لم يعد متاحًا، اختر وقتًا آخر.';

  @override
  String get callsErrorVideo => 'مكالمات الفيديو غير متاحة مع أخصائيك حاليًا.';

  @override
  String get callsErrorClosed => 'هذا الموعد لم يعد قائمًا.';

  @override
  String callsErrorLocked(String hours) {
    return 'لا يمكن تعديل الموعد أو إلغاؤه قبل أقل من $hours ساعة. تواصل مع أخصائيك.';
  }

  @override
  String get callsErrorGeneric => 'تعذّر إتمام الطلب. حاول مرة أخرى.';

  @override
  String get healthSyncHeroApple => 'ربط التطبيق مع Apple Health';

  @override
  String get healthSyncHeroAndroid => 'ربط التطبيق مع Health Connect';

  @override
  String get healthSyncHeroBody =>
      'تصل خطواتك ونومك ووزنك تلقائياً، فتسجّل أقل ويرى أخصائي التغذية صورة أوضح.';

  @override
  String get healthSyncComingSoon => 'قريبًا';

  @override
  String get healthSyncWhatTitle => 'ما الذي يُزامَن';

  @override
  String get healthSyncSteps => 'الخطوات اليومية';

  @override
  String get healthSyncStepsBody => 'لترى نشاطك بجانب خطة النشاط البدني';

  @override
  String get healthSyncSleep => 'ساعات النوم';

  @override
  String get healthSyncSleepBody => 'بتتعبّى لحالها بسجل النوم والمزاج';

  @override
  String get healthSyncWeight => 'الوزن من الميزان الذكي';

  @override
  String get healthSyncWeightBody => 'يوصل مع قياساتك بدل ما تكتبه';

  @override
  String get healthSyncPrivacyTitle => 'خصوصيتك أولًا';

  @override
  String get healthSyncPrivacyRead =>
      'التطبيق بيقرأ بس، وما بيكتب شي بتطبيق الصحة.';

  @override
  String get healthSyncPrivacyChoice => 'أنت من يختار ما يصل، بنداً بنداً.';

  @override
  String get healthSyncPrivacyStop =>
      'يمكنك إيقاف الربط في أي وقت من إعدادات جهازك.';

  @override
  String get healthSyncMeanwhile =>
      'لحد ما يجهز الربط، سجّل نومك وقياساتك من التطبيق مباشرة.';

  @override
  String get conditionDiabetesType1 => 'سكري النوع الأول';

  @override
  String get conditionDiabetesType2 => 'سكري النوع الثاني';

  @override
  String get conditionGestationalDiabetes => 'سكري الحمل';

  @override
  String get conditionInsulinResistance => 'مقاومة الإنسولين';

  @override
  String get conditionPrediabetes => 'ما قبل السكري';

  @override
  String get conditionHypertension => 'ارتفاع ضغط الدم';

  @override
  String get conditionKidneyDisease => 'أمراض الكلى';

  @override
  String get conditionLiverDisease => 'أمراض الكبد';

  @override
  String get conditionCancer => 'السرطان';

  @override
  String get conditionCeliac => 'الداء البطني (السيلياك)';

  @override
  String get conditionFluidRetention => 'احتباس السوائل';

  @override
  String get conditionOther => 'أخرى';

  @override
  String get onboardingHealthNoConditions => 'لا توجد حالات صحية مشخّصة';

  @override
  String get onboardingHealthNoAllergies => 'لا توجد حساسية غذائية معروفة';

  @override
  String get onboardingHealthOtherConditionHint =>
      'اسم الحالة، مثل: قصور الغدة الدرقية';

  @override
  String onboardingHealthNoteTooLong(int count) {
    return 'النص أطول من المسموح بمقدار $count حرفاً. اختصر الملاحظات أو اسم الحالة لإرسالها كاملة إلى الأخصائي.';
  }

  @override
  String get commonListSeparator => '، ';

  @override
  String get loginPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get stateOfflineTitle => 'لا يوجد اتصال';

  @override
  String get stateErrorTitle => 'تعذّر تحميل الصفحة';

  @override
  String get mealAte => 'أكلتها';

  @override
  String get mealDetailsAndSwaps => 'التفاصيل والبدائل';

  @override
  String mealLoggedSnack(String meal) {
    return 'تم تسجيل $meal';
  }

  @override
  String get mealUndo => 'تراجع';

  @override
  String get mealUndoFailed => 'تعذّر التراجع. يمكنك حذف الوجبة من سجل اليوم.';

  @override
  String get logMealTabPlan => 'من خطتي';

  @override
  String get logMealTabOffPlan => 'خارج الخطة';

  @override
  String get logMealAllLogged => 'تم تسجيل كل وجبات اليوم.';

  @override
  String get logMealOffPlanHint =>
      'ابحث عن الطعام الذي تناولته وحدّد كميته بالغرام، وتُضاف سعراته إلى سجل اليوم.';

  @override
  String get logMealSearchFood => 'البحث عن طعام';
}
