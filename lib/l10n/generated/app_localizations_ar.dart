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
}
