import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

/// DetailHeroHeader — colored top panel + overlapping white info sheet.
/// Used for Schedule/Accountability Calls and any similar detail screen (M11).
class DetailHeroHeader extends StatelessWidget {
  final Widget topPanelChild;
  final Widget sheetChild;
  final double topPanelHeight;
  final String heroTag;

  const DetailHeroHeader({
    super.key,
    required this.topPanelChild,
    required this.sheetChild,
    this.topPanelHeight = 220,
    this.heroTag = 'detail-hero',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: Container(
            height: topPanelHeight,
            width: double.infinity,
            decoration:
                const BoxDecoration(gradient: AppColors.primaryDarkGradient),
            padding: const EdgeInsets.all(20),
            child: topPanelChild,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: topPanelHeight - 28),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
            ),
            padding: const EdgeInsets.all(20),
            child: sheetChild,
          ),
        ),
      ],
    );
  }
}
