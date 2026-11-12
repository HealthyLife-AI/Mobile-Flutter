import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/engagement_entities.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../l10n/l10n.dart';
import '../bloc/meal_plan/meal_plan_cubit.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/load_error_view.dart';
import '../widgets/spec_ui.dart';
import '../widgets/state_views.dart';

/// "أكلاتي" — `GET` / `PUT /me/food-preferences`.
///
/// Up to 30 foods the patient likes and 30 they don't, from the same food
/// search as meal logging. The nutritionist's entries carry "من أخصائيتك"
/// and no remove button; saving replaces only the patient's own entries.
class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  late final AppDependencies _deps = context.read<AppDependencies>();
  late final FoodPreferencesRepository _repository = _deps.foodPreferences;
  final TextEditingController _query = TextEditingController();
  Timer? _debounce;

  bool _loading = true;
  Failure? _loadFailure;
  List<FoodPreference> _likes = [];
  List<FoodPreference> _dislikes = [];
  bool _dirty = false;
  bool _saving = false;
  String? _error;

  List<SearchableFood> _results = const [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailure = null;
    });
    final result = await _repository.get();
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.when(
        success: (prefs) {
          _likes = [...prefs.likes];
          _dislikes = [...prefs.dislikes];
        },
        failure: (failure) => _loadFailure = failure,
      );
    });
  }

  void _onQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String value) async {
    if (value.trim().length < 2) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _searching = true);
    final result = await _deps.searchFoods(value);
    if (!mounted || _query.text != value) return;
    setState(() {
      _searching = false;
      _results = [
        for (final food in result.valueOrNull ?? const <SearchableFood>[])
          if (food.id != null) food,
      ];
    });
  }

  bool _has(int id) =>
      _likes.any((f) => f.foodId == id) || _dislikes.any((f) => f.foodId == id);

  /// Asks "بحبها / ما بحبها" for [food] and adds it to that list.
  Future<void> _ask(int id, String name) async {
    final l10n = context.l10n;
    if (_has(id)) {
      showSpecSnack(context, l10n.foodPrefsAlreadyAdded);
      return;
    }
    final like = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name,
                  textAlign: TextAlign.center, style: AppTextStyles.cardTitle),
              const SizedBox(height: 14),
              ChoiceTile(
                label: l10n.foodPrefsLike,
                icon: Icons.favorite_border_rounded,
                selected: false,
                onTap: () => Navigator.of(sheet).pop(true),
              ),
              const SizedBox(height: 10),
              ChoiceTile(
                label: l10n.foodPrefsDislike,
                icon: Icons.thumb_down_alt_outlined,
                selected: false,
                onTap: () => Navigator.of(sheet).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (like == null || !mounted) return;
    final list = like ? _likes : _dislikes;
    if (list.length >= FoodPreferences.maxPerList) {
      showSpecSnack(
          context,
          l10n.foodPrefsListFull(
              context.localizeDigits(FoodPreferences.maxPerList)),
          error: true);
      return;
    }
    setState(() {
      list.add(FoodPreference(foodId: id, nameAr: name));
      _dirty = true;
      _error = null;
      _query.clear();
      _results = const [];
    });
  }

  void _remove(FoodPreference food) => setState(() {
        _likes.removeWhere((f) => f.foodId == food.foodId && !f.byNutritionist);
        _dislikes
            .removeWhere((f) => f.foodId == food.foodId && !f.byNutritionist);
        _dirty = true;
      });

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    List<int> own(List<FoodPreference> list) => [
          for (final f in list)
            if (!f.byNutritionist) f.foodId
        ];
    final result =
        await _repository.save(likes: own(_likes), dislikes: own(_dislikes));
    if (!mounted) return;
    final l10n = context.l10n;
    setState(() {
      _saving = false;
      result.when(
        success: (prefs) {
          _likes = [...prefs.likes];
          _dislikes = [...prefs.dislikes];
          _dirty = false;
          showSpecSnack(context, l10n.commonSaved);
        },
        failure: (failure) => _error = switch (failure) {
          NetworkFailure() => l10n.commonOfflineBody,
          ApiFailure(:final fieldErrors) when fieldErrors.isNotEmpty =>
            fieldErrors.values.first,
          _ => l10n.commonErrorBody,
        },
      );
    });
  }

  /// Foods from the patient's plan they have not sorted yet.
  List<SearchableFood> _suggestions() {
    final plan = context.watch<MealPlanCubit>().state.dataOrNull;
    if (plan == null) return const [];
    final seen = <int>{};
    final foods = <SearchableFood>[];
    for (final meal in plan.meals) {
      for (final item in meal.items) {
        final id = item.food.id;
        if (id != null && !_has(id) && seen.add(id)) foods.add(item.food);
      }
    }
    return foods.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Widget body;
    if (_loading) {
      body = const ListSkeleton();
    } else if (_loadFailure != null) {
      body = LoadErrorView(
          failure: _loadFailure, onRetry: _load);
    } else {
      final suggestions = _suggestions();
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          SpecCard(
            color: AppColors.primaryTint,
            child: SpecCardHeader(
              icon: Icons.info_outline_rounded,
              title: l10n.foodPrefsNotAllergy,
              subtitle: l10n.foodPrefsNotAllergyBody,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _query,
            onChanged: _onQuery,
            textInputAction: TextInputAction.search,
            decoration: specInputDecoration(l10n.foodPrefsSearchHint).copyWith(
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.textMuted),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
          ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 8),
            SpecCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final food in _results.take(8))
                    ListTile(
                      dense: true,
                      title: Text(food.name, style: AppTextStyles.body),
                      trailing: Icon(
                          _has(food.id!)
                              ? Icons.check_rounded
                              : Icons.add_circle_outline_rounded,
                          color: AppColors.primary),
                      onTap: () => _ask(food.id!, food.name),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          _ListCard(
            title: l10n.foodPrefsLikes,
            icon: Icons.favorite_rounded,
            iconColor: AppColors.success,
            tone: PillTone.success,
            foods: _likes,
            liked: true,
            onRemove: _remove,
          ),
          const SizedBox(height: 14),
          _ListCard(
            title: l10n.foodPrefsDislikes,
            icon: Icons.thumb_down_alt_rounded,
            iconColor: AppColors.textMuted,
            tone: PillTone.neutral,
            foods: _dislikes,
            liked: false,
            onRemove: _remove,
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.foodPrefsSuggestions, style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final food in suggestions)
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded,
                        size: 16, color: AppColors.primary),
                    label: Text(food.name),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    shape: const StadiumBorder(),
                    onPressed: () => _ask(food.id!, food.name),
                  ),
              ],
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!,
                style:
                    AppTextStyles.secondary.copyWith(color: AppColors.danger)),
          ],
          const SizedBox(height: 20),
          SpecPrimaryButton(
            label: l10n.commonSave,
            loading: _saving,
            onPressed: _dirty ? _save : null,
          ),
        ],
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.foodPrefsTitle),
      body: SafeArea(child: body),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.tone,
    required this.foods,
    required this.liked,
    required this.onRemove,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final PillTone tone;
  final List<FoodPreference> foods;
  final bool liked;
  final void Function(FoodPreference) onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SpecCard(
      child: SpecColumn(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTextStyles.cardTitle)),
              StatusPill(
                  l10n.foodPrefsCount(context.localizeDigits(foods.length),
                      context.localizeDigits(FoodPreferences.maxPerList)),
                  tone: tone),
            ],
          ),
          if (foods.isEmpty)
            Text(l10n.foodPrefsEmpty,
                style: AppTextStyles.secondary
                    .copyWith(color: AppColors.textMuted))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final food in foods) _FoodChip(food, liked, onRemove)
              ],
            ),
        ],
      ),
    );
  }
}

class _FoodChip extends StatelessWidget {
  const _FoodChip(this.food, this.liked, this.onRemove);

  final FoodPreference food;
  final bool liked;
  final void Function(FoodPreference) onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fg = liked ? AppColors.success : AppColors.textSecondary;
    final bg = liked ? AppColors.successBg : AppColors.chipInactiveBg;
    final name =
        !context.isArabic && food.nameEn != null ? food.nameEn! : food.nameAr;
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: EdgeInsetsDirectional.fromSTEB(
          12, 4, food.byNutritionist ? 12 : 4, 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(name,
                style: AppTextStyles.secondary
                    .copyWith(color: fg, fontWeight: FontWeight.w600)),
          ),
          if (food.byNutritionist) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text(l10n.foodPrefsFromNutritionist,
                  style:
                      AppTextStyles.tiny.copyWith(fontWeight: FontWeight.w600)),
            ),
          ] else
            IconButton(
              // Small enough that every chip keeps one height.
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
              iconSize: 16,
              tooltip: l10n.foodPrefsRemove(name),
              onPressed: () => onRemove(food),
              icon: Icon(Icons.close_rounded, color: fg),
            ),
        ],
      ),
    );
  }
}
