import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/shopping_list.dart';
import '../../l10n/l10n.dart';
import '../bloc/meal_plan/meal_plan_cubit.dart';
import '../date_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/segmented_sliding_tabs.dart';
import '../widgets/spec_ui.dart';

/// «قائمة التسوق»: what to buy for [day] or for the whole week, built on the
/// device from the plan (API guide 5.4), grouped by aisle.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key, required this.day});

  /// The day the list starts on.
  final DateTime day;

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _week = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = context.watch<MealPlanCubit>().state.dataOrNull;
    final sections = plan == null
        ? const <ShoppingSection>[]
        : shoppingListFor(plan, day: _week ? null : widget.day);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.shoppingListTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            SegmentedSlidingTabs(
              tabs: [l10n.shoppingDayTab, l10n.shoppingWeekTab],
              selectedIndex: _week ? 1 : 0,
              onChanged: (i) => setState(() => _week = i == 1),
            ),
            const SizedBox(height: 10),
            Text(
              _week ? l10n.shoppingWeekNote : fullDayLabel(context, widget.day),
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 4),
            Text(l10n.shoppingNote, style: AppTextStyles.caption),
            const SizedBox(height: 14),
            if (sections.isEmpty)
              SpecEmptyState(
                icon: Icons.shopping_basket_outlined,
                title: l10n.shoppingEmpty,
              )
            else
              for (final section in sections) ...[
                _SectionCard(section: section),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final ShoppingSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SpecCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SpecSectionTitle(_title(l10n, section.key),
              icon: _icon(section.key)),
          const SizedBox(height: 8),
          for (final item in section.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.food.name, style: AppTextStyles.body),
                        if (item.alternatives.isNotEmpty)
                          Text(
                            l10n.shoppingAlternatives(item.alternatives
                                .map((food) => food.name)
                                .join(context.isArabic ? '، ' : ', ')),
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(_amount(context, item.grams),
                      style: AppTextStyles.cardTitle),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Grams, or kilograms from one kilogram up.
  static String _amount(BuildContext context, int grams) {
    final l10n = context.l10n;
    if (grams < 1000) {
      return l10n.commonGramsValue(context.localizeDigits(grams));
    }
    final kg = grams / 1000;
    final text =
        kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);
    return l10n.commonKgValue(context.localizeDigits(text));
  }

  static String _title(AppLocalizations l10n, String key) => switch (key) {
        'produce' => l10n.shoppingSectionProduce,
        'meat_poultry_fish' => l10n.shoppingSectionMeat,
        'dairy_eggs' => l10n.shoppingSectionDairy,
        'grains_starches' => l10n.shoppingSectionGrains,
        'legumes_nuts' => l10n.shoppingSectionLegumes,
        'oils_spices' => l10n.shoppingSectionOils,
        _ => l10n.shoppingSectionOther,
      };

  static IconData _icon(String key) => switch (key) {
        'produce' => Icons.eco_outlined,
        'meat_poultry_fish' => Icons.set_meal_outlined,
        'dairy_eggs' => Icons.egg_outlined,
        'grains_starches' => Icons.bakery_dining_outlined,
        'legumes_nuts' => Icons.spa_outlined,
        'oils_spices' => Icons.water_drop_outlined,
        _ => Icons.shopping_basket_outlined,
      };
}
