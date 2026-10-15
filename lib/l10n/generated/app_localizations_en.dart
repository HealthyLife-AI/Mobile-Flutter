// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HealthyLife AI';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDone => 'Done';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonEmptyTitle => 'Nothing to show yet';

  @override
  String get commonEmptyBody =>
      'Information will appear here as soon as it\'s available.';

  @override
  String get commonErrorTitle => 'Something went wrong';

  @override
  String get commonErrorBody => 'We couldn\'t load the data. Please try again.';

  @override
  String get commonOfflineTitle => 'No internet connection';

  @override
  String get commonOfflineBody => 'Check your network and try again.';

  @override
  String get commonSuccess => 'Done successfully';

  @override
  String get failureNetwork =>
      'Could not reach the server. Check your connection and try again.';

  @override
  String get failureTimeout => 'The request took too long. Please try again.';

  @override
  String get failureServer =>
      'The service is unavailable right now. Try again later.';

  @override
  String get failureUnauthorized =>
      'Your session has expired. Please sign in again.';

  @override
  String get failureNotFound => 'The requested item was not found.';

  @override
  String get failureValidation => 'Please check your input and try again.';

  @override
  String get failureCache => 'Could not read locally saved data.';

  @override
  String get failureUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidEmail => 'Enter a valid email address';

  @override
  String validationTooShort(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String validationTooLong(int max) {
    return 'Must not exceed $max characters';
  }

  @override
  String get validationMissingUppercase => 'Add at least one uppercase letter';

  @override
  String get validationMissingDigit => 'Add at least one digit';

  @override
  String get validationMissingSpecial => 'Add at least one special character';

  @override
  String get validationMismatch => 'The two values don\'t match';

  @override
  String get validationInvalidNumber => 'Numbers only';

  @override
  String validationOutOfRange(num min, num max) {
    return 'Value must be between $min and $max';
  }

  @override
  String get logoutConfirmTitle => 'Log out of your account';

  @override
  String get logoutConfirmMessage =>
      'Your session on this device will end securely once your latest measurements and logs have synced.';

  @override
  String get commonLogout => 'Log out';

  @override
  String get navHome => 'Home';

  @override
  String get navPlan => 'Plan';

  @override
  String get navProgress => 'Progress';

  @override
  String get navAccount => 'Account';

  @override
  String get navLogMealTooltip => 'Log a new meal';

  @override
  String get notificationCategoryAll => 'All';

  @override
  String get notificationCategoryMeals => 'Meals';

  @override
  String get notificationCategoryMeasurements => 'Measurements';

  @override
  String get notificationCategoryPlanUpdates => 'Plan updates';

  @override
  String get notificationCategoryNutritionist => 'Nutritionist';

  @override
  String get notificationCategoryOther => 'Other';

  @override
  String get aboutTitle => 'About the app';

  @override
  String get aboutTransparencyTitle => 'Transparency';

  @override
  String get aboutCertifiedRegulations => 'Certified regulations';

  @override
  String get aboutSessionAccountTitle => 'Session & account';

  @override
  String get aboutCopyright =>
      'HealthyLife Clinical Suite © 2026 • All rights reserved';

  @override
  String get aboutBrandName => 'HealthyLife';

  @override
  String get aboutTagline =>
      'Patient follow-up and clinical nutrition platform';

  @override
  String get aboutVersion => 'Version 1.0.0 (Build 240)';

  @override
  String get aboutDescription =>
      'A certified app designed to support you, in direct collaboration with your certified specialist, in reaching lasting health goals.';

  @override
  String get aboutPrivacyPolicyTitle => 'Privacy policy & health data security';

  @override
  String get aboutPrivacyPolicySubtitle =>
      'High-grade clinical encryption for your nutrition profile';

  @override
  String get aboutMedicalTermsTitle => 'Medical terms & conditions';

  @override
  String get aboutMedicalTermsSubtitle =>
      'Guidelines for following health care plans';

  @override
  String get aboutLicensesTitle => 'Medical authority licenses & accreditation';

  @override
  String get aboutLicensesSubtitle =>
      'Documented medical compliance record #A-8841';

  @override
  String get aboutSupportTitle => 'Technical support & app help';

  @override
  String get aboutSupportSubtitle => 'Ongoing help with technical questions';

  @override
  String get aboutStandardHealthProtection => 'Standard health protection';

  @override
  String get aboutEncryptionNote =>
      'Your data is encrypted and protected under certified health-privacy standards for secure syncing with your clinical record.';

  @override
  String get aboutLogoutNote =>
      'Your session will end securely, and all your logs and measurements stay in your medical records with no data loss.';

  @override
  String get achievementsFullWeek => 'A full week of commitment';

  @override
  String get achievementsSevenDayStreak => '7-day logging streak';

  @override
  String get achievementsFirstMeal => 'First meal logged';

  @override
  String get achievementsHydration => 'Drinking water regularly';

  @override
  String get achievementsThirtyDays => '30 days of commitment';

  @override
  String get achievementsFirstWeightGoal => 'First weight goal';

  @override
  String get achievementsTitle => 'Your achievements';

  @override
  String get achievementsEncouragement =>
      'Keep going — every small step counts';

  @override
  String get activationWelcome => 'Welcome to HealthyLife';

  @override
  String get activationSubtitle =>
      'Activate your instant access to the clinical care program';

  @override
  String get activationCertified => 'Certified';

  @override
  String get activationSpecialistRole =>
      'Clinical nutrition & metabolic management specialist';

  @override
  String get activationInvitedBy =>
      'Your specialist has invited you to link your health record and start your personalized therapeutic meal plan right away.';

  @override
  String get activationPrefilledNote =>
      'The clinic has already entered your basic details';

  @override
  String get activationNewPassword => 'New password';

  @override
  String get activationConfirmPassword => 'Confirm password';

  @override
  String get passwordRuleMinLength => '8 characters or more';

  @override
  String get passwordRuleUppercase => 'At least one uppercase letter (A-Z)';

  @override
  String get passwordRuleDigit => 'At least one number (0-9)';

  @override
  String get activationCta => 'Activate account & start the plan';

  @override
  String get activationEncryptedNote =>
      'Your health data is encrypted and protected under medical compliance regulations';

  @override
  String get activationLinkValid => 'Link valid and active';

  @override
  String get activationLinkExpired => 'Link expired / already used';

  @override
  String get barcodeTitle => 'Scan the product barcode';

  @override
  String get barcodeFound => 'Product found ✓';

  @override
  String get barcodeHint => 'Point the camera at the barcode — tap to simulate';

  @override
  String beetaiWelcome(String known, String name) {
    String _temp0 = intl.Intl.selectLogic(
      known,
      {
        'yes':
            'Hi $name! I\'m BeetAI. Ask me anything about your meal plan, or log a meal quickly 🌿',
        'other':
            'Hi! I\'m BeetAI. Ask me anything about your meal plan, or log a meal quickly 🌿',
      },
    );
    return '$_temp0';
  }

  @override
  String get beetaiLoggedReply =>
      'That\'s been added to your log. Would you like to add any other details?';

  @override
  String get beetaiSubtitle => 'Your smart assistant';

  @override
  String get beetaiVoiceInput => 'Voice input';

  @override
  String get beetaiInputHint => 'Ask BeetAI or log a meal…';

  @override
  String get beetaiVoiceMessage => 'Voice message';

  @override
  String get dailyLogMealDeleted => 'Meal removed from today\'s log';

  @override
  String get commonUndo => 'Undo';

  @override
  String get dailyLogTitle => 'Today\'s log';

  @override
  String get commonNotifications => 'Notifications';

  @override
  String get dailyLogWeeklyPlanTooltip => 'View the weekly plan';

  @override
  String get dailyLogActiveDay => 'Active day';

  @override
  String get demoDateSunday21Sep2025 => 'Sunday, 21 September 2025';

  @override
  String get dailyLogLoggedMeals => 'Logged meals';

  @override
  String get dailyLogTotalEnergy => 'Total energy consumed';

  @override
  String commonKcalValue(Object value) {
    return '$value kcal';
  }

  @override
  String dailyLogOverGoal(Object value) {
    return '$value kcal over your goal';
  }

  @override
  String get dailyLogBalancedEnergy => 'Balanced daily energy';

  @override
  String dailyLogPercentOfRecommended(Object percent) {
    return '$percent% of recommended';
  }

  @override
  String get dailyLogOverGoalReassurance =>
      'That\'s okay — the numbers are a calm guide, not a verdict, and tomorrow is a new day.';

  @override
  String get dailyLogVariedChoices =>
      'Your choices today are varied and nourishing. Remember, the numbers are a calm guide to support your activity and health.';

  @override
  String get dailyLogTimeline => 'Timeline';

  @override
  String get dailyLogPreviewEmpty => 'Preview empty log';

  @override
  String get dailyLogOffPlanFree => 'Off-plan • free entry';

  @override
  String get dailyLogFromPlan => 'From the meal plan';

  @override
  String commonGramsValue(Object value) {
    return '$value g';
  }

  @override
  String get dailyLogDeleteMeal => 'Delete meal';

  @override
  String get dailyLogDietitianReminder => 'Dietitian\'s reminder';

  @override
  String get dailyLogFlexibilityNote =>
      'Flexibility is a core part of lasting success. Logging honestly every day is the most important step in caring for yourself.';

  @override
  String get dailyLogNoMealsYet => 'No meals logged yet';

  @override
  String get errorStateTitle => 'Something went wrong';

  @override
  String get errorStateQuickCheck => 'Quick check in progress';

  @override
  String get errorStateServerStatus => 'HealthyLife server status';

  @override
  String get errorStateUnexpected => 'An unexpected error occurred';

  @override
  String get errorStateMessage =>
      'Sorry, we couldn\'t sync this page right now. Take a calm breath and please try again.';

  @override
  String get errorStateDataSafeTitle => 'Your health data is completely safe';

  @override
  String get errorStateDataSafeBody =>
      'Your meal logs, calorie tracking and vital history are unaffected and safely saved in the cloud.';

  @override
  String get errorStateTipsTitle => 'Quick troubleshooting tips';

  @override
  String get errorStateTipsBody =>
      'Please check your internet connection, or try again in a few seconds once the system responds.';

  @override
  String get errorStateRetryNow => 'Retry now';

  @override
  String get commonBackToHome => 'Back to home';

  @override
  String get measurementGuideTitle => 'Measurement guide';

  @override
  String get firstMeasurementHeadline =>
      'Log your next measurement so we can draw your progress line';

  @override
  String get firstMeasurementExplanation =>
      'A progress curve needs at least two measurements to show the real trend accurately and objectively. Your next entry will activate the chart right away.';

  @override
  String get firstMeasurementLogNew => 'Log a new measurement';

  @override
  String get firstMeasurementBackToPlan => 'Back to my daily plan';

  @override
  String get firstMeasurementBaseline => 'Confirmed starting point';

  @override
  String get firstMeasurementInitial => 'Initial recorded measurement';

  @override
  String commonKgValue(Object value) {
    return '$value kg';
  }

  @override
  String get demoDateFriday19Sep2025 => 'Friday, 19 September 2025';

  @override
  String get firstMeasurementBaselineSaved =>
      'Your starting point has been saved to your health record.';

  @override
  String get firstMeasurementJourneyNote =>
      'One measurement sets your starting point; the next one starts mapping your journey with your specialist, step by step.';

  @override
  String get firstMeasurementSuggestedTime => 'Suggested measuring time';

  @override
  String get firstMeasurementMorningTip =>
      'In the morning right after waking up, for a stable reading';

  @override
  String get firstMeasurementIllustratedGuide =>
      'Illustrated measurement guide 📐';

  @override
  String get firstMeasurementAwaitingSecond => 'Awaiting 2nd reading';

  @override
  String get measurementPromptFirstHeadline =>
      'Log your first measurement to set your starting point';

  @override
  String get measurementPromptFirstBody =>
      'Your first measurement is your starting point. After that, one a week is enough to draw your progress chart.';

  @override
  String get measurementPromptAwaitingFirst =>
      'Waiting for your first measurement';

  @override
  String get measurementPromptWeeklyBadge => 'Weekly check-in';

  @override
  String get measurementPromptLatest => 'Your latest measurement';

  @override
  String get measurementPromptWeeklyNote =>
      'A week has passed since this measurement. It\'s time for the next one.';

  @override
  String get measurementPromptWeeklyHeadline =>
      'It\'s time for your weekly measurement';

  @override
  String get measurementPromptWeeklyBody =>
      'One measurement a week keeps your progress chart accurate and up to date.';

  @override
  String get measurementPromptAwaitingNew => 'Waiting for your new measurement';

  @override
  String get measurementPromptViewProgress => 'View my progress';

  @override
  String get followUpSuccessfully => 'Successfully';

  @override
  String get followUpStatus => 'Follow-up status';

  @override
  String get followUpTwelveWeeks => '12 weeks';

  @override
  String get followUpMeasurementsLogged => 'Measurements logged';

  @override
  String get followUpMealAdherence => 'Meal adherence';

  @override
  String get followUpEndedTitle => 'Follow-up ended';

  @override
  String get followUpPlanCompleted => 'Clinical follow-up plan completed';

  @override
  String get followUpPeriodEnded => 'Your current follow-up period has ended';

  @override
  String get followUpEndedMessage =>
      'We hope you enjoyed your health plan and reached your goals! Your current follow-up period with your specialist has ended. To renew, continue your treatment journey or get a new plan, you can reach out directly and easily.';

  @override
  String get followUpSupervisor => 'Your supervisor';

  @override
  String get followUpSupervisingSpecialist =>
      'The clinical nutrition specialist supervising you';

  @override
  String get followUpRecordsSafe =>
      'Your past logs and measurements are safely kept in your health record, and the plan and follow-up can resume as soon as you renew.';

  @override
  String get followUpContactWhatsApp => 'Contact your specialist on WhatsApp';

  @override
  String get followUpViewFinalReport =>
      'View the final follow-up report summary';

  @override
  String get followUpTerms =>
      'Terms of service & privacy policy for medical records';

  @override
  String get foodSearchFilterFruitVeg => 'Fruits & vegetables';

  @override
  String get foodSearchFilterCarbsGrains => 'Starches & grains';

  @override
  String get foodSearchFilterProteins => 'Proteins';

  @override
  String get foodSearchAteOffPlan => 'I ate off-plan';

  @override
  String get foodSearchNoWorries => 'Don\'t worry, we\'re here';

  @override
  String get foodSearchSafeFollowUp => 'Safe follow-up';

  @override
  String get foodSearchHonestLogging =>
      'Logging everything you eat honestly helps your specialist follow up accurately and adjust your plan smoothly, without deprivation.';

  @override
  String get foodSearchHint => 'Search by Arabic or English name';

  @override
  String get foodSearchClear => 'Clear search';

  @override
  String get foodSearchScanBarcode => 'Scan barcode';

  @override
  String get foodSearchSuggested => 'Suggested foods';

  @override
  String foodSearchPer100g(Object amount) {
    return 'per $amount g';
  }

  @override
  String get foodSearchEmptyCategory => 'No foods in this category';

  @override
  String foodSearchNoResults(Object query) {
    return 'No results matching \"$query\"';
  }

  @override
  String get foodSearchTryAnother =>
      'Try another word, or request the item to be added below';

  @override
  String get foodSearchNotFound => 'Can\'t find what you\'re looking for?';

  @override
  String get foodAllergyCheckUnavailable =>
      'Allergy warnings are off right now: your health profile could not be read.';

  @override
  String foodSearchSpecialistWaiting(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'unknown': 'Your nutritionist is here for you',
        'other': 'Your nutritionist, $name, is here for you',
      },
    );
    return '$_temp0';
  }

  @override
  String get foodSearchSendItemNote =>
      'You can send the item\'s name or photo to your specialist so it\'s added to your database right away, or estimate its main ingredients without losing track of your goals.';

  @override
  String get foodSearchRequestViaWhatsApp => 'Request a new item via WhatsApp';

  @override
  String get foodSearchManualEstimate => 'Estimate calories manually (quick)';

  @override
  String get foodSearchManualEstimateName => 'Manual estimate';

  @override
  String get foodSearchRequestNewItem => 'Request a new item';

  @override
  String get foodSearchWhatsAppSheetBody =>
      'Send the item\'s name or photo to your specialist on WhatsApp, and it will be added to your database as soon as possible.';

  @override
  String get commonOpenWhatsApp => 'Open WhatsApp';

  @override
  String get consentClauseStorageTitle => 'How is your health data stored?';

  @override
  String get consentClauseStorageBody =>
      'Full encryption to the highest clinical health-privacy standards (HIPAA standards). Records are stored on isolated medical servers that no third party or advertising company can access under any circumstances.';

  @override
  String get consentClauseAccessTitle => 'Who can see it?';

  @override
  String get consentClauseAccessBody =>
      'Only the certified clinical nutrition specialist assigned to your account, through an encrypted clinical review system. Your data is not shared with anyone else and is never used for marketing.';

  @override
  String get consentClauseRevokeTitle => 'Your full right to withdraw consent';

  @override
  String get consentClauseRevokeBody =>
      'You can withdraw your consent at any time from Account → Privacy. This automatically pauses meal plan personalization until you renew your consent, without affecting your saved records.';

  @override
  String get consentExitTitle => 'Leave your health profile setup?';

  @override
  String get consentExitMessage =>
      'You won\'t be able to continue your treatment journey or access your meal plan until you agree to the health privacy terms.';

  @override
  String get consentExitConfirm => 'Leave now';

  @override
  String get consentExitCancel => 'Continue consent';

  @override
  String get consentClausesHeader => 'Privacy terms & data custody';

  @override
  String consentClausesCount(Object count) {
    return '$count key terms';
  }

  @override
  String get consentReadFullDocument =>
      'Read the full clinical privacy document';

  @override
  String get consentVerified => 'Verified';

  @override
  String get consentCta => 'Continue setting up my health plan';

  @override
  String get consentPleaseAgree =>
      'Please agree to the clinical terms to continue';

  @override
  String get consentCharterTitle => 'Nutrition privacy charter';

  @override
  String get consentConfidentialVerified => 'Confidential & verified';

  @override
  String get consentDataUseNote =>
      'Your data (meal log, measurements and health status) reaches only your specialist and is used to build your meal plan and follow your clinical progress safely.';

  @override
  String get consentEncryptionShort =>
      'Encrypted with 256-bit encryption and compliant with clinical health standards (HIPAA).';

  @override
  String get consentTitle => 'Consent to health data use';

  @override
  String get consentProtectionSystem => 'Smart clinical protection system';

  @override
  String get consentBeforeWeStart => 'Before we start your health journey';

  @override
  String get consentCommitment =>
      'We are committed to protecting the privacy of your health and clinical data with the utmost transparency and security.';

  @override
  String get consentAesNote =>
      'Your medical data is encrypted with AES-256 from the moment it is entered';

  @override
  String get consentCheckbox =>
      'I have read and agree to the data-sharing terms of the health privacy policy.';

  @override
  String get consentRevocable =>
      'You can change or withdraw your consent instantly at any time.';

  @override
  String get healthRecordTitle => 'Medical record';

  @override
  String get healthRecordAllergies => 'Allergies & restrictions';

  @override
  String get healthRecordBadges => 'Badges & achievements log';

  @override
  String get healthRecordBadgesUnlocked => '3 badges unlocked';

  @override
  String get healthRecordBadgeFirstGoal => 'First goal';

  @override
  String get healthRecordBadgeFirstGoalDesc =>
      'First weight measurement logged';

  @override
  String get healthRecordBadgeIronCommitment => 'Iron commitment';

  @override
  String get healthRecordBadgeIronCommitmentDesc =>
      '7 consecutive days of logging';

  @override
  String get healthRecordBadgeWaterFriend => 'Water friend';

  @override
  String get healthRecordBadgeWaterFriendDesc =>
      'Drank 2.5 L for 5 days in a row';

  @override
  String get healthRecordBadgeLose5kg => 'Lose 5 kg';

  @override
  String get healthRecordBadgeLose5kgDesc => '1.2 kg left to unlock';

  @override
  String get healthRecordShareSummary =>
      'Share summary & achievements with your specialist';

  @override
  String get healthRecordActiveNow => 'Active now';

  @override
  String get healthRecordAgeFileCode => '26 years • File code:';

  @override
  String get healthRecordLevel => 'Level 3: Commitment champion';

  @override
  String get healthRecordExcellentWeek => 'Excellent performance this week';

  @override
  String healthRecordPoints(Object points) {
    return '$points / 1000 pts';
  }

  @override
  String get healthRecordPointsToNext => '250 points left to reach level four';

  @override
  String healthRecordPercentComplete(Object percent) {
    return '$percent% complete';
  }

  @override
  String get healthRecordCurrentGoal => 'Current strategic health goal';

  @override
  String get healthRecordMedications =>
      'Approved daily medications & supplements';

  @override
  String get healthRecordActive => 'Active';

  @override
  String get commonViewDetails => 'View details';

  @override
  String get offlineWriteDropped =>
      'The server did not accept a reading saved while you were offline, so it was not kept.';

  @override
  String get healthRecordCertified => 'Certified medical record';

  @override
  String get healthRecordDiagnosesNote =>
      'Diagnoses and precautions for precisely tailoring your plan';

  @override
  String get healthRecordRequestChange =>
      'Request a change or add a report to the medical record';

  @override
  String healthRecordStreakDays(Object days) {
    return '$days consecutive days of full commitment!';
  }

  @override
  String get healthRecordStreakNote =>
      'Log your meals and daily physical activity accurately — keep the spark of motivation alive!';

  @override
  String get healthRecordDone => 'Achieved';

  @override
  String get healthSyncTitle => 'Connect a health app';

  @override
  String get healthSyncConnected => 'Connected successfully';

  @override
  String get healthSyncConnectPrompt => 'Connect your health app';

  @override
  String get healthSyncBody =>
      'Connecting Apple Health or Google Fit lets your specialist follow your activity and heart rate automatically without manual entry, and improves the accuracy of your meal plan.';

  @override
  String get healthSyncConnectNow => 'Connect now';

  @override
  String get healthSyncBackToProgress => 'Back to progress';

  @override
  String get homeMealBreakfast => 'Breakfast';

  @override
  String get homeBreakfastTime => '08:00 AM';

  @override
  String get homeBreakfastAlternative =>
      'Suggested alternative: 100g cottage cheese';

  @override
  String get homeItemTwoBoiledEggs => '2 boiled eggs';

  @override
  String get homeItemOatBread => '1 loaf of oat bread';

  @override
  String get homeItemCucumberTomatoes => 'Cucumber and cherry tomatoes';

  @override
  String get homeItemFresh => 'Fresh';

  @override
  String get homeMealLunch => 'Lunch';

  @override
  String get homeLunchTime => '02:30 PM';

  @override
  String get homeItemGrilledChicken => 'Grilled chicken breast';

  @override
  String get homeItemBrownRice => 'Steamed brown rice';

  @override
  String get homeItemGreenSalad => 'Green salad with olive oil dressing';

  @override
  String get homeItemLargePlate => 'Large plate';

  @override
  String get homeDinnerTitle => 'Dinner - 08:00 PM';

  @override
  String get homeDinnerSubtitle => 'Light and clean - about 320 calories';

  @override
  String get homeItemGreekYogurt => 'Greek yogurt';

  @override
  String get homeItemSauteedVeg => 'Sautéed vegetables';

  @override
  String get homeItemBrownToast => 'Brown toast';

  @override
  String get homeEveningSnack => 'Evening snack';

  @override
  String get homeEveningSnackSubtitle => 'Seasonal fruit (120g)';

  @override
  String homeSyncedItems(Object count) {
    return '$count items synced successfully';
  }

  @override
  String get homeOnlineNow => 'You\'re online now';

  @override
  String get homeTapToSync => 'Tap to sync and reconnect';

  @override
  String get homeOnlineTapPreview => 'Online — tap to preview offline mode';

  @override
  String homeGreeting(String known, String name) {
    String _temp0 = intl.Intl.selectLogic(
      known,
      {
        'yes': 'Hello $name 👋',
        'other': 'Hello 👋',
      },
    );
    return '$_temp0';
  }

  @override
  String get homeAdherenceToday => 'Today\'s adherence';

  @override
  String get homeDailyMealPath => 'Daily meal path';

  @override
  String homeMealsLogged(Object logged, Object total) {
    return '$logged of $total meals logged';
  }

  @override
  String get homeMealSchedule => 'Meal schedule';

  @override
  String homeTargetKcal(Object value) {
    return '$value kcal target';
  }

  @override
  String get homeAwaitingSync => 'Awaiting sync';

  @override
  String get homeAwaitingLog => 'Awaiting log';

  @override
  String get homeLogged => 'Logged';

  @override
  String get homeAlternativeAvailable => 'Alternative available';

  @override
  String commonCaloriesValue(Object value) {
    return '$value kcal';
  }

  @override
  String get homeCompletedOnTime => 'Completed on time';

  @override
  String get homeLogMeal => 'Log meal';

  @override
  String get homeHydrationTip =>
      'Drinking two glasses of water before each meal supports steady metabolism and helps you feel calmly full. You\'re keeping an excellent pace!';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSave => 'Save selected language';

  @override
  String get languageFooter => 'HealthyLife Care Portal — Version 2.4.0';

  @override
  String get languageCustomizeInterface => 'Customize the interface';

  @override
  String get languageChooseTitle => 'Choose the app language';

  @override
  String get languageChooseBody =>
      'Choose your preferred display language to follow your meal plan, consultation appointments and health records clearly and easily.';

  @override
  String get languageCurrentBadge => 'Current language';

  @override
  String get languageEffectTitle => 'How the change affects your experience';

  @override
  String get languageEffectBody =>
      'When you change the language, the whole app\'s layout direction updates automatically (RTL for Arabic and LTR for English) for a natural, comfortable browsing experience.';

  @override
  String get logMealTitle => 'Log a meal';

  @override
  String get logMealIntro =>
      'Logging what you ate honestly is your first step toward lasting results. Your specialist is always here to support you, without judgment.';

  @override
  String get logMealPlannedBadge => 'Approved meals';

  @override
  String get logMealFromPlanTitle => 'I ate a meal from my plan';

  @override
  String get logMealFromPlanDesc =>
      'Quickly confirm you had one of today\'s scheduled meals (breakfast, snack, lunch, dinner), with the option to adjust approved alternatives.';

  @override
  String get logMealFromPlanNote =>
      'Automatic matching of scheduled calories and ingredients';

  @override
  String get logMealFromPlanNote2 =>
      'Smart one-tap swap for equivalent alternatives';

  @override
  String get logMealFromPlanFooter => 'Continue to choose the meal (P-21)';

  @override
  String get logMealFlexibleBadge => 'Flexible search & logging';

  @override
  String get logMealOffPlanDesc =>
      'Had a food or snack that wasn\'t on your schedule? Log it easily by searching directly or entering approximate grams.';

  @override
  String get logMealOffPlanNote =>
      'A rich database of Arabic foods and common meals';

  @override
  String get logMealOffPlanNote2 =>
      'No need to feel guilty — flexibility is a key part of success';

  @override
  String get logMealOffPlanFooter =>
      'Continue to search and calculate grams (P-22)';

  @override
  String get logMealPrivacyNote =>
      'Your nutrition data is encrypted and handled with full medical confidentiality';

  @override
  String get logMealEncouragementLabel => 'A note of encouragement:';

  @override
  String get logMealEncouragementBody =>
      'Accurate logging helps your specialist fine-tune your calories and fit upcoming meals to your body\'s natural response and your daily preferences.';

  @override
  String get mealDetailTitle => 'Meal details';

  @override
  String get mealDetailIngredients => 'Meal ingredients & alternatives';

  @override
  String mealDetailItemsCount(Object count) {
    return '$count food items';
  }

  @override
  String get mealDetailUpdateNote =>
      'Today\'s log and your adherence will update instantly';

  @override
  String mealDetailCurrentMeal(Object time) {
    return 'Current meal • $time';
  }

  @override
  String get mealDetailSmartSwap => 'Smart swap flexibility';

  @override
  String get mealDetailSwapNote =>
      'Choose an alternative if the original item isn\'t available. The alternative replaces the item rather than adding to it, for precise nutritional balance.';

  @override
  String get mealDetailTotalCalories => 'Total active calories';

  @override
  String get commonCaloriesUnit => 'kcal';

  @override
  String mealDetailApprovedBy(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'unknown': 'Balanced meal approved by your nutritionist',
        'other': 'Balanced meal approved by $name (nutritionist)',
      },
    );
    return '$_temp0';
  }

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroCarbs => 'Carbs';

  @override
  String get macroHealthyFats => 'Healthy fats';

  @override
  String commonGramsShortValue(Object value) {
    return '$value g';
  }

  @override
  String get mealDetailNoAlternative => 'Core item, no alternative';

  @override
  String get mealDetailChooseOne => 'Choose one item';

  @override
  String get mealDetailOriginalItem => 'Original scheduled item';

  @override
  String mealDetailReplaces(Object item) {
    return 'Replaces $item';
  }

  @override
  String get mealDetailLoggedNow => 'I logged this meal now';

  @override
  String get mealLoggedOffPlan => 'Off-plan meal';

  @override
  String get mealLoggedFromPlan => 'Meal from your meal plan';

  @override
  String get mealLoggedTitle => 'Meal logged successfully';

  @override
  String get mealLoggedBody =>
      'Today\'s log and your nutrition adherence have been updated successfully, with clinical accuracy.';

  @override
  String get mealLoggedYourMeal => 'Your logged meal';

  @override
  String mealLoggedMealLine(Object plan, Object grams) {
    return '$plan  •  $grams g';
  }

  @override
  String get mealLoggedGoToPlan => 'Go straight to my daily plan';

  @override
  String get mealLoggedLogAnother => 'Log another meal';

  @override
  String get mealLoggedInstantUpdate => 'Instant update';

  @override
  String get mealLoggedDailyAdherence => 'Daily meal adherence';

  @override
  String mealLoggedSummary(Object logged, Object planned, Object percent) {
    return 'You logged $logged of $planned ($percent%)';
  }

  @override
  String get macroCarbohydrates => 'Carbohydrates';

  @override
  String get mealLoggedRedirecting =>
      'Taking you to your daily plan automatically...';

  @override
  String get guideNeedHelp =>
      'Need more help? Contact your specialist via chat';

  @override
  String get guideHeadline => 'Guidelines for taking accurate measurements';

  @override
  String get guideIntro =>
      'The following illustrations show exactly where to place the measuring tape, so you get accurate, consistent readings that help your specialist.';

  @override
  String get guideGeneralTips =>
      'General tips: stand relaxed, breathe normally, and don\'t pull the tape tight against your skin';

  @override
  String get guideComingFeature => 'Feature in preparation';

  @override
  String get guideVideoComingSoon =>
      '🎬 Coming soon: a short guide video (10 seconds) for each measurement, to make hands-on follow-up easier.';

  @override
  String get guideDoneBack => 'Got it, back to logging measurements';

  @override
  String get guideZoom => 'Enlarge illustration';

  @override
  String get measurementsTitle => 'Weight & body measurements';

  @override
  String get measurementsDateLabel => 'Friday, 19 September 2025';

  @override
  String get measurementsCurrentWeight => 'Current weight';

  @override
  String get commonKgUnit => 'kg';

  @override
  String measurementsDeltaVsLast(Object delta) {
    return '$delta kg compared with the last measurement';
  }

  @override
  String measurementsClinicVerified(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'unknown': 'Verified during the clinic visit',
        'other': 'Verified during the clinic visit with $name',
      },
    );
    return '$_temp0';
  }

  @override
  String get measurementsRange30 => '30 days';

  @override
  String get measurementsRange90 => '90 days';

  @override
  String get measurementsNoReadingsYet =>
      'No readings yet. Your first measurement will appear here.';

  @override
  String get measurementsNoReadingsInRange => 'No readings in this range.';

  @override
  String get measurementsSmoothStable => 'Smooth and stable';

  @override
  String get measurementsTrend => 'Change over time';

  @override
  String get measurementsClinicReading => 'Clinic measurement (verified)';

  @override
  String get measurementsHomeReading => 'Home measurement';

  @override
  String get measurementsSyncNote =>
      'Data updates are reliably synced with clinic measurements and your personal record.';

  @override
  String get measurementsLastUpdated => 'Last updated: 19 September';

  @override
  String get measurementsBodyCircumference => 'Body circumference';

  @override
  String get measurementsOngoingStep => 'Steady progress';

  @override
  String get measurementsLoggingCommitment => 'Logging consistency';

  @override
  String measurementsDaysThisWeek(Object days) {
    return 'You logged $days of 7 days this week';
  }

  @override
  String measurementsDaysThisMonth(Object days) {
    return '($days days logged in total this month)';
  }

  @override
  String get measurementsRegularNote =>
      'Logging regularly lets your specialist analyze your pattern accurately and support you with the best options, without any pressure or rush.';

  @override
  String get measurementsLogDaily => 'Log your daily measurements';

  @override
  String commonCmValue(Object value) {
    return '$value cm';
  }

  @override
  String get measurementsSteady => 'Steady and stable';

  @override
  String get measurementEntryTitle => 'Measurement details';

  @override
  String get measurementEntrySave => 'Save measurements';

  @override
  String get measurementEntryCancel => 'Cancel and return to progress';

  @override
  String get measurementEntryView => 'View';

  @override
  String get measurementEntryGuideTitle => 'Illustrated guide';

  @override
  String get measurementEntryGuideSubtitle =>
      'Simple steps for an accurate reading';

  @override
  String get measurementEntryDate => 'Measurement date';

  @override
  String get measurementEntryNoFuture => 'No future dates';

  @override
  String get measurementEntryToday => 'Today, Sun 21 Sep 2025';

  @override
  String get measurementEntrySuggestedTime =>
      'Suggested time to log: in the morning before breakfast';

  @override
  String get measurementEntryRequired => 'Required';

  @override
  String get measurementEntryRegularNote =>
      'Weighing yourself regularly in the morning after waking up gives your specialist reliable data that reflects your real progress.';

  @override
  String get measurementEntryCircumferenceTitle =>
      'Tape-measure circumferences';

  @override
  String get commonOptional => 'Optional';

  @override
  String get measurementEntryOptionalNote =>
      'Log only what you have, with no obligation';

  @override
  String get measurementEntryHowToMeasure => 'How to measure';

  @override
  String get measurementEntryUnitCm => 'In centimeters (cm)';

  @override
  String get measurementWaist => 'Waist circumference';

  @override
  String get measurementWaistHint => 'At the narrowest point above the navel';

  @override
  String get measurementHip => 'Hip circumference';

  @override
  String get measurementHipHint => 'At the widest point of the pelvis';

  @override
  String get measurementThigh => 'Thigh circumference';

  @override
  String get measurementThighHint => 'Midway between the hip and the knee';

  @override
  String get measurementArm => 'Arm circumference';

  @override
  String get measurementArmHint =>
      'Middle of the upper arm, with the arm relaxed';

  @override
  String get measurementEntryPrivacyTitle =>
      'Your health privacy is held in trust';

  @override
  String measurementEntryPrivacyBody(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'unknown':
            'All your data is protected and reaches your live medical record with your nutritionist securely, without any prior judgment or evaluation, so your plan can be adjusted to suit you.',
        'other':
            'All your data is protected and reaches your live medical record with $name securely, without any prior judgment or evaluation, so your plan can be adjusted to suit you.',
      },
    );
    return '$_temp0';
  }

  @override
  String measurementEntryLastValueHint(Object value) {
    return 'Last measurement: $value';
  }

  @override
  String get commonCmUnit => 'cm';

  @override
  String get timeAm => 'AM';

  @override
  String get timePm => 'PM';

  @override
  String get notificationSettingsHeading => 'Customize health alerts';

  @override
  String get notificationSettingsIntro =>
      'You can choose exactly which notifications you want to receive, to stay connected with your goals without any disturbance.';

  @override
  String get notificationSettingsMeals => 'Meal reminders';

  @override
  String get notificationSettingsMealsDesc =>
      'Reminders of your daily plan\'s meal times, so you can log them at the right time.';

  @override
  String get notificationSettingsMeasurements => 'Measurement reminders';

  @override
  String get notificationSettingsMeasurementsDesc =>
      'A gentle reminder every week, in the morning, to take your weight and body measurements and update your progress.';

  @override
  String get notificationSettingsPlanUpdatesDesc =>
      'An instant notification when your dietitian reviews your plan and adjusts meals or alternatives.';

  @override
  String notificationSettingsQuietRange(Object start, Object end) {
    return 'From $start to $end automatically';
  }

  @override
  String get notificationSettingsPhoneDisabled => 'Phone notifications are off';

  @override
  String get notificationSettingsSystemSettings => 'System settings';

  @override
  String get notificationSettingsPermissionOff =>
      'Notification permission for HealthyLife has been turned off in your device settings. To receive reminders and follow your meal plan, please turn them on in system settings.';

  @override
  String get notificationSettingsOpenPhoneSettings => 'Open phone settings';

  @override
  String get notificationSettingsEnableTitle =>
      'Phone notifications are not enabled';

  @override
  String get notificationSettingsEnableDesc =>
      'Meal reminders and specialist messages stay hidden until you allow them. It takes a moment and you can turn them off any time.';

  @override
  String get notificationSettingsEnable => 'Turn on notifications now';

  @override
  String get notificationSettingsEnabledTitle => 'Phone notifications are on';

  @override
  String get notificationSettingsEnabledDesc =>
      'You will get meal reminders, specialist messages and measurement times.';

  @override
  String get notificationSettingsCalm => 'Calm and balance without noise';

  @override
  String get notificationSettingsRoutine =>
      'We organize your notifications to fit your daily routine';

  @override
  String get commonOff => 'Off';

  @override
  String get notificationSettingsQuietHours => 'Do-not-disturb hours';

  @override
  String get notificationSettingsPromise =>
      'We only send the alerts you need to stay on track — no disturbance and no promotional notifications.';

  @override
  String get notificationSettingsNightQuiet => 'Night quiet hours';

  @override
  String commonFromTo(Object start, Object end) {
    return 'From $start to $end';
  }

  @override
  String get notificationSettingsStarts => 'Starts';

  @override
  String get notificationSettingsEnds => 'Ends';

  @override
  String get notificationsTitle => 'Alerts';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsAllInOne => 'Everything new, in one place';

  @override
  String get notificationsSubtitle => 'Your plan updates and health reminders';

  @override
  String get notificationsRead => 'Read';

  @override
  String notificationsMealMacros(Object protein, Object carbs) {
    return 'Protein $protein g  •  Carbs $carbs g';
  }

  @override
  String get notificationsClinicalUpdate => 'Clinical update';

  @override
  String get notificationsLogNow => 'Log now';

  @override
  String get notificationsEmptyCategory =>
      'No notifications in this category right now';

  @override
  String get notificationsPersonalized =>
      'Your alerts are personalized for your comfort';

  @override
  String get notificationsEditMealTimes =>
      'You can change meal times in settings';

  @override
  String get offlineTitle => 'No connection';

  @override
  String get offlineRetry => 'Retry connection';

  @override
  String get offlineSavedMeals => 'View meals saved offline';

  @override
  String get offlineCheckWifi =>
      'Check that Wi-Fi or mobile data is turned on in your device settings';

  @override
  String get onboardingHealthAsPrescribed => 'As prescribed';

  @override
  String get onboardingHealthTitle => 'Health data';

  @override
  String get onboardingHealthConditions => 'Health conditions & diseases';

  @override
  String get onboardingHealthConditionsNote =>
      'Select any health conditions you\'ve been diagnosed with, so your nutrition program, its ingredients and suggested meals are adapted to respond fully and safely to your body.';

  @override
  String get onboardingHealthConfidentialNote =>
      'Encrypted, medically certified clinical confidentiality — these details help your specialist exclude any ingredients that might conflict with your vital indicators or prescribed medications.';

  @override
  String get onboardingHealthAllergies => 'Food allergies & preferences';

  @override
  String get onboardingHealthAllergiesNote =>
      'Select confirmed allergens so the system automatically excludes them from meal schedules and suggested recipes.';

  @override
  String get onboardingHealthMedications => 'Regular medications & supplements';

  @override
  String get onboardingHealthDoseAccuracy => 'Dose accuracy';

  @override
  String get onboardingHealthMedicationsNote =>
      'Enter any prescribed medications or vitamins you take, so they don\'t interact chemically with meal timing and ingredients.';

  @override
  String get commonAdd => 'Add';

  @override
  String get onboardingHealthMedicationHint =>
      'Enter the medication name and dose (e.g. Omega 3)';

  @override
  String get onboardingHealthReviewNote =>
      'All notes and medications undergo careful automated and advisory review to fit your diet and rule out any food interactions with your prescribed medications.';

  @override
  String get onboardingHealthOtherNotes =>
      'Other health notes for the specialist (optional)';

  @override
  String get onboardingHealthOtherNotesHint =>
      'e.g. I take vitamin D supplements daily, previous gallbladder surgery, or any regular medications...';

  @override
  String get onboardingHealthContinue => 'Continue to next';

  @override
  String get onboardingMeasurementsPickWeight => 'Choose your weight';

  @override
  String commonKilogramsValue(Object value) {
    return '$value kg';
  }

  @override
  String get onboardingMeasurementsTitle => 'Initial measurements';

  @override
  String get onboardingMeasurementsYours => 'Your initial measurements';

  @override
  String get onboardingMeasurementsIntro =>
      'Enter your weight and measurements today so we can start tracking your health journey with your specialist accurately and professionally.';

  @override
  String get onboardingMeasurementsMandatory => 'Mandatory';

  @override
  String get commonKilogramsUnit => 'kg';

  @override
  String get onboardingMeasurementsTapToChoose => 'Tap to choose';

  @override
  String get onboardingMeasurementsMaxWeight => '160 kg';

  @override
  String get onboardingMeasurementsIdealRange => 'Estimated ideal: 65-72';

  @override
  String get onboardingMeasurementsMinWeight => '40 kg';

  @override
  String get onboardingMeasurementsTip =>
      'Specialist\'s tip: it\'s best to measure in the morning right after waking up, in light clothing and before breakfast.';

  @override
  String get onboardingMeasurementsHowTo => 'How to measure';

  @override
  String get onboardingMeasurementsIllustratedGuide => 'Illustrated guide';

  @override
  String get onboardingMeasurementsExtraNote =>
      'Additional measurements help your specialist accurately follow your body circumference and fat distribution.';

  @override
  String get onboardingMeasurementsWaistHint => 'At the narrowest point';

  @override
  String get onboardingMeasurementsHipHint => 'The widest area';

  @override
  String get onboardingMeasurementsThighHint => 'Upper right thigh';

  @override
  String get onboardingMeasurementsPrivacyNote =>
      'Your data and measurements are fully encrypted to certified health security standards, and shown only to your certified specialist to design your individual meal plan.';

  @override
  String get onboardingMeasurementsSaveContinue => 'Save and continue';

  @override
  String get onboardingNotificationsTitle => 'Don\'t miss your meal times';

  @override
  String get onboardingNotificationsIntro =>
      'Turn on notifications to receive personalized meal reminders and specialist alerts that follow your commitment step by step, smoothly.';

  @override
  String get onboardingNotificationsMealReminders =>
      'Reminders at your scheduled meal times';

  @override
  String get onboardingNotificationsMealRemindersDesc =>
      'A gentle reminder before each meal to help you organize your day and eat your healthy food at the best time for your body.';

  @override
  String get onboardingNotificationsSpecialistMessages =>
      'Direct messages and guidance from your specialist';

  @override
  String get onboardingNotificationsSpecialistMessagesDesc =>
      'Receive your specialist\'s comments and plan changes as soon as they\'re sent, without having to keep checking the app.';

  @override
  String get onboardingNotificationsWeightReminders =>
      'Weekly weigh-in reminders';

  @override
  String get onboardingNotificationsWeightRemindersDesc =>
      'A weekly reminder at the ideal morning time to measure, so you can follow your results and vital indicators accurately.';

  @override
  String get onboardingNotificationsEnable => 'Turn on notifications now';

  @override
  String get onboardingNotificationsLater => 'Not now, I\'ll set them up later';

  @override
  String onboardingStepProgress(Object percent) {
    return 'Step 3 of 3 ($percent%)';
  }

  @override
  String get onboardingNotificationsHeader => 'Alert setup • HealthyLife';

  @override
  String get onboardingNotificationsRespectLabel =>
      'We respect your calm and privacy:';

  @override
  String get onboardingNotificationsRespectBody =>
      'We\'ll never send promotional ads, and you can always adjust or mute alert times in settings.';

  @override
  String get onboardingTrackTitle => 'Track your meals and weight in one tap';

  @override
  String get onboardingTrackDescription =>
      'Log your daily meals and weight precisely in grams, and use the available alternatives to make sticking to your diet easier, without deprivation.';

  @override
  String get onboardingBadgeSmartScan => 'Instant smart scan';

  @override
  String get onboardingBadgeDetailedAccuracy => 'Detailed accuracy';

  @override
  String get onboardingPlanTitle =>
      'Your meal plan, supervised by your specialist';

  @override
  String get onboardingPlanDescription =>
      'Get a fully personalized diet that suits your body and health condition, designed directly by the dietitian following your case.';

  @override
  String get onboardingBadgeApproved =>
      '100% medically approved and based on lab tests';

  @override
  String get onboardingStartNow => 'Get started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get passwordErrorEnterCurrent => 'Enter your current password';

  @override
  String get passwordErrorMinLength =>
      'Make your password at least 8 characters';

  @override
  String get passwordErrorUppercase => 'Add at least one uppercase letter';

  @override
  String get passwordErrorDigit => 'Add at least one number';

  @override
  String get passwordErrorSpecial => 'Add at least one special character';

  @override
  String get passwordErrorMismatch =>
      'Confirm your new password so that it matches exactly';

  @override
  String get passwordSaved => 'Password saved successfully';

  @override
  String get passwordResetLinkSent =>
      'A password reset link will be sent to your registered number or email';

  @override
  String get passwordTitle => 'Password';

  @override
  String get passwordCurrent => 'Current password';

  @override
  String get passwordForgot => 'Forgot your password?';

  @override
  String get passwordConfirmNew => 'Confirm new password';

  @override
  String get passwordMatches => 'The new password matches exactly';

  @override
  String get passwordNoMatch => 'The passwords don\'t match';

  @override
  String get passwordRequirements => 'Password requirements:';

  @override
  String get passwordRuleMinLength8 => 'At least 8 characters';

  @override
  String get passwordRuleSpecial => 'At least one special character (!@#\$%)';

  @override
  String get passwordLogoutOthersNote =>
      'After you change your password, you\'ll be logged out of other devices automatically to protect your medical account and your health.';

  @override
  String get passwordProtectionTitle => 'Account & health data protection';

  @override
  String get passwordProtectionBody =>
      'Choose a strong, unique password to keep your plan and health records private.';

  @override
  String get passwordStrengthEnter => 'Enter a password';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthFair => 'Fair';

  @override
  String get passwordStrengthGood => 'Good';

  @override
  String get passwordStrengthVeryStrong => 'Very strong';

  @override
  String get passwordStrengthLabel => 'Password strength:';

  @override
  String get commonSaved => 'Saved';

  @override
  String get passwordSave => 'Save password';

  @override
  String get planPreparingTitle => 'Your plan is being carefully prepared';

  @override
  String get planPreparingBody =>
      'Your clinical dietitian is now preparing your personalized meal schedule to fit your health goals and initial measurement results. We\'ll notify you as soon as the plan is approved, and you\'ll find it here.';

  @override
  String get planPreparingExpectedTime => 'Expected approval time';

  @override
  String get planPreparingWithin24h =>
      'Within 24 working hours of logging your initial measurements';

  @override
  String get planPreparingReview => 'Verified clinical review';

  @override
  String planPreparingManualPercent(Object percent) {
    return '$percent% personalized';
  }

  @override
  String get planPreparingUrgentQuestion =>
      'An urgent question or food preference?';

  @override
  String get planPreparingTeamAvailable =>
      'Our team and your specialist are available to help right away';

  @override
  String get planPreparingContactWhatsApp =>
      'Contact the specialist on WhatsApp';

  @override
  String get planPreparingHours =>
      'Available throughout official working days from 9:00 AM to 6:00 PM';

  @override
  String planPreparingClinic(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'unknown': 'Clinical nutrition clinic',
        'other': 'Clinical nutrition clinic • $name',
      },
    );
    return '$_temp0';
  }

  @override
  String get planPreparingAdvanced => 'Advanced personalization';

  @override
  String get commonEnabled => 'Enabled';

  @override
  String get privacyScopeTitle => '1. Scope of data collected';

  @override
  String get privacyScopeBody =>
      'We collect only what\'s needed to build your therapeutic meal plan: your vital measurements (weight, body circumference), your daily meal logs, your diagnosed health conditions, your food allergies, and the medications and supplements you tell us about. We never request or store financial data or permanent location data.';

  @override
  String get privacyEncryptionTitle => '2. Encryption and storage locations';

  @override
  String get privacyEncryptionBody =>
      'All health data is encrypted in transit and at rest with AES-256 and stored on isolated medical servers that comply with HIPAA standards. Your data is never used to train general models and is never shared with any advertising company under any circumstances.';

  @override
  String get privacyAccessTitle => '3. Who can see your record';

  @override
  String get privacyAccessBody =>
      'Only your dedicated care team — the certified clinical dietitian on your account — can see your full record. Every update or change to your plan is recorded with its author and time in an audit log that cannot be deleted.';

  @override
  String get privacyRightsTitle => '4. Your right to change and withdraw';

  @override
  String get privacyRightsBody =>
      'You can withdraw your consent at any time from Account → Privacy, which automatically pauses plan personalization until you renew your consent. You can also request a full copy of your data, or its permanent deletion, by contacting your specialist.';

  @override
  String get privacyRetentionTitle => '5. Data retention after follow-up ends';

  @override
  String get privacyRetentionBody =>
      'When your clinical follow-up period ends, your logs and measurements stay safely stored so the plan can resume as soon as you renew, and they are only deleted at your explicit request.';

  @override
  String get privacyTitle => 'Full clinical privacy';

  @override
  String get privacyLastUpdated =>
      'Last updated: January 2026 — compliant with clinical HIPAA standards';

  @override
  String get profileMeasurementsSubtitle =>
      'Log your measurements and follow how you\'re changing';

  @override
  String get profileHealthRecordSubtitle =>
      'Level, goal, medications and confirmed diagnoses';

  @override
  String get profileAchievements => 'My achievements';

  @override
  String get profileWellbeing => 'Sleep, stress & mood';

  @override
  String get profileAppointments => 'Appointments & follow-up';

  @override
  String get profileNotificationLog => 'Notification history';

  @override
  String get profileTitle => 'Account';

  @override
  String get commonSettings => 'Settings';

  @override
  String get profileAccountSettings => 'Account & follow-up settings';

  @override
  String get profileDietitian => 'Dietitian';

  @override
  String profileDietitianName(String gender, String name) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'unknown': 'Clinical nutrition specialist',
        'other': '$name (clinical nutrition specialist)',
      },
    );
    return '$_temp0';
  }

  @override
  String get profileNotificationsSubtitle => 'Meal and measurement reminders';

  @override
  String get profilePasswordSubtitle => 'Update and protect your account';

  @override
  String get profileLanguageCurrent => 'English (current)';

  @override
  String get profileLanguageBadge => 'English';

  @override
  String get profileVersion => 'Version 1.0.0';

  @override
  String get profileUpgradeRequired =>
      'This feature requires a higher plan — contact your specialist to upgrade';

  @override
  String get profileHealthCv => 'Health profile (Health CV)';

  @override
  String get profileHealthCvSubtitle =>
      'A comprehensive health record prepared by your specialist';

  @override
  String get profileLogoutCaption =>
      'Logging out requires confirmation so your latest measurements are synced';

  @override
  String get profilePatientCode => 'Patient code: HL-0042';

  @override
  String get profileFollowingClinic => 'Following clinic';

  @override
  String get profileMore => 'More';

  @override
  String get profileMoreSubtitle =>
      'Measurements, medical record, achievements and appointments';

  @override
  String get profileLogoutSubtitle => 'End the session securely on this device';

  @override
  String get progressNextConsultation =>
      'Next consultation: next Sunday at 5:00 PM';

  @override
  String progressNextAppointment(String date) {
    return 'Your next appointment: $date';
  }

  @override
  String get progressTitle => 'Progress tracking & evaluation';

  @override
  String get progressActiveFile => 'Active file';

  @override
  String get progressLiveSync => 'Live sync with the clinic';

  @override
  String get progressOnlineNow => 'Online now';

  @override
  String get progressAndMeasurements => 'Progress';

  @override
  String get progressSpecialistNotes => 'Notes';

  @override
  String get commonNew => 'New';

  @override
  String get progressCurrentWeight => 'Current recorded weight';

  @override
  String get progressLogWeightToday => 'Log a new weight today';

  @override
  String get progressWeightTrend => 'Weight trend';

  @override
  String get progressClinicVsHome => 'Clinic vs. home measurements';

  @override
  String get progressRange30 => '30 days';

  @override
  String get progressRange90 => '90 days';

  @override
  String get commonToday => 'Today';

  @override
  String get progressClinicReading => 'Clinic (verified)';

  @override
  String get progressHomeReading => 'Home (regular)';

  @override
  String get progressVitalCircumference => 'Body measurements';

  @override
  String progressUpdatedOn(String date) {
    return 'Updated $date';
  }

  @override
  String get progressNoCircumference =>
      'No circumference measurements yet. Add them with your next weight.';

  @override
  String progressCmChange(String value) {
    return '$value cm';
  }

  @override
  String get progressUpdatedTwoDaysAgo => 'Updated 2 days ago';

  @override
  String get progressWaist => 'Waist';

  @override
  String get progressWaistDelta => '-4 cm';

  @override
  String get progressHip => 'Hip';

  @override
  String get progressHipDelta => '-2 cm';

  @override
  String get progressThigh => 'Thigh';

  @override
  String get progressThighDelta => '-1 cm';

  @override
  String get progressArm => 'Arm';

  @override
  String get progressGuideLink => 'Illustrated measurement guide';

  @override
  String get progressWeeklyEvaluation => 'This week\'s evaluation';

  @override
  String get progressLatestReview => 'Latest review from your nutritionist';

  @override
  String progressAdherencePercent(String percent) {
    return '$percent% adherence';
  }

  @override
  String get progressNoReadings => 'No weight readings in this period yet.';

  @override
  String progressReviewedBy(String name) {
    return 'Reviewed by $name';
  }

  @override
  String get progressExcellent => 'Excellent performance';

  @override
  String get progressEvaluationBody =>
      'An excellent response in insulin resistance, with a noticeable improvement in vital energy balance during the morning hours and remarkable stability in waist measurements.';

  @override
  String get progressEncouragementTitle => 'A special note of encouragement';

  @override
  String get progressEncouragementQuote =>
      '“I\'m so proud of your awareness and commitment this week! The weight loss is gradual and healthy, and your waist has improved noticeably. Keep up your current sleep pattern and we\'ll reach this month\'s goal easily.”';

  @override
  String get progressVoiceNote => 'Voice note from the doctor';

  @override
  String get progressTaskWater => 'Increase water intake to 2.5 liters a day';

  @override
  String get progressTaskWaterDesc =>
      'Spread it evenly, one glass every two hours between meals, to boost metabolism.';

  @override
  String get progressTaskCottageCheese =>
      'Cottage cheese with olive oil as an alternative';

  @override
  String get progressTaskCottageCheeseDesc =>
      'Adopt it as your main dinner to support slow satiety and balance blood sugar at night.';

  @override
  String get progressTaskWalk => 'A 15-minute light walk after dinner';

  @override
  String get progressTaskWalkDesc =>
      'Boosts circulation and draws down glycogen stores before sleep.';

  @override
  String get progressNextWeekGuidance => 'Next week\'s guidance';

  @override
  String progressTaskCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String get progressAllNotes => 'View all notes';

  @override
  String get progressThreeTasks => '3 specific tasks';

  @override
  String get progressDiscussWhatsApp =>
      'Discuss the evaluation directly on WhatsApp';

  @override
  String get quantityFreshFruit => 'Fresh fruit';

  @override
  String quantityKcalPerGrams(Object kcal, Object grams) {
    return '$kcal kcal per $grams g';
  }

  @override
  String quantityKcalTimesPortions(Object kcal, Object portions) {
    return '$kcal kcal × $portions portions';
  }

  @override
  String get quantityCalculatedNote =>
      'The value is fully calculated and added precisely to your daily plan';

  @override
  String quantityRange(Object min, Object max) {
    return 'Available range: $min g to $max g';
  }

  @override
  String get quantityGramsUnit => 'grams (g)';

  @override
  String get quantityCommonAmounts => 'Common quick amounts:';

  @override
  String get quantityOneTap => 'Pick with one tap';

  @override
  String get quantityFineSlider => 'Fine-adjustment slider';

  @override
  String get quantityEstimateHint => 'A hint to help you estimate';

  @override
  String quantityEstimateBody(Object apple, Object palm) {
    return 'A medium apple is about $apple g, while a flat palm is about $palm g of meat or cooked rice — you can always estimate roughly without worry.';
  }

  @override
  String quantityStepAdd(String value) {
    return '+$value';
  }

  @override
  String quantityStepSubtract(String value) {
    return '-$value';
  }

  @override
  String get quantityReassuring => 'A reassuring, healthy approach';

  @override
  String get quantityFlexibility =>
      'Flexibility in logging is the foundation of lasting healthy habits';

  @override
  String get quantityConfirm => 'Confirm amount & log food';

  @override
  String get weekdayShortSunday => 'Sun';

  @override
  String get weekdayShortMonday => 'Mon';

  @override
  String get weekdayShortTuesday => 'Tue';

  @override
  String get weekdayShortWednesday => 'Wed';

  @override
  String get weekdayShortThursday => 'Thu';

  @override
  String get callsResultsReview => 'Measurement results review';

  @override
  String get callsCompleted => 'Completed';

  @override
  String get callsPast => 'Past';

  @override
  String get callsUpcoming => 'Upcoming';

  @override
  String get callsBookNew => 'Book a new appointment';

  @override
  String callsWithNutritionist(String name) {
    return 'With $name';
  }

  @override
  String get appointmentReminderChannel => 'Appointment reminders';

  @override
  String get appointmentReminderTitle => 'Upcoming appointment';

  @override
  String get appointmentReminderDay => 'Your appointment is in 24 hours';

  @override
  String get appointmentReminderHour => 'Your appointment is in 1 hour';

  @override
  String get appointmentReminderFiveMinutes =>
      'Your appointment starts in 5 minutes';

  @override
  String get callsTypeFollowUp => 'Follow-up session';

  @override
  String get callsTypeQuickConsult => 'Quick consultation';

  @override
  String get callsTypeOther => 'Appointment';

  @override
  String get callsChannelWhatsapp => 'WhatsApp';

  @override
  String get callsChannelPhone => 'Phone call';

  @override
  String get callsChannelVideo => 'Video call';

  @override
  String get callsStatusBooked => 'Booked';

  @override
  String get callsStatusCancelled => 'Cancelled';

  @override
  String get callsStatusNoShow => 'Missed';

  @override
  String get callsEmptyUpcoming => 'No upcoming appointments.';

  @override
  String get callsEmptyPast => 'No past appointments yet.';

  @override
  String get wellbeingSleepQuality => 'Your sleep quality last night';

  @override
  String get wellbeingHours => 'hours';

  @override
  String get wellbeingGoodSleep => 'Good sleep — keep the same routine';

  @override
  String get wellbeingStressLevel => 'Stress level';

  @override
  String get wellbeingLow => 'Low';

  @override
  String get wellbeingBreathingMoment => 'A breathing moment';

  @override
  String get specialistTitle => 'Specialist profile';

  @override
  String get specialistAboutTitle => 'About your nutritionist';

  @override
  String get specialistProfileActive => 'Therapeutic nutrition profile active';

  @override
  String get specialistCertified => 'Certified';

  @override
  String get specialistLicensed => 'Licensed';

  @override
  String get specialistLicensedByAuthority =>
      'Licensed by the health authority';

  @override
  String get specialistDirectCare => 'Direct one-on-one care';

  @override
  String get specialistHoursTitle => 'Usual response and follow-up hours';

  @override
  String get specialistQuickConsult =>
      'Quick consultation with your specialist';

  @override
  String get specialistQuickConsultBody =>
      'Reach out any time to discuss meal changes and how you\'re feeling overall';

  @override
  String get specialistContactWhatsApp => 'Contact via WhatsApp';

  @override
  String get specialistContactNote =>
      'Opens a direct chat with the specialist to follow up on your case';

  @override
  String get splashTagline => 'A small step toward better health';

  @override
  String get splashSubtitle =>
      'We\'re with you on the way to a more balanced life, day by day.';

  @override
  String get splashCaringEveryDay => 'Caring for your health, every day';

  @override
  String get splashPreparing => 'Preparing your health experience';

  @override
  String get weekdayShortSaturday => 'Sat';

  @override
  String get weekdayShortFriday => 'Fri';

  @override
  String get weeklyPlanPreviewScreen => 'Plan preview & advance preparation';

  @override
  String get weeklyPlanLoggingHint =>
      'To log meals and confirm you ate them, please go to the My daily plan tab';

  @override
  String get weeklyPlanWeekThree => 'Week three';

  @override
  String get weeklyPlanMonth => 'September 2025';

  @override
  String get weeklyPlanDetailed => 'Detailed plan';

  @override
  String weeklyPlanDayPlan(Object day, Object date) {
    return '$day • $date Sep';
  }

  @override
  String get macroHealthyFatsShort => 'Healthy fats';

  @override
  String get macroProteinLabel => 'Protein';

  @override
  String get macroFatLabel => 'Fat';

  @override
  String get weeklyPlanFats => '42 g';

  @override
  String get weeklyPlanCarbs => '120 g';

  @override
  String get weeklyPlanProtein => '105 g';

  @override
  String get weeklyPlanSummary =>
      'A balanced plan to boost energy and burn fat, supervised by your specialist';

  @override
  String get connectionStatusTitle => 'Connection status';

  @override
  String datePickerKcal(Object value) {
    return '$value kcal';
  }

  @override
  String get liveBadge => 'Live';

  @override
  String get lockedContactSpecialist => 'Contact your specialist';

  @override
  String get mealCardLogged => 'Meal logged';

  @override
  String get mealCardNextCurrent => 'Next / current meal';

  @override
  String get mealCardScheduledLater => 'Scheduled for later';

  @override
  String get mealCardLogNow => 'Log this meal now';

  @override
  String get offlineBannerSyncing => 'Syncing your data...';

  @override
  String get offlineBannerOffline => 'You\'re offline right now';

  @override
  String get offlineBannerUpdating =>
      'Your records are being updated with the server now';

  @override
  String get offlineBannerSavedLocally =>
      'Your data is safely saved on this device';

  @override
  String offlineBannerPending(Object count) {
    return '$count awaiting sync';
  }

  @override
  String get offlinePanelBrowsePlan => 'Browse today\'s saved meal plan';

  @override
  String get offlinePanelBrowsePlanDesc =>
      'Calorie and ingredient tables are available offline';

  @override
  String get offlinePanelLogMeasurements =>
      'Log weight and circumference measurements';

  @override
  String get offlinePanelLogMeasurementsDesc =>
      'Changes are saved in the phone\'s encrypted database';

  @override
  String get offlinePanelNotes => 'Jot down notes and quick meals';

  @override
  String get offlinePanelNotesDesc => 'Queued for instant sync later';

  @override
  String get offlinePanelPrivacy => 'Privacy protection and local encryption';

  @override
  String get offlinePanelPrivacyDesc =>
      'Advanced encryption protects your health records without needing a server';

  @override
  String get offlinePanelSavedNote =>
      'Your data and logged meals are safely saved on your device. We\'ll sync to the cloud automatically as soon as the network is back.';

  @override
  String get offlinePanelLocally => 'Locally';

  @override
  String get offlinePanelModeActive => 'Offline mode is active';

  @override
  String get offlinePanelContinue =>
      'You can keep browsing your meal plan and logging your meals as usual, without interruption.';

  @override
  String get offlinePanelWhatNow => 'What can you do right now?';

  @override
  String onboardingStepOf(Object step, Object total, Object percent) {
    return 'Step $step of $total ($percent%)';
  }

  @override
  String get onboardingStepBrand => 'HealthyLife • Health profile';

  @override
  String get breathingInhale => 'Inhale';

  @override
  String get breathingExhale => 'Exhale';

  @override
  String substitutionKcalDelta(Object sign, Object delta) {
    return '($sign$delta kcal)';
  }

  @override
  String get substitutionOriginal => 'Original item';

  @override
  String get substitutionFixed => 'Fixed';

  @override
  String get substitutionCoreNoAlternative => 'Core item, no alternative';

  @override
  String dailyLogMealsCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText meals',
      one: '1 meal',
    );
    return '$_temp0';
  }

  @override
  String foodSearchFoodsCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText foods',
      one: '1 food',
    );
    return '$_temp0';
  }

  @override
  String mealLoggedCountdown(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String mealLoggedMealsCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText meals',
      one: '1 meal',
    );
    return '$_temp0';
  }

  @override
  String notificationsNewCount(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $countText new notifications',
      one: 'You have 1 new notification',
    );
    return '$_temp0';
  }

  @override
  String redirectCountdown(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Redirecting you automatically in $countText seconds…',
      one: 'Redirecting you automatically in $countText second…',
    );
    return '$_temp0';
  }

  @override
  String languageSubtitleCurrent(String languageName) {
    return '$languageName (current app language)';
  }

  @override
  String get commonShow => 'Show';

  @override
  String get commonHide => 'Hide';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle =>
      'Use the username and password your specialist sent you on WhatsApp.';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginUsernameHint => 'Letters in English only';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginCta => 'Sign in';

  @override
  String get loginErrorRequired => 'Enter your username and password.';

  @override
  String get loginErrorInvalid => 'The username or password is wrong.';

  @override
  String loginErrorLocked(String time) {
    return 'Sign-in is paused after several wrong attempts. Try again at $time.';
  }

  @override
  String get loginErrorRateLimited =>
      'Too many attempts in a short time. Wait a moment and try again.';

  @override
  String get loginErrorGeneric => 'Sign-in failed. Please try again.';

  @override
  String get loginForgotBody =>
      'Ask your specialist to reset your password. They will send you a new username and password on WhatsApp.';

  @override
  String get sessionEndedMessage =>
      'Your session has ended. Please sign in again.';

  @override
  String get passwordRuleLowercase => 'At least one lowercase letter (a–z)';

  @override
  String get passwordErrorLowercase => 'Add at least one lowercase letter';

  @override
  String get passwordCurrentWrong => 'The current password is wrong.';

  @override
  String get passwordWeakServer =>
      'The new password does not meet the requirements. Choose another one.';

  @override
  String get consentVersionChanged =>
      'The privacy policy was updated. Please read the new version.';

  @override
  String get linkCouldNotOpen => 'The link could not be opened.';

  @override
  String followUpWeeksValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String get followUpWeeksLabel => 'Weeks followed';

  @override
  String followUpAdherenceValue(String value) {
    return '$value%';
  }

  @override
  String get passwordTemporaryTitle => 'Your password is temporary';

  @override
  String get passwordTemporaryBody =>
      'Set a password of your own. The app keeps working in the meantime.';

  @override
  String get accountDeleteTitle => 'Delete account';

  @override
  String get accountDeleteWarningTitle => 'This cannot be undone';

  @override
  String get accountDeleteWarningBody =>
      'Your account and all of its data will be deleted permanently.';

  @override
  String get accountDeletePasswordLabel => 'Your current password';

  @override
  String get accountDeleteCta => 'Delete my account';

  @override
  String get accountDeleteConfirmTitle => 'Delete your account?';

  @override
  String get accountDeleteConfirmMessage =>
      'Your account and all of its data will be deleted permanently. This cannot be undone.';

  @override
  String get accountDeleteWrongPassword => 'That password is not correct.';

  @override
  String get healthGoalNotSet => 'No goal has been set yet';

  @override
  String get healthGoalWeightLoss => 'Weight loss';

  @override
  String get healthGoalWeightGain => 'Weight gain';

  @override
  String get healthGoalMuscleGain => 'Muscle gain';

  @override
  String get healthGoalWeightMaintenance => 'Weight maintenance';

  @override
  String get healthGoalHealthEnergy => 'Health and energy';

  @override
  String get healthGoalMedicalCondition => 'Medical condition';

  @override
  String get healthGoalOther => 'Other';

  @override
  String healthGoalTarget(String value) {
    return 'Target: $value';
  }

  @override
  String healthGoalTargetDate(String date) {
    return 'By $date';
  }

  @override
  String get healthNoMedications => 'No medications recorded';

  @override
  String get healthTimingBefore => 'Before meals';

  @override
  String get healthTimingWith => 'With meals';

  @override
  String get healthTimingAfter => 'After meals';

  @override
  String get healthTimingEmptyStomach => 'On an empty stomach';

  @override
  String get healthTimingAny => 'Any time';

  @override
  String get healthMedStatusOngoing => 'Ongoing';

  @override
  String healthMedStatusUntil(String date) {
    return 'Until $date';
  }

  @override
  String get healthMedReviewedBy => 'Reviewed by your nutritionist';

  @override
  String healthMedReviewedOn(String date) {
    return 'Last reviewed $date';
  }

  @override
  String get healthMedDisclaimer =>
      'This information is only for your nutritionist\'s follow-up and is not medication advice. Do not change your medications without consulting your doctor.';

  @override
  String get healthNoAllergies => 'No allergies recorded';

  @override
  String get healthAllergyFooter =>
      'Foods that may contain these show a warning in your plan.';

  @override
  String get healthAllergyClassConfirmed => 'Confirmed allergy';

  @override
  String get healthAllergyClassIntolerance => 'Intolerance';

  @override
  String get healthAllergyClassAvoid => 'Avoid';

  @override
  String get healthRequestsTitle => 'Request a change';

  @override
  String get healthRequestIntro =>
      'Changes take effect only after your nutritionist approves them.';

  @override
  String get healthRequestGoalSection => 'Goal';

  @override
  String get healthRequestMedicationsSection => 'Medications';

  @override
  String get healthRequestAllergiesSection => 'Allergies';

  @override
  String get healthRequestMyRequestsSection => 'My requests';

  @override
  String get healthRequestChangeGoal => 'Request a change to my goal';

  @override
  String get healthRequestAddMedication => 'Add a medication';

  @override
  String get healthRequestAddAllergy => 'Add an allergy';

  @override
  String get healthRequestGoalTitle => 'Change my goal';

  @override
  String get healthRequestMedicationTitleEdit => 'Change a medication';

  @override
  String get healthRequestAllergyTitleEdit => 'Change an allergy';

  @override
  String get healthRequestActionAdd => 'Add';

  @override
  String get healthRequestActionEdit => 'Change';

  @override
  String get healthRequestActionRemove => 'Remove';

  @override
  String get healthRequestRemove => 'Remove';

  @override
  String get healthRequestRemoveTitle => 'Request removal?';

  @override
  String get healthRequestRemoveBody =>
      'Your nutritionist will review the removal before it takes effect.';

  @override
  String get healthRequestWithdraw => 'Withdraw';

  @override
  String get healthRequestWithdrawTitle => 'Withdraw this request?';

  @override
  String get healthRequestWithdrawBody => 'Your nutritionist will not see it.';

  @override
  String get healthRequestStatusPending =>
      'Waiting for your nutritionist\'s approval';

  @override
  String get healthRequestStatusApproved => 'Approved';

  @override
  String get healthRequestStatusRejected => 'Not approved';

  @override
  String get healthRequestStatusWithdrawn => 'Withdrawn';

  @override
  String get healthRequestPendingChip => 'Waiting for approval';

  @override
  String get healthRequestNoRequests => 'No requests in the last 60 days.';

  @override
  String healthRequestDecisionNote(String note) {
    return 'Nutritionist\'s note: $note';
  }

  @override
  String get healthRequestSend => 'Send request';

  @override
  String get healthRequestSent =>
      'Your request was sent. It takes effect after your nutritionist approves it.';

  @override
  String get healthRequestWithdrawnSnack => 'Request withdrawn.';

  @override
  String get healthRequestAlreadyPending =>
      'A request for this item is already waiting for approval.';

  @override
  String get healthRequestAlreadyRecorded =>
      'This allergy is already on your profile.';

  @override
  String get healthRequestNotPending =>
      'This request was already decided, so it can\'t be withdrawn.';

  @override
  String get healthRequestInvalid => 'Check the highlighted fields.';

  @override
  String get healthRequestFieldRequired => 'Required';

  @override
  String get healthRequestFieldNumber => 'Enter a number';

  @override
  String healthRequestFieldRange(String min, String max) {
    return 'Enter a number from $min to $max';
  }

  @override
  String healthRequestFieldTooLong(String max) {
    return 'At most $max characters';
  }

  @override
  String get healthRequestFieldNotAfterToday => 'Choose a date after today';

  @override
  String get healthRequestFieldBeforeToday => 'Choose today or a later date';

  @override
  String get healthRequestGoalType => 'Goal';

  @override
  String get healthRequestTargetWeight => 'Target weight (kg)';

  @override
  String get healthRequestTargetDate => 'Target date';

  @override
  String get healthRequestChooseDate => 'Choose a date';

  @override
  String get healthRequestActivity => 'Activity level';

  @override
  String get healthRequestTrainingDays => 'Training days per week';

  @override
  String get healthRequestTrainingLevel => 'Training level';

  @override
  String get healthRequestTrainingType => 'Type of training';

  @override
  String get healthRequestDetails => 'Details';

  @override
  String get healthRequestName => 'Name';

  @override
  String get healthRequestDose => 'Dose';

  @override
  String get healthRequestFrequency => 'How often';

  @override
  String get healthRequestTiming => 'When to take it';

  @override
  String get healthRequestReason => 'Why it is taken';

  @override
  String get healthRequestDuration => 'How long';

  @override
  String get healthRequestUntilDate => 'Until a date';

  @override
  String get healthRequestAllergy => 'Allergy';

  @override
  String get healthRequestOtherText => 'Describe it';

  @override
  String get healthRequestClass => 'How strict is it';

  @override
  String get healthRequestNote => 'Note';

  @override
  String get healthAllergyGroupTreeNuts => 'Tree nuts';

  @override
  String get healthAllergyGroupPeanuts => 'Peanuts';

  @override
  String get healthAllergyGroupMilk => 'Milk and lactose';

  @override
  String get healthAllergyGroupEgg => 'Egg';

  @override
  String get healthAllergyGroupWheat => 'Wheat and gluten';

  @override
  String get healthAllergyGroupSesame => 'Sesame';

  @override
  String get healthAllergyGroupFish => 'Fish';

  @override
  String get healthAllergyGroupShellfish => 'Shellfish';

  @override
  String get healthAllergyGroupSoy => 'Soy';

  @override
  String get healthAllergyGroupOther => 'Other (write it)';

  @override
  String get healthActivitySedentary => 'Sedentary';

  @override
  String get healthActivityLight => 'Light activity';

  @override
  String get healthActivityModerate => 'Moderate activity';

  @override
  String get healthActivityActive => 'Active';

  @override
  String get healthActivityVeryActive => 'Very active';

  @override
  String get healthTrainingBeginner => 'Beginner';

  @override
  String get healthTrainingIntermediate => 'Intermediate';

  @override
  String get healthTrainingAdvanced => 'Advanced';

  @override
  String get healthTrainingStrength => 'Strength training';

  @override
  String get healthTrainingCardio => 'Cardio';

  @override
  String get healthTrainingMixed => 'Mixed';

  @override
  String get healthTrainingSports => 'Sports';

  @override
  String get foodSearchTypeToSearch => 'Type at least 2 letters to search.';

  @override
  String get foodSearchResultsTitle => 'Results';

  @override
  String get foodAllergyBadge => 'May contain your allergen';

  @override
  String get reviewsTitle => 'Notes from your nutritionist';

  @override
  String get reviewsEntrySubtitle => 'Read the notes and tick off your tasks';

  @override
  String get reviewsEmpty =>
      'No notes yet. Notes from your nutritionist will appear here.';

  @override
  String get reviewRatingOnTrack => 'On track';

  @override
  String get reviewRatingSmallAdjustment => 'Small adjustment';

  @override
  String get reviewRatingReviewTogether => 'Review together';

  @override
  String get reviewEdited => 'Updated by your nutritionist';

  @override
  String get reviewKeyPointsTitle => 'Key points';

  @override
  String get reviewTasksTitle => 'Tasks';

  @override
  String get reviewAcknowledge => 'Got it';

  @override
  String get reviewSeen => 'Seen';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get mealTypeOther => 'Meal';

  @override
  String homeSuggestedAlternative(String grams, String food) {
    return 'Suggested alternative: $food ($grams g)';
  }

  @override
  String get planEmptyTitle => 'No active plan yet';

  @override
  String get planEmptyBody =>
      'Your plan will appear here as soon as your nutritionist activates it.';

  @override
  String get planNoMealToday => 'Your plan has no meals for today';

  @override
  String weeklyPlanWeekNumber(String week) {
    return 'Week $week of your plan';
  }

  @override
  String get weeklyPlanFromNutritionist =>
      'Your plan as your nutritionist set it';

  @override
  String get mealDetailFromPlan => 'From your nutritionist\'s plan';

  @override
  String weeklyPlanDayOf(String date) {
    return 'Plan for $date';
  }

  @override
  String get nutritionistAvatarLabel => 'Nutritionist';

  @override
  String get patientAvatarLabel => 'Account';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String get notificationsJustNow => 'Just now';

  @override
  String notificationsMinutesAgo(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String notificationsHoursAgo(num count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get notificationsLoadOlder => 'Show older notifications';

  @override
  String get weighInReminderChannel => 'Weekly weigh-in reminder';

  @override
  String get weighInReminderTitle => 'Time for your weekly weigh-in';

  @override
  String get weighInReminderBody =>
      'Log your weight now, after waking up, to keep your progress accurate.';

  @override
  String get notificationSettingsNutritionistDesc =>
      'New notes from your nutritionist, and changes to them.';

  @override
  String get notificationSettingsSaveFailed =>
      'The setting could not be saved. Check your connection and try again.';
}
