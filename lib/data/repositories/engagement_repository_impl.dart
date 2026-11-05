import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/engagement_entities.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../models/json_read.dart';
import 'cached_response.dart';

/// `GET /me/checkins/current` and `POST /me/checkins/{id}`, plus the draft
/// answers kept on the device until the check-in is sent.
class CheckinRepositoryImpl implements CheckinRepository, PatientCache {
  CheckinRepositoryImpl(this._api, this._storage);

  static const String _draftKey = 'checkin_draft.v1';

  final ApiClient _api;
  final StorageService _storage;

  @override
  Future<Result<Checkin?>> getCurrent() => guard(
        () async => parseCheckin(await _api.get('me/checkins/current')),
        context: 'CheckinRepository.getCurrent',
      );

  @override
  Future<Result<void>> submit(int checkinId, CheckinAnswers answers) => guard(
        () async {
          await _api.post('me/checkins/$checkinId', body: {'answers': answers});
          await clearDraft();
        },
        context: 'CheckinRepository.submit',
      );

  /// A check-in needs an id and at least one question it can show.
  static Checkin? parseCheckin(Object? raw) {
    final json = jsonMap(unwrapData(raw));
    final id = json == null ? null : jsonInt(json['id']);
    if (json == null || id == null) return null;
    final questions = <CheckinQuestion>[];
    for (final q in jsonMaps(json['questions'])) {
      final key = jsonText(q['key']);
      final label = jsonText(q['label']);
      if (key == null || label == null) continue;
      final type = switch (q['type']) {
        'single' => CheckinQuestionType.single,
        'multi' => CheckinQuestionType.multi,
        'text' => CheckinQuestionType.text,
        _ => CheckinQuestionType.unknown,
      };
      final options = [
        for (final o in jsonMaps(q['options']))
          if ((jsonText(o['value']), jsonText(o['label']))
              case (final value?, final optionLabel?))
            CheckinOption(value: value, label: optionLabel),
      ];
      // A choice question without options cannot be answered.
      if (type == CheckinQuestionType.unknown ||
          (type != CheckinQuestionType.text && options.isEmpty)) {
        continue;
      }
      questions.add(CheckinQuestion(
        key: key,
        type: type,
        label: label,
        options: options,
        max: jsonInt(q['max']),
      ));
    }
    if (questions.isEmpty) return null;
    return Checkin(
        id: id, dueOn: jsonDate(json['due_on']), questions: questions);
  }

  @override
  Future<CheckinDraft?> readDraft(int checkinId) async {
    try {
      final raw = await _storage.readMap(_draftKey);
      if (raw == null || jsonInt(raw['checkin_id']) != checkinId) return null;
      final answers = <String, Object>{};
      final saved = jsonMap(raw['answers']) ?? const {};
      saved.forEach((key, value) {
        if (value is String) answers[key] = value;
        if (value is List) answers[key] = value.whereType<String>().toList();
      });
      return CheckinDraft(
          checkinId: checkinId,
          step: jsonInt(raw['step']) ?? 0,
          answers: answers);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveDraft(CheckinDraft draft) async {
    try {
      await _storage.writeMap(_draftKey, {
        'checkin_id': draft.checkinId,
        'step': draft.step,
        'answers': draft.answers,
      });
    } on Object {
      // Losing a draft only means answering again.
    }
  }

  @override
  Future<void> clearDraft() async {
    try {
      await _storage.remove(_draftKey);
    } on Object {
      // Nothing to clear.
    }
  }

  @override
  Future<void> forgetPatientData() => clearDraft();
}

/// `GET` / `PUT /me/food-preferences`.
class FoodPreferencesRepositoryImpl
    implements FoodPreferencesRepository, PatientCache {
  FoodPreferencesRepositoryImpl(this._api, this._cache);

  final ApiClient _api;
  final CachedResponse _cache;

  @override
  Future<Result<FoodPreferences>> get() => guard(
        () => _cache.read(() => _api.get('me/food-preferences'), parse),
        context: 'FoodPreferencesRepository.get',
      );

  @override
  Future<Result<FoodPreferences>> save(
          {required List<int> likes, required List<int> dislikes}) =>
      guard(
        () async {
          final raw = await _api.put('me/food-preferences',
              body: {'likes': likes, 'dislikes': dislikes});
          final body = jsonMap(unwrapData(raw));
          // The answer is the new state when it has the lists; otherwise the
          // state is read again.
          if (body != null && body.containsKey('likes')) {
            await _cache.replace(raw);
            return parse(raw);
          }
          return _cache.read(() => _api.get('me/food-preferences'), parse);
        },
        context: 'FoodPreferencesRepository.save',
      );

  static FoodPreferences parse(Object? raw) {
    final json = jsonMap(unwrapData(raw)) ?? const <String, dynamic>{};
    List<FoodPreference> list(Object? value) => [
          for (final f in jsonMaps(value))
            if (jsonInt(f['food_id'] ?? f['id']) case final id?)
              FoodPreference(
                foodId: id,
                nameAr: jsonText(f['name_ar']) ??
                    jsonText(f['name']) ??
                    jsonText(f['name_en']) ??
                    '#$id',
                nameEn: jsonText(f['name_en']),
                source: f['source'] == 'nutritionist'
                    ? FoodPreferenceSource.nutritionist
                    : FoodPreferenceSource.patient,
              ),
        ];
    return FoodPreferences(
        likes: list(json['likes']), dislikes: list(json['dislikes']));
  }

  @override
  Future<void> forgetPatientData() => _cache.forgetPatientData();
}

/// `GET /me/goal-projection` and `GET /me/weight-insight`.
class InsightsRepositoryImpl implements InsightsRepository, PatientCache {
  InsightsRepositoryImpl(this._api, this._projection, this._insight);

  final ApiClient _api;
  final CachedResponse _projection;
  final CachedResponse _insight;

  @override
  Future<Result<GoalProjection?>> getGoalProjection() => guard(
        () => _projection.read(
            () => _api.get('me/goal-projection'), parseProjection),
        context: 'InsightsRepository.getGoalProjection',
      );

  @override
  Future<Result<WeightInsight?>> getWeightInsight() => guard(
        () => _insight.read(() => _api.get('me/weight-insight'), parseInsight),
        context: 'InsightsRepository.getWeightInsight',
      );

  static GoalProjection? parseProjection(Object? raw) {
    final json = jsonMap(unwrapData(raw));
    if (json == null) return null;
    final remaining = jsonDouble(json['remaining_kg']);
    if (remaining == null) return null;
    ProjectionLevel? level(Object? value) => switch (value) {
          'high' => ProjectionLevel.high,
          'medium' => ProjectionLevel.medium,
          'low' => ProjectionLevel.low,
          _ => null,
        };
    final scenarios = <ProjectionScenario>[
      for (final s in jsonMaps(json['scenarios']))
        if (level(s['level']) case final l?)
          ProjectionScenario(
            level: l,
            weeks: jsonInt(s['weeks']),
            estimatedDate: jsonDate(s['estimated_date']),
            reachable: jsonBool(s['reachable']) ?? true,
          ),
    ]..sort((a, b) => a.level.index.compareTo(b.level.index));
    if (scenarios.isEmpty) return null;
    return GoalProjection(
      remainingKg: remaining.abs(),
      direction: json['direction'] == 'gain'
          ? WeightDirection.gain
          : WeightDirection.loss,
      scenarios: scenarios,
      currentLevel: level(json['current_level']),
      disclaimer: jsonText(json['disclaimer_ar']) ?? '',
    );
  }

  static WeightInsight? parseInsight(Object? raw) {
    final json = jsonMap(unwrapData(raw));
    final text = json == null ? null : jsonBody(json['text_ar']);
    if (json == null || text == null) return null;
    return WeightInsight(
      text: text,
      changeKg: jsonDouble(json['change_kg']),
      fromDate: jsonDate(json['from_date']),
      toDate: jsonDate(json['to_date']),
    );
  }

  @override
  Future<void> forgetPatientData() async {
    await _projection.forgetPatientData();
    await _insight.forgetPatientData();
  }
}

/// `GET /me/today`.
class TodayRepositoryImpl implements TodayRepository, PatientCache {
  TodayRepositoryImpl(this._api, this._cache);

  final ApiClient _api;
  final CachedResponse _cache;

  @override
  Future<Result<TodaySummary>> getToday() => guard(
        () => _cache.read(() => _api.get('me/today'), parse),
        context: 'TodayRepository.getToday',
      );

  static TodaySummary parse(Object? raw) {
    final json = jsonMap(unwrapData(raw)) ?? const <String, dynamic>{};
    final now = DateTime.now();
    return TodaySummary(
      date: jsonDate(json['date']) ?? DateTime(now.year, now.month, now.day),
      meals: [
        for (final m in jsonMaps(json['meals']))
          if (jsonText(m['name_ar']) ?? jsonText(m['name']) case final name?)
            TodayMeal(name: name, window: jsonText(m['window'])),
      ],
      activities: [
        for (final a in jsonMaps(json['activities']))
          if (jsonText(a['title']) case final title?)
            TodayActivity(
              title: title,
              durationMinutes: jsonInt(a['duration_minutes']),
              timesPerDay: jsonInt(a['times_per_day']),
            ),
      ],
      reminders: [
        for (final r in jsonMaps(json['reminders']))
          if (jsonText(r['text_ar']) case final text?)
            TodayReminder(type: reminderType(r['type']), text: text),
      ],
      motivation: jsonText(json['motivation_ar']),
    );
  }

  static TodayReminderType reminderType(Object? value) => switch (value) {
        'measurement' => TodayReminderType.measurement,
        'checkin' => TodayReminderType.checkin,
        'quick_request' => TodayReminderType.quickRequest,
        'appointment' => TodayReminderType.appointment,
        'posts' => TodayReminderType.posts,
        'wellbeing' => TodayReminderType.wellbeing,
        _ => TodayReminderType.unknown,
      };

  @override
  Future<void> forgetPatientData() => _cache.forgetPatientData();
}

/// `/me/posts`. The first page is kept for offline reading.
class PostsRepositoryImpl implements PostsRepository, PatientCache {
  PostsRepositoryImpl(this._api, this._firstPage);

  final ApiClient _api;
  final CachedResponse _firstPage;

  @override
  Future<Result<PostsPage>> getPage(int page) => guard(
        () {
          Future<Object?> fetch() =>
              _api.get('me/posts', query: {'page': page});
          return page == 1 ? _firstPage.read(fetch, parsePage) : _fetch(fetch);
        },
        context: 'PostsRepository.getPage',
      );

  Future<PostsPage> _fetch(Future<Object?> Function() fetch) async =>
      parsePage(await fetch());

  @override
  Future<Result<Post>> getPost(int id) => guard(
        () async {
          final post =
              parsePost(jsonMap(unwrapData(await _api.get('me/posts/$id'))));
          if (post == null) throw const NotFoundException('No such post');
          return post;
        },
        context: 'PostsRepository.getPost',
      );

  @override
  Future<Result<void>> markRead(int id) => guard(
        () async {
          await _api.post('me/posts/$id/read');
        },
        context: 'PostsRepository.markRead',
      );

  @override
  Future<Result<int>> unreadCount() => guard(
        () async {
          final json =
              jsonMap(unwrapData(await _api.get('me/posts/unread-count')));
          return (jsonInt(json?['unread']) ?? 0).clamp(0, 9999);
        },
        context: 'PostsRepository.unreadCount',
      );

  static PostsPage parsePage(Object? raw) {
    final json = jsonMap(raw);
    final list = json == null ? raw : json['data'];
    final meta = jsonMap(json?['meta']);
    final page = jsonInt(meta?['current_page']) ?? 1;
    return PostsPage(
      posts: [
        for (final p in jsonMaps(list))
          if (parsePost(p) case final post?) post,
      ],
      page: page,
      lastPage: jsonInt(meta?['last_page']) ?? page,
    );
  }

  static Post? parsePost(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = jsonInt(json['id']);
    final title = jsonText(json['title']);
    if (id == null || title == null) return null;
    return Post(
      id: id,
      title: title,
      body: json['body'] is String ? json['body'] as String : '',
      publishedAt: jsonDateTime(json['published_at']),
      pinned: jsonBool(json['pinned']) ?? false,
      isRead: jsonBool(json['is_read']) ?? false,
    );
  }

  @override
  Future<void> forgetPatientData() => _firstPage.forgetPatientData();
}
