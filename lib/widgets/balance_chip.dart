import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'purchase_dialog.dart';

/// "رصيد ألعابك" with a recharge action; tapping opens the packages dialog.
class BalanceChip extends StatelessWidget {
  final int balance;
  final double fontSize;

  const BalanceChip({super.key, required this.balance, this.fontSize = 13});

  @override
  Widget build(BuildContext context) {
    final empty = balance <= 0;
    return InkWell(
      onTap: () => PurchaseDialog.showStore(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: empty ? AppColors.primaryRed.withValues(alpha: 0.10) : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: empty ? AppColors.primaryRed : const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            Text(
              'رصيد ألعابك : $balance',
              style: AppTextStyles.mediumRegular.copyWith(
                color: empty ? AppColors.primaryRed : const Color(0xFF666666),
                fontSize: fontSize,
                fontWeight: empty ? FontWeight.w700 : FontWeight.w400,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 6),
            Icon(Icons.add_circle, size: fontSize + 4, color: AppColors.primaryRed),
            const SizedBox(width: 2),
            Text(
              'اشحن',
              style: AppTextStyles.mediumBold.copyWith(
                color: AppColors.primaryRed,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
