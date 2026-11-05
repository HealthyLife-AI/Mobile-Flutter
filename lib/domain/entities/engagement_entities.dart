/// Phases 2 and 3 of the patient-app spec: the periodic check-in, food likes
/// and dislikes, the goal projection, the "today" summary, the
/// nutritionist's posts (advice) and the weight insight.
///
/// Pure Dart: no Flutter imports, no wire format.
library;

// ── Check-in (`/me/checkins/current`) ──────────────────────────────────────

enum CheckinQuestionType { single, multi, text, unknown }

class CheckinOption {
  const CheckinOption({required this.value, required this.label});

  final String value;
  final String label;

  /// "ولا شي": exclusive in a multi-choice question.
  bool get isNone => value == 'none';
}

/// One question, rendered from the API: the app hardcodes no question text.
class CheckinQuestion {
  const CheckinQuestion({
    required this.key,
    required this.type,
    required this.label,
    this.options = const [],
    this.max,
  });

  final String key;
  final CheckinQuestionType type;
  final String label;
  final List<CheckinOption> options;

  /// Most choices for [CheckinQuestionType.multi], most characters for
  /// [CheckinQuestionType.text].
  final int? max;

  bool get isText => type == CheckinQuestionType.text;
}

class Checkin {
  const Checkin({required this.id, required this.questions, this.dueOn});

  final int id;
  final DateTime? dueOn;
  final List<CheckinQuestion> questions;
}

/// The answers so far: a `String` for single and text questions, a
/// `List<String>` for multi.
typedef CheckinAnswers = Map<String, Object>;

/// Answers kept on the device while the patient fills a check-in, so leaving
/// and coming back resumes where they were. Only for the same check-in.
class CheckinDraft {
  const CheckinDraft(
      {required this.checkinId, required this.step, required this.answers});

  final int checkinId;
  final int step;
  final CheckinAnswers answers;
}

/// Applies a tap on [value] in a multi-choice question, following the spec:
/// "none" is exclusive (choosing it clears the rest, choosing anything else
/// clears it), and a choice past [max] is refused (null is returned).
List<String>? toggleMultiChoice(List<String> current, String value,
    {required int? max}) {
  if (current.contains(value)) {
    return [...current]..remove(value);
  }
  if (value == 'none') return ['none'];
  final next = [...current]..remove('none');
  if (max != null && next.length >= max) return null;
  return next..add(value);
}

// ── Food likes and dislikes (`/me/food-preferences`) ───────────────────────

enum FoodPreferenceSource { patient, nutritionist }

class FoodPreference {
  const FoodPreference({
    required this.foodId,
    required this.nameAr,
    this.nameEn,
    this.source = FoodPreferenceSource.patient,
  });

  final int foodId;
  final String nameAr;
  final String? nameEn;

  /// The nutritionist's entries show a badge and cannot be removed.
  final FoodPreferenceSource source;

  bool get byNutritionist => source == FoodPreferenceSource.nutritionist;
}

class FoodPreferences {
  const FoodPreferences({this.likes = const [], this.dislikes = const []});

  /// Most entries per list.
  static const int maxPerList = 30;

  final List<FoodPreference> likes;
  final List<FoodPreference> dislikes;

  bool contains(int foodId) =>
      likes.any((f) => f.foodId == foodId) ||
      dislikes.any((f) => f.foodId == foodId);
}

// ── Goal projection (`/me/goal-projection`) ────────────────────────────────

enum ProjectionLevel { high, medium, low }

enum WeightDirection { loss, gain }

class ProjectionScenario {
  const ProjectionScenario({
    required this.level,
    required this.reachable,
    this.weeks,
    this.estimatedDate,
  });

  final ProjectionLevel level;
  final bool reachable;
  final int? weeks;
  final DateTime? estimatedDate;
}

class GoalProjection {
  const GoalProjection({
    required this.remainingKg,
    required this.direction,
    required this.scenarios,
    required this.disclaimer,
    this.currentLevel,
  });

  final double remainingKg;
  final WeightDirection direction;

  /// High, medium, low, in that order.
  final List<ProjectionScenario> scenarios;

  /// Null: no row is highlighted.
  final ProjectionLevel? currentLevel;

  /// `disclaimer_ar`, always shown.
  final String disclaimer;
}

// ── Today (`/me/today`) ────────────────────────────────────────────────────

class TodayMeal {
  const TodayMeal({required this.name, this.window});

  final String name;

  /// e.g. "الصبح".
  final String? window;
}

class TodayActivity {
  const TodayActivity(
      {required this.title, this.durationMinutes, this.timesPerDay});

  final String title;
  final int? durationMinutes;
  final int? timesPerDay;
}

/// Each reminder type opens one screen.
enum TodayReminderType {
  measurement,
  checkin,
  quickRequest,
  appointment,
  posts,
  wellbeing,
  unknown,
}

class TodayReminder {
  const TodayReminder({required this.type, required this.text});

  final TodayReminderType type;
  final String text;
}

/// No calorie numbers anywhere on this card (spec).
class TodaySummary {
  const TodaySummary({
    required this.date,
    this.meals = const [],
    this.activities = const [],
    this.reminders = const [],
    this.motivation,
  });

  final DateTime date;
  final List<TodayMeal> meals;
  final List<TodayActivity> activities;
  final List<TodayReminder> reminders;
  final String? motivation;

  bool hasReminder(TodayReminderType type) =>
      reminders.any((r) => r.type == type);
}

// ── Posts: "نصائح أخصائيتك" (`/me/posts`) ───────────────────────────────────

class Post {
  const Post({
    required this.id,
    required this.title,
    required this.body,
    this.publishedAt,
    this.pinned = false,
    this.isRead = false,
  });

  final int id;
  final String title;

  /// Plain text, blank lines kept. Never rendered as HTML or links.
  final String body;
  final DateTime? publishedAt;
  final bool pinned;
  final bool isRead;

  Post markedRead() => Post(
      id: id,
      title: title,
      body: body,
      publishedAt: publishedAt,
      pinned: pinned,
      isRead: true);
}

class PostsPage {
  const PostsPage(
      {required this.posts, required this.page, required this.lastPage});

  final List<Post> posts;
  final int page;
  final int lastPage;

  bool get hasMore => page < lastPage;
}

// ── Weight insight (`/me/weight-insight`) ──────────────────────────────────

class WeightInsight {
  const WeightInsight({
    required this.text,
    this.changeKg,
    this.fromDate,
    this.toDate,
  });

  /// `text_ar`, shown exactly as sent.
  final String text;
  final double? changeKg;
  final DateTime? fromDate;
  final DateTime? toDate;
}
