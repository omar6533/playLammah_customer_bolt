import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/app_service.dart';
import '../theme/app_colors.dart';

const _kReasons = [
  'الإجابة خاطئة',
  'السؤال غير واضح',
  'الصورة لا تظهر',
  'خطأ إملائي',
  'أخرى',
];

/// Lets players flag a problem with the current question. The question id
/// and category are attached automatically so the content team can find it.
Future<void> showQuestionReportDialog(
  BuildContext context, {
  required Question question,
  String? gameId,
}) async {
  final sent = await showDialog<bool>(
    context: context,
    builder: (_) => _QuestionReportDialog(question: question, gameId: gameId),
  );
  if (sent == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('شكراً! وصلتنا ملاحظتك', textDirection: TextDirection.rtl),
        backgroundColor: AppColors.primaryRed,
      ),
    );
  }
}

class _QuestionReportDialog extends StatefulWidget {
  final Question question;
  final String? gameId;

  const _QuestionReportDialog({required this.question, this.gameId});

  @override
  State<_QuestionReportDialog> createState() => _QuestionReportDialogState();
}

class _QuestionReportDialogState extends State<_QuestionReportDialog> {
  final _noteController = TextEditingController();
  String? _reason;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_reason == null) {
      setState(() => _error = 'اختر نوع الملاحظة');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await AppService().reportQuestion(
        questionId: widget.question.id,
        subCategoryId: widget.question.subCategoryId,
        questionText: widget.question.questionTextAr,
        reason: _reason!,
        note: _noteController.text.trim(),
        gameId: widget.gameId,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error sending question report: $e');
      if (mounted) {
        setState(() {
          _sending = false;
          _error = 'تعذر إرسال الملاحظة، حاول مرة ثانية';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ملاحظة على السؤال',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.primaryRed, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final reason in _kReasons)
                      ChoiceChip(
                        label: Text(reason),
                        selected: _reason == reason,
                        selectedColor:
                            AppColors.primaryRed.withValues(alpha: 0.15),
                        onSelected: _sending
                            ? null
                            : (_) => setState(() {
                                  _reason = reason;
                                  _error = null;
                                }),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _noteController,
                  enabled: !_sending,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'اكتب التفاصيل (اختياري)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (_error != null)
                  Text(_error!,
                      style: const TextStyle(
                          color: AppColors.primaryRed, fontSize: 12)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _sending ? null : () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: _sending ? null : _send,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: _sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}
