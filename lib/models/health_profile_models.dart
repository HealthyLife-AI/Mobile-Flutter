import 'package:flutter/material.dart';

/// Mock models for the onboarding "البيانات الصحية" step. Mirrors the shape
/// a real POST /me/health-profile call would take: selected chronic
/// conditions, selected food-allergy groups and a free-form medications
/// list, each with a stable [id] so the backend can diff selections.

class HealthConditionOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  const HealthConditionOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class FoodAllergyOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  const FoodAllergyOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class MedicationEntry {
  final String name;
  final String frequency;
  const MedicationEntry({required this.name, required this.frequency});
}

class HealthProfileMockData {
  HealthProfileMockData._();

  static const List<HealthConditionOption> conditions = [
    HealthConditionOption(
      id: 'diabetes',
      title: 'السكري (النوع الأول / الثاني)',
      subtitle: 'مراقبة مؤشر السكر ومقاومة الإنسولين',
      icon: Icons.bloodtype_outlined,
    ),
    HealthConditionOption(
      id: 'hypertension',
      title: 'ارتفاع ضغط الدم',
      subtitle: 'تقليل الصوديوم وتوازن البوتاسيوم',
      icon: Icons.monitor_heart_outlined,
    ),
    HealthConditionOption(
      id: 'thyroid',
      title: 'خمول / نشاط الغدة الدرقية',
      subtitle: 'توازن معدلات الأيض ومصادر اليود',
      icon: Icons.favorite_border_rounded,
    ),
    HealthConditionOption(
      id: 'pcos',
      title: 'تكيس المبايض (PCOS)',
      subtitle: 'استقرار هرموني وخفض الالتهابات',
      icon: Icons.balance_rounded,
    ),
    HealthConditionOption(
      id: 'ibs',
      title: 'القولون العصبي (IBS)',
      subtitle: 'تجنب محفزات الفودماب (FODMAP)',
      icon: Icons.spa_outlined,
    ),
    HealthConditionOption(
      id: 'cholesterol',
      title: 'ارتفاع الكوليسترول أو الدهون الثلاثية',
      subtitle: 'التركيز على الدهون الصحية غير المشبعة',
      icon: Icons.show_chart_rounded,
    ),
    HealthConditionOption(
      id: 'none',
      title: 'لا توجد لدي أي أمراض مزمنة',
      subtitle: 'أتمتع بصحة جيدة وأبحث عن توازن وقائي',
      icon: Icons.shield_outlined,
    ),
  ];

  static const List<FoodAllergyOption> allergies = [
    FoodAllergyOption(
      id: 'lactose',
      title: 'حساسية اللاكتوز / مشتقات الحليب',
      subtitle: 'استبعاد ألبان الأبقار واللاكتوز الصريح والمخفي',
      icon: Icons.local_drink_outlined,
    ),
    FoodAllergyOption(
      id: 'gluten',
      title: 'حساسية القمح / الجلوتين (Celiac)',
      subtitle: 'استبدال كامل بمنتجات معتمدة خالية من الجلوتين',
      icon: Icons.grass_outlined,
    ),
    FoodAllergyOption(
      id: 'peanuts',
      title: 'حساسية الفول السوداني والمكسرات',
      subtitle: 'استبعاد زبدة المكسرات والزيوت العطرية المشتقة',
      icon: Icons.eco_outlined,
    ),
    FoodAllergyOption(
      id: 'seafood',
      title: 'حساسية البيض أو المأكولات البحرية',
      subtitle: 'تجنب زلال البيض والأسماك القشرية والمحاريات',
      icon: Icons.set_meal_outlined,
    ),
    FoodAllergyOption(
      id: 'none',
      title: 'لا توجد أي حساسية غذائية معروفة',
      subtitle: 'أستمتع بتناول كافة المجموعات الغذائية بأمان',
      icon: Icons.star_border_rounded,
    ),
  ];

  static const List<MedicationEntry> defaultMedications = [
    MedicationEntry(name: 'متفورمين (Metformin) 500mg', frequency: 'يومياً'),
    MedicationEntry(name: 'فيتامين د 5000IU', frequency: 'أسبوعياً'),
  ];
}
