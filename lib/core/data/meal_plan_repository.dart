import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/meal_plan_models.dart';

/// Returns the decoded body of `GET /me/meal-plan`.
typedef MealPlanFetcher = Future<Map<String, dynamic>> Function();

/// Keeps the last good `/me/meal-plan` body so the plan, and the
/// specialist's instructions with it, still show offline.
abstract class MealPlanCache {
  Future<String?> read();
  Future<void> write(String body);
  Future<void> clear();
}

class SharedPrefsMealPlanCache implements MealPlanCache {
  const SharedPrefsMealPlanCache();

  static const String _key = 'cache.me_meal_plan';

  @override
  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(_key);

  @override
  Future<void> write(String body) async => (await SharedPreferences.getInstance()).setString(_key, body);

  @override
  Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_key);
}

/// Holds the current meal plan: the cached copy first, then whatever the
/// latest fetch returned.
///
/// Errors are swallowed on purpose and never logged: both the cached body
/// and the response carry health data.
class MealPlanRepository extends ChangeNotifier {
  MealPlanRepository({required MealPlanFetcher fetch, required MealPlanCache cache})
      : _fetch = fetch,
        _cache = cache;

  /// Until the app has an API client, the fetcher returns the mock response
  /// below. Swap it for the real `GET /me/meal-plan` call; nothing else
  /// needs to change.
  static final MealPlanRepository instance = MealPlanRepository(
    fetch: () async => _mockMealPlanResponse,
    cache: const SharedPrefsMealPlanCache(),
  );

  final MealPlanFetcher _fetch;
  final MealPlanCache _cache;

  MealPlan? _plan;
  Future<void>? _cacheLoad;
  int _lastStarted = 0;
  int _lastApplied = 0;

  MealPlan? get plan => _plan;

  /// Reads the cached plan, once. A fetch that already landed wins over it.
  Future<void> loadCached() => _cacheLoad ??= _readCache();

  Future<void> _readCache() async {
    try {
      final body = await _cache.read();
      if (body == null || _lastApplied > 0) return;
      _plan = MealPlan.fromJson(jsonDecode(body) as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {
      // Missing or unreadable cache: nothing to show offline.
    }
  }

  /// Fetches the plan again. Called on pull-to-refresh and when the
  /// plan-updated push notification arrives.
  ///
  /// Returns false when the fetch failed; the plan on screen (cached or
  /// fetched earlier) stays as it was. If calls overlap, the response of the
  /// one started last is what stays on screen.
  Future<bool> refresh() async {
    final id = ++_lastStarted;
    final Map<String, dynamic> body;
    final MealPlan plan;
    try {
      body = await _fetch();
      plan = MealPlan.fromJson(body);
    } catch (_) {
      return false;
    }
    if (id < _lastApplied) return true;
    _lastApplied = id;
    _plan = plan;
    notifyListeners();
    try {
      await _cache.write(jsonEncode(body));
    } catch (_) {
      // The plan is on screen; it just won't survive a restart offline.
    }
    return true;
  }

  /// Drops the plan from memory and disk, e.g. on logout, so the next
  /// account on this device never sees it. Fetches still in flight are
  /// discarded when they land.
  Future<void> clear() async {
    _lastApplied = ++_lastStarted;
    _cacheLoad = null;
    _plan = null;
    notifyListeners();
    try {
      await _cache.clear();
    } catch (_) {}
  }
}

const Map<String, dynamic> _mockMealPlanResponse = {
  'patient_instructions': 'قلّل الصوديوم والأطعمة المصنّعة، وفضّل الأكل الطبيعي والطازج.\n'
      'قِس مستوى السكر قبل الوجبات وبعدها.\n'
      'حافظ على هدوئك وخصص وقتًا يوميًا لتمارين التنفس.\n'
      'مارس رياضة خفيفة بشكل منتظم، مثل المشي.',
};
