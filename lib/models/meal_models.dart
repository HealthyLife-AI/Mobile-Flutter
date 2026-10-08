import 'package:flutter/material.dart';
import '../widgets/horizontal_recommendation_card.dart';
import '../core/theme/app_colors.dart';

/// Mock data models mirroring the /me/meal-plan API shape
/// (see the "Mobile API Reference" doc, section 3.1).

class MealItem {
  final String name;
  final int grams;
  final bool checked;
  const MealItem({required this.name, required this.grams, this.checked = false});
}

class Meal {
  final String id;
  final String name;
  final String timeRange;
  final int calories;
  final List<MealItem> items;
  final String alternativesText;
  final MealStatus status;
  final String iconEmojiSlot;

  const Meal({
    required this.id,
    required this.name,
    required this.timeRange,
    required this.calories,
    required this.items,
    required this.alternativesText,
    required this.status,
    required this.iconEmojiSlot,
  });
}

enum MealStatus { logged, current, upcoming }

class MealLogEntry {
  final String id;
  final String name;
  final int calories;
  final int grams;
  final DateTime loggedAt;
  final bool isOffPlan;
  final Meal? plannedMeal;

  const MealLogEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.grams,
    required this.loggedAt,
    required this.isOffPlan,
    this.plannedMeal,
  });
}

class MealLogStore extends ChangeNotifier {
  MealLogStore._();

  static final MealLogStore instance = MealLogStore._();
  final List<MealLogEntry> _entries = [];

  List<MealLogEntry> get entries => List.unmodifiable(_entries);

  MealLogEntry recordPlanned(Meal meal) {
    for (final entry in _entries) {
      if (entry.plannedMeal?.id == meal.id) return entry;
    }
    final entry = MealLogEntry(
      id: 'planned-${meal.id}',
      name: meal.name,
      calories: meal.calories,
      grams: meal.items.fold(0, (total, item) => total + item.grams),
      loggedAt: DateTime.now(),
      isOffPlan: false,
      plannedMeal: meal,
    );
    _entries.add(entry);
    notifyListeners();
    return entry;
  }

  MealLogEntry recordFood(SearchableFood food, int grams) {
    final entry = MealLogEntry(
      id: 'food-${DateTime.now().microsecondsSinceEpoch}',
      name: food.name,
      calories: (food.caloriesPer100g * grams / 100).round(),
      grams: grams,
      loggedAt: DateTime.now(),
      isOffPlan: true,
    );
    _entries.add(entry);
    notifyListeners();
    return entry;
  }
}

class FoodOption {
  final String name;
  final int grams;
  final int calories;
  final String macroLabel;
  final bool isOriginal;
  final bool selected;
  final bool locked;

  const FoodOption({
    required this.name,
    required this.grams,
    required this.calories,
    required this.macroLabel,
    this.isOriginal = false,
    this.selected = false,
    this.locked = false,
  });
}

class FoodCategoryGroup {
  final String title;
  final List<FoodOption> options;
  const FoodCategoryGroup({required this.title, required this.options});
}

class SearchableFood {
  final String name;
  final int caloriesPer100g;
  final String macro;
  // FoodTagColorMapper (2.3) key: redFruit | greenFruit | naturalSugar |
  // dairy | cookedProtein | carb | nuts — a category system, NOT the
  // literal food name, and deliberately separate from mealType colors.
  final String category;
  const SearchableFood({required this.name, required this.caloriesPer100g, required this.macro, this.category = 'default'});
}

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
        MealItem(name: 'شوفان عضوي بحبوب الشيا (60 غ)', grams: 60, checked: true),
        MealItem(name: 'حليب لوز غير محلى أو قليل الدسم (200 مل)', grams: 200, checked: true),
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
        MealItem(name: 'تفاح أخضر شرائح طازجة (150 غ)', grams: 150, checked: true),
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
      alternativesText: 'شريحة سلمون مشوي (140غ) بدلاً من الدجاج، أو بطاطا حلوة مشوية (150غ)',
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

  static const List<SearchableFood> foodSearchResults = [
    SearchableFood(name: 'تفاح أحمر طازج', caloriesPer100g: 52, macro: 'default', category: 'redFruit'),
    SearchableFood(name: 'موز طازج', caloriesPer100g: 89, macro: 'fiber', category: 'greenFruit'),
    SearchableFood(name: 'تمر سكري', caloriesPer100g: 277, macro: 'carbs', category: 'naturalSugar'),
    SearchableFood(name: 'لبن زبادي يوناني 5%', caloriesPer100g: 59, macro: 'protein', category: 'dairy'),
    SearchableFood(name: 'صدر دجاج مقلي', caloriesPer100g: 230, macro: 'default', category: 'cookedProtein'),
    SearchableFood(name: 'أرز أبيض مطبوخ', caloriesPer100g: 130, macro: 'carbs', category: 'carb'),
    SearchableFood(name: 'مكسرات مشكلة نيئة', caloriesPer100g: 607, macro: 'fat', category: 'nuts'),
  ];

  static const List<RecommendationItem> recommendedRecipes = [
    RecommendationItem(title: 'شوربة عدس دافئة', subtitle: '210 سعرة', icon: Icons.soup_kitchen_outlined, color: AppColors.accentOrange),
    RecommendationItem(title: 'سلطة الكينوا', subtitle: '180 سعرة', icon: Icons.eco_rounded, color: AppColors.accentGreen),
    RecommendationItem(title: 'سموذي التوت', subtitle: '150 سعرة', icon: Icons.local_drink_outlined, color: AppColors.accentPurple),
    RecommendationItem(title: 'توست الأفوكادو', subtitle: '240 سعرة', icon: Icons.breakfast_dining_outlined, color: AppColors.primary),
  ];
}
