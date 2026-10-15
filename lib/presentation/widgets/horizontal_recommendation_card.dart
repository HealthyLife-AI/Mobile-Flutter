import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/recommendation_entity.dart';

/// HorizontalRecommendationCard — single card in the recipes/doctors
/// carousel, supporting M10 staggered Slide+Fade on the section's
/// first appearance only (60-80ms apart per card).
class HorizontalRecommendationCard extends StatefulWidget {
  final RecommendationItem item;
  final Duration delay;
  const HorizontalRecommendationCard(
      {super.key, required this.item, required this.delay});

  @override
  State<HorizontalRecommendationCard> createState() =>
      _HorizontalRecommendationCardState();
}

class _HorizontalRecommendationCardState
    extends State<HorizontalRecommendationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
        child: Container(
          width: 150,
          margin: const EdgeInsetsDirectional.only(end: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: widget.item.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child:
                    Icon(widget.item.icon, color: widget.item.color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(widget.item.title,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(widget.item.subtitle,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// The carousel itself — one-time staggered entrance the first time the
/// section appears (does not replay on scroll back into view).
class HorizontalRecommendationList extends StatelessWidget {
  final List<RecommendationItem> items;
  const HorizontalRecommendationList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      reverse: true,
      itemCount: items.length,
      itemBuilder: (context, i) => HorizontalRecommendationCard(
        item: items[i],
        delay: Duration(milliseconds: i * 70),
      ),
    );
  }
}
