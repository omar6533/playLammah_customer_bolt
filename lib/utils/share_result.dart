import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../theme/app_colors.dart';

/// Builds the text shared after a game ends.
String buildResultShareText({
  required String winnerName,
  required int winnerScore,
  required String loserName,
  required int loserScore,
}) {
  final headline = winnerScore == loserScore
      ? '🤝 تعادل $winnerName و$loserName بنتيجة $winnerScore - $loserScore'
      : '🏆 فاز فريق $winnerName على $loserName بنتيجة $winnerScore - $loserScore';
  return '$headline في لمّه وتحدي!\nجرّبوها: ${AppConfig.siteUrl}';
}

/// Opens the platform share sheet (iOS/Android, or Web Share API in the
/// browser). Browsers without Web Share get a small sheet with WhatsApp and
/// copy-to-clipboard instead.
Future<void> shareResult(BuildContext context, String text) async {
  final box = context.findRenderObject() as RenderBox?;
  try {
    await SharePlus.instance.share(ShareParams(
      text: text,
      mailToFallbackEnabled: false,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  } catch (_) {
    if (context.mounted) await _showFallbackSheet(context, text);
  }
}

Future<void> _showFallbackSheet(BuildContext context, String text) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('مشاركة النتيجة',
                    style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
                title: const Text('واتساب'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  launchUrl(
                    Uri.parse(
                        'https://wa.me/?text=${Uri.encodeComponent(text)}'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: AppColors.primaryRed),
                title: const Text('نسخ النتيجة'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ النتيجة')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
