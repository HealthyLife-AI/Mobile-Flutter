import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

IconData _categoryIcon(String category) {
  switch (category) {
    case 'redFruit':
      return Icons.circle; // apple-like dot, kept simple/abstract per spec's "icon" not literal artwork
    case 'greenFruit':
      return Icons.eco_rounded;
    case 'naturalSugar':
      return Icons.grain_rounded;
    case 'dairy':
      return Icons.circle_outlined;
    case 'cookedProtein':
      return Icons.outdoor_grill_rounded;
    case 'carb':
      return Icons.public_rounded;
    case 'nuts':
      return Icons.eco_outlined;
    default:
      return Icons.circle_outlined;
  }
}

/// FoodTagIcon (component 8, section 2.3) — colors a search-result's
/// circular icon by nutritional CATEGORY, not the specific food name.
/// Deliberately kept as its own file/widget so it is never confused with
/// MealTypeIcon (2.2), even though both are visually "pastel circles"
/// (section 8, point 6).
class FoodTagIcon extends StatelessWidget {
  final String category;
  final double size;
  const FoodTagIcon({super.key, required this.category, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppColors.foodTagBg(category), shape: BoxShape.circle),
      child: Icon(_categoryIcon(category), color: AppColors.foodTagIcon(category), size: size * 0.45),
    );
  }
}
