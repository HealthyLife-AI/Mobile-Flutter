import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/nutritionist_entities.dart';
import 'bloc/auth/auth_cubit.dart';
import 'bloc/nutritionist/nutritionist_cubit.dart';

/// The real people the app names: the patient's nutritionist (API guide 9.1)
/// and the patient (3.1). Never a fixed demo name.

NutritionistProfile? _nutritionist(BuildContext context) =>
    context.select<NutritionistCubit, NutritionistProfile?>(
        (cubit) => cubit.state.dataOrNull);

/// The nutritionist's name, or '' while it is not known.
String nutritionistName(BuildContext context) =>
    _nutritionist(context)?.name ?? '';

/// The `gender` value the nutritionist messages select on: `male`, `female`,
/// `other` (name known, gender not), or `unknown` (not loaded: the messages
/// then use a generic wording without a name).
String nutritionistGender(BuildContext context) {
  final profile = _nutritionist(context);
  if (profile == null) return 'unknown';
  return profile.gender ?? 'other';
}

/// The patient's first name, or '' when not known.
String patientFirstName(BuildContext context) {
  final name = context
      .select<AuthCubit, String?>((cubit) => cubit.state.user?.name.trim());
  if (name == null || name.isEmpty) return '';
  return name.split(RegExp(r'\s+')).first;
}

/// The `known` value the patient-name messages select on.
String patientNameKnown(BuildContext context) =>
    patientFirstName(context).isEmpty ? 'no' : 'yes';
