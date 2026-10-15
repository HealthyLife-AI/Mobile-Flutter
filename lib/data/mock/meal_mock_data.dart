import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/entities/recommendation_entity.dart';

/// Mock meal-plan data shaped like the real API responses. Served by the
/// mock data sources in `lib/data/datasources/` until a backend exists.

class MockData {
  static const List<Meal> todayMeals = [
    Meal(
      id: 'breakfast',
      name: 'الفطور',
      timeRange: '08:00 ص - 09:30 ص',
      calories: 320,
      status: MealStatus.logged,
      iconEmojiSlot: 'sun',
      alternativesText: 'زبادي يوناني قليل الدسم (150غ) مع كوب توت أزرق',
      items: [
        MealItem(
            name: 'شوفان عضوي بحبوب الشيا (60 غ)', grams: 60, checked: true),
        MealItem(
            name: 'حليب لوز غير محلى أو قليل الدسم (200 مل)',
            grams: 200,
            checked: true),
      ],
    ),
    Meal(
      id: 'snack',
      name: 'وجبة خفيفة (سناك)',
      timeRange: '11:30 ص - 12:00 م',
      calories: 160,
      status: MealStatus.logged,
      iconEmojiSlot: 'leaf',
      alternativesText: 'كمثرى متوسطة الحجم (140غ) مع 3 حبات جوز عين الجمل',
      items: [
        MealItem(
            name: 'تفاح أخضر شرائح طازجة (150 غ)', grams: 150, checked: true),
        MealItem(name: 'لوز نيء غير مملح (15 غ)', grams: 15, checked: true),
      ],
    ),
    Meal(
      id: 'lunch',
      name: 'الغداء',
      timeRange: '02:00 م - 03:30 م',
      calories: 540,
      status: MealStatus.current,
      iconEmojiSlot: 'sun_orange',
      alternativesText:
          'شريحة سلمون مشوي (140غ) بدلاً من الدجاج، أو بطاطا حلوة مشوية (150غ)',
      items: [
        MealItem(name: 'صدر دجاج مشوي متبل بالأعشاب', grams: 150),
        MealItem(name: 'أرز بسمتي بني مطهو على البخار', grams: 120),
        MealItem(name: 'سلطة خضراء غنية مع قطرات زيت زيتون', grams: 150),
      ],
    ),
    Meal(
      id: 'dinner',
      name: 'العشاء',
      timeRange: '08:30 م - 09:30 م',
      calories: 330,
      status: MealStatus.upcoming,
      iconEmojiSlot: 'moon',
      alternativesText: 'بيضتان مسلوقتان مع أعشاب، أو 3 ملاعق لبنة قليلة الدسم',
      items: [
        MealItem(name: 'جبنة قريش طازجة خفيفة الملح', grams: 150),
        MealItem(name: 'خضار مقطعة (خيار، طماطم كرزية، جرجير)', grams: 140),
        MealItem(name: 'شريحة خبز شوفان كامل الحبة', grams: 40),
      ],
    ),
  ];

  static const List<FoodCategoryGroup> lunchDetailGroups = [
    FoodCategoryGroup(
      title: 'المصدر البروتيني',
      options: [
        FoodOption(
            name: 'صدر دجاج مشوي متبل',
            grams: 150,
            calories: 240,
            macroLabel: '31غ بروتين',
            isOriginal: true,
            selected: true),
        FoodOption(
          name: 'شريحة سلمون مشوي طازج',
          grams: 130,
          calories: 250,
          macroLabel: '26غ بروتين',
        ),
      ],
    ),
    FoodCategoryGroup(
      title: 'النشويات المعقدة',
      options: [
        FoodOption(
            name: 'أرز بني مطبوخ على البخار',
            grams: 120,
            calories: 135,
            macroLabel: '28غ كارب',
            isOriginal: true,
            selected: true),
        FoodOption(
          name: 'بطاطا حلوة مشوية بالفرن',
          grams: 150,
          calories: 130,
          macroLabel: '29غ كارب',
        ),
      ],
    ),
    FoodCategoryGroup(
      title: 'الخضار والألياف',
      options: [
        FoodOption(
            name: 'سلطة خضراء بزيت الزيتون',
            grams: 150,
            calories: 85,
            macroLabel: '4غ ألياف',
            isOriginal: true,
            selected: true,
            locked: true),
      ],
    ),
  ];

  static const List<RecommendationItem> recommendedRecipes = [
    RecommendationItem(
        title: 'شوربة عدس دافئة',
        subtitle: '210 سعرة',
        icon: Icons.soup_kitchen_outlined,
        color: AppColors.accentOrange),
    RecommendationItem(
        title: 'سلطة الكينوا',
        subtitle: '180 سعرة',
        icon: Icons.eco_rounded,
        color: AppColors.accentGreen),
    RecommendationItem(
        title: 'سموذي التوت',
        subtitle: '150 سعرة',
        icon: Icons.local_drink_outlined,
        color: AppColors.accentPurple),
    RecommendationItem(
        title: 'توست الأفوكادو',
        subtitle: '240 سعرة',
        icon: Icons.breakfast_dining_outlined,
        color: AppColors.primary),
  ];
}
