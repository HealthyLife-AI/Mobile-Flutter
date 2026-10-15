import 'package:flutter/material.dart';

/// Domain entities for the onboarding health-profile step: selected chronic
/// conditions, food-allergy groups and a free-form medications list, each
/// with a stable [id] so a real backend can diff selections.

class HealthConditionOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  const HealthConditionOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class FoodAllergyOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  const FoodAllergyOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class MedicationEntry {
  final String name;
  final String frequency;
  const MedicationEntry({required this.name, required this.frequency});
}
