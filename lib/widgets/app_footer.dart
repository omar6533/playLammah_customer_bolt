import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  // True only when running as a native iOS/Android app — not in any browser.
  static bool get _isNativeApp =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    return isDesktop ? _desktop() : _mobile();
  }

  Widget _desktop() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_full.png',
                height: 36, fit: BoxFit.contain),
            const SizedBox(width: 16),
            _storeBadge('assets/images/google_play_badge.svg'),
            const SizedBox(width: 8),
            _storeBadge('assets/images/app_store_badge.svg'),
            const Spacer(),
            Text(
              'all rights reserved © 2026 Playlammh',
              style: AppTextStyles.mediumRegular.copyWith(
                color: AppColors.primaryRed,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            _socialIcon('assets/images/x_icon.svg'),
            const SizedBox(width: 12),
            _socialIcon('assets/images/snapchat_icon.svg'),
          ],
        ),
      ),
    );
  }

  Widget _mobile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon('assets/images/x_icon.svg'),
              const SizedBox(width: 16),
              _socialIcon('assets/images/snapchat_icon.svg'),
            ],
          ),
          const SizedBox(height: 16),
          Image.asset('assets/images/logo_full.png',
              height: 40, fit: BoxFit.contain),
          if (!_isNativeApp) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _storeBadge('assets/images/google_play_badge.svg', width: 110),
                const SizedBox(width: 12),
                _storeBadge('assets/images/app_store_badge.svg', width: 110),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'all rights reserved © 2026 Playlammh',
            style: AppTextStyles.mediumRegular.copyWith(
              color: AppColors.primaryRed,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(String assetPath) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryRed, width: 1.5),
      ),
      padding: const EdgeInsets.all(7),
      child: SvgPicture.asset(assetPath),
    );
  }

  Widget _storeBadge(String assetPath, {double width = 120}) {
    return SvgPicture.asset(assetPath, width: width, height: 36);
  }
}
