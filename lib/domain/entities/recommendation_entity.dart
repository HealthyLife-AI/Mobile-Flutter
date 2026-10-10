import 'package:flutter/material.dart';

/// Item shown in the horizontal recommendation carousel (recipes, etc.).
class RecommendationItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const RecommendationItem({required this.title, required this.subtitle, required this.icon, required this.color});
}
