import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// ClinicalTrustFooter — fixed line appearing beneath every food-logging
/// screen: "Your nutritional data is encrypted and handled with complete
/// medical privacy." Privacy stated explicitly as reassurance (section 1).
class ClinicalTrustFooter extends StatelessWidget {
  const ClinicalTrustFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: AppColors.textSecondary),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'بياناتك الغذائية مشفرة وتُعامل بخصوصية طبية تامة',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
