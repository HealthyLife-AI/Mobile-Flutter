import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/data/datasources/meal_plan_data_source.dart';
import 'package:healthylife_ai/data/models/meal_plan_dto.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/domain/entities/meal_plan_entities.dart';

/// A plan shaped like `GET /me/meal-plan` (API guide 5.1), relative to [today]:
///
/// * breakfast, lunch and dinner every day (`day_index: null`);
/// * an afternoon snack only on [today]'s weekday;
/// * started two weeks before [today], so today is week 3.
///
/// Lunch's chicken has one alternative (fish fillet); its rice has one too.
Map<String, dynamic> samplePlanJson({DateTime? today}) {
  final day = today ?? DateTime.now();
  final start = DateTime(day.year, day.month, day.day - 14);
  String two(int n) => n.toString().padLeft(2, '0');
  Map<String, dynamic> food(int id, String ar, String en, double kcal,
          {double p = 0,
          double c = 0,
          double f = 0,
          String section = 'other'}) =>
      {
        'id': id,
        'name_en': en,
        'name_ar': ar,
        'source': 'admin',
        'status': 'approved',
        'calories_per_100g': kcal,
        'protein_g_per_100g': p,
        'carbs_g_per_100g': c,
        'fat_g_per_100g': f,
        'fiber_g_per_100g': null,
        'allergens': <String>[],
        'shopping_section': section,
      };
  Map<String, dynamic> macros(num kcal, num p, num c, num f) =>
      {'calories': kcal, 'protein_g': p, 'carbs_g': c, 'fat_g': f};

  return {
    'id': 8,
    'subscriber_id': 17,
    'is_template': false,
    'is_ai_draft': false,
    'name': null,
    'start_date': '${start.year}-${two(start.month)}-${two(start.day)}',
    'status': 'active',
    'activated_at': '2026-10-01T09:00:00+00:00',
    'meals': [
      {
        'id': 21,
        'name': 'breakfast',
        'day_index': null,
        'macros': macros(330, 20, 30, 12),
        'items': [
          {
            'id': 55,
            'food': food(3, 'بيض مسلوق', 'Boiled egg', 155,
                p: 13, f: 11, section: 'dairy_eggs'),
            'quantity_grams': 100,
            'macros': macros(155, 13, 1, 11),
            'alternatives': [
              {
                'id': 56,
                'food': food(4, 'جبنة قريش', 'Cottage cheese', 98,
                    p: 11, c: 3, f: 4, section: 'dairy_eggs'),
                'quantity_grams': 100,
                'macros': macros(98, 11, 3, 4),
                'alternatives': [],
              },
            ],
          },
          {
            'id': 57,
            'food': food(5, 'خبز شوفان', 'Oat bread', 290,
                p: 10, c: 50, f: 5, section: 'grains_starches'),
            'quantity_grams': 60,
            'macros': macros(175, 7, 29, 1),
            'alternatives': [],
          },
        ],
      },
      {
        'id': 22,
        'name': 'lunch',
        'day_index': null,
        'macros': macros(422, 50, 36, 7),
        'items': [
          {
            'id': 60,
            'food': food(6, 'صدر دجاج مشوي', 'Grilled chicken breast', 165,
                p: 31, f: 4, section: 'meat_poultry_fish'),
            'quantity_grams': 150,
            'macros': macros(248, 45, 0, 6),
            'alternatives': [
              {
                'id': 61,
                'food': food(7, 'سمك فيليه', 'Fish fillet', 120,
                    p: 24, f: 2, section: 'meat_poultry_fish'),
                'quantity_grams': 160,
                'macros': macros(192, 38, 0, 3),
                'alternatives': [],
              },
            ],
          },
          {
            'id': 62,
            'food': food(8, 'أرز بني', 'Brown rice', 112,
                p: 3, c: 23, f: 1, section: 'grains_starches'),
            'quantity_grams': 120,
            'macros': macros(134, 3, 28, 1),
            'alternatives': [
              {
                'id': 63,
                'food': food(9, 'بطاطا حلوة', 'Sweet potato', 86,
                    p: 2, c: 20, section: 'produce'),
                'quantity_grams': 150,
                'macros': macros(129, 2, 30, 0),
                'alternatives': [],
              },
            ],
          },
          {
            'id': 64,
            'food': food(10, 'سلطة خضراء', 'Green salad', 20,
                c: 4, section: 'produce'),
            'quantity_grams': 200,
            'macros': macros(40, 2, 8, 0),
            'alternatives': [],
          },
        ],
      },
      {
        'id': 23,
        'name': 'dinner',
        'day_index': null,
        'macros': macros(146, 14, 6, 8),
        'items': [
          {
            'id': 70,
            'food': food(11, 'زبادي يوناني', 'Greek yogurt', 97,
                p: 9, c: 4, f: 5, section: 'dairy_eggs'),
            'quantity_grams': 150,
            'macros': macros(146, 14, 6, 8),
            'alternatives': [],
          },
        ],
      },
      {
        'id': 24,
        'name': 'snack',
        'day_index': day.weekday - 1,
        'macros': macros(95, 1, 25, 0),
        'items': [
          {
            'id': 80,
            'food': food(12, 'تفاحة', 'Apple', 52, c: 14, section: 'produce'),
            'quantity_grams': 180,
            'macros': macros(95, 1, 25, 0),
            'alternatives': [],
          },
        ],
      },
    ],
    'summary_by_day': {
      '${day.weekday - 1}': macros(993, 85, 97, 27),
    },
    'created_at': '2026-10-01T09:00:00+00:00',
    'updated_at': '2026-10-01T09:00:00+00:00',
  };
}

MealPlan samplePlan({DateTime? today}) =>
    MealPlanDto.fromJson(samplePlanJson(today: today))!;

/// Lunch from [samplePlan] as the screens show it (no meal times in the API).
Meal sampleLunch() {
  final lunch = samplePlan().meals.firstWhere((m) => m.id == 22);
  return Meal(
    id: '${lunch.id}',
    name: 'الغداء',
    timeRange: '',
    calories: lunch.macros.calories.round(),
    items: [
      for (final i in lunch.items)
        MealItem(name: i.food.name, grams: i.quantityGrams),
    ],
    alternativesText: '',
    status: MealStatus.current,
    iconEmojiSlot: 'sun_orange',
    source: lunch,
  );
}

/// `GET /me/meal-plan` in tests: answers [plan] (null = 204, no active plan),
/// or throws [error] when one is set. Counts the calls.
class FakeMealPlanSource implements MealPlanRemoteDataSource {
  FakeMealPlanSource([this.plan]);

  /// What the next read answers. Null means `204`.
  Map<String, dynamic>? plan;

  /// Thrown by the next read instead of answering, when set.
  AppException? error;
  int calls = 0;

  @override
  Future<Map<String, dynamic>?> fetchActivePlan() async {
    calls++;
    final failure = error;
    if (failure != null) throw failure;
    return plan;
  }
}
