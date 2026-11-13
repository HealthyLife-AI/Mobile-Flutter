import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/meal_log/meal_log_cubit.dart';
import 'load_error_view.dart';

/// How long the patient can undo a meal they just logged.
const Duration mealUndoWindow = Duration(seconds: 6);

/// Logs [meal] as planned and shows the confirmation with its undo, or the
/// reason it could not be logged. Takes what outlives the screen that asked,
/// so a bottom sheet can close first.
Future<void> logPlannedAndConfirm({
  required ScaffoldMessengerState messenger,
  required MealLogCubit cubit,
  required AppLocalizations l10n,
  required Meal meal,

  /// The foods eaten, an alternative in place of a planned food where one was
  /// picked. Null: the meal as planned.
  List<PlanItem>? eaten,
}) async {
  final result = await cubit.logPlanned(meal, eaten: eaten);
  final entry = result.valueOrNull;
  if (entry == null) {
    messenger.showSnackBar(SnackBar(
        content: Text(loadFailureText(l10n, result.failureOrNull))));
    return;
  }
  showMealLoggedSnack(
      messenger: messenger, cubit: cubit, l10n: l10n, entry: entry);
}

/// The short confirmation after a planned meal is logged, with an undo.
///
/// It replaces a full success screen: the patient stays where they were and
/// the next meal is one tap away. Undo removes the log (a log still waiting
/// in the offline queue is dropped before it is sent); after the window the
/// log can still be edited or deleted from today's record.
///
/// Takes the messenger and cubit, not a context, so it can be called right
/// after the screen that logged the meal has been closed.
void showMealLoggedSnack({
  required ScaffoldMessengerState messenger,
  required MealLogCubit cubit,
  required AppLocalizations l10n,
  required MealLogEntry entry,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: mealUndoWindow,
      // A snack bar with an action stays until dismissed by default; the undo
      // is only for the next few seconds.
      persist: false,
      backgroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(children: [
        const Icon(Icons.check_circle_rounded,
            color: AppColors.primaryTint, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(l10n.mealLoggedSnack(entry.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: Colors.white)),
        ),
      ]),
      action: SnackBarAction(
        label: l10n.mealUndo,
        textColor: AppColors.primaryTint,
        onPressed: () async {
          final result = await cubit.delete(entry.id);
          if (result.isSuccess) return;
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.mealUndoFailed)));
        },
      ),
    ));
}
