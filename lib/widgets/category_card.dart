import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable category subcategory card — Figma spec: 220.8×380, radius 24, border 2px.
/// Used in CategorySelectionScreen (with selection state) and HomeCategoriesSection (display-only).
class CategoryCard extends StatelessWidget {
  final String nameAr;
  final String icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.nameAr,
    required this.icon,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : const Color(0xFFE8E8E8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryRed.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: isSelected ? 12 : 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Opacity(
                opacity: isDisabled ? 0.45 : 1.0,
                child: Column(
                  children: [
                    // Illustration area (~78 %)
                    Expanded(
                      flex: 78,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        color: isSelected
                            ? const Color(0xFFFFD6DD)
                            : const Color(0xFFDCEEFB),
                        child: Image.asset(
                          'assets/images/category_placeholder.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 44),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Name area (~22 %)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: isSelected ? AppColors.primaryRed : Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      child: Center(
                        child: Text(
                          nameAr,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Flag badge — top-right
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 2),
                      const Text('🇸🇦', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
