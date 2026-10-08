import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart';

class _DocSection {
  final String heading;
  final String body;
  const _DocSection(this.heading, this.body);
}

/// A single, real, read-only document screen shared by every "read the
/// full policy" link in the app (health-data consent, the account
/// settings footer, the follow-up-ended screen's terms link) — one source
/// of truth for the legal copy instead of three dead links to nowhere.
class PrivacyDocumentScreen extends StatelessWidget {
  const PrivacyDocumentScreen({super.key});

  static const List<_DocSection> _sections = [
    _DocSection(
      '١. نطاق البيانات المجمّعة',
      'نجمع فقط ما يلزم لبناء خطتك الغذائية العلاجية: قياساتك الحيوية (الوزن، محيط الجسم)، سجلات وجباتك اليومية، حالاتك الصحية المشخصة، حساسياتك الغذائية، والأدوية والمكملات التي تخبرينا بها. لا نطلب أو نُخزّن أي بيانات مالية أو بيانات موقع دائم.',
    ),
    _DocSection(
      '٢. التشفير وأماكن التخزين',
      'تُشفّر جميع البيانات الصحية أثناء النقل والتخزين بنظام bit AES-256، وتُحفظ على خوادم طبية معزولة متوافقة مع معايير HIPAA. لا تُستخدم بياناتك في تدريب نماذج عامة ولا تُشارك مع أي شركة إعلانات تحت أي ظرف.',
    ),
    _DocSection(
      '٣. من يستطيع الاطلاع على ملفك',
      'فريق الرعاية المخصص لك فقط — أخصائية التغذية العلاجية المعتمدة على حسابك — يستطيع الاطلاع على سجلك الكامل. أي تحديث أو تعديل على خطتك يُسجَّل باسم صاحبه ووقته في سجل تدقيق لا يمكن حذفه.',
    ),
    _DocSection(
      '٤. حقك في التعديل والإلغاء',
      'يمكنك سحب موافقتك في أي وقت من الحساب ← الخصوصية، وسيؤدي ذلك إلى إيقاف تخصيص الخطة تلقائياً حتى تجديد الموافقة. يمكنك أيضاً طلب نسخة كاملة من بياناتك أو حذفها نهائياً بالتواصل مع أخصائيتك.',
    ),
    _DocSection(
      '٥. الاحتفاظ بالبيانات بعد انتهاء المتابعة',
      'عند انتهاء فترة المتابعة السريرية، تبقى سجلاتك وقياساتك محفوظة بأمان لاستئناف الخطة فور التجديد، ولا تُحذف تلقائياً إلا بطلب صريح منك.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'الخصوصية السريرية الكاملة'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: const Row(children: [
              Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('آخر تحديث لهذه الوثيقة: يناير 2026 — متوافقة مع معايير HIPAA السريرية', style: AppTextStyles.caption)),
            ]),
          ),
          const SizedBox(height: 18),
          for (final s in _sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.heading, style: AppTextStyles.sectionHeading),
                const SizedBox(height: 8),
                Text(s.body, style: AppTextStyles.body.copyWith(height: 1.7)),
              ]),
            ),
        ],
      ),
    );
  }
}
