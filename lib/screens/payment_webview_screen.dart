import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../routes/app_router.dart';
import '../services/payment_service.dart';
import '../services/firebase_service.dart';
import '../config/app_config.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

@RoutePage()
class PaymentWebviewScreen extends StatefulWidget {
  final String paymentUrl;
  final String successUrlPattern;
  final String callbackUrlPattern;
  final int? gamesCount;

  const PaymentWebviewScreen({
    Key? key,
    required this.paymentUrl,
    required this.successUrlPattern,
    required this.callbackUrlPattern,
    this.gamesCount,
  }) : super(key: key);

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _openPaymentInNewTab();
    } else {
      _initializeController();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _openPaymentInNewTab() async {
    // Capture the messenger and router before async operations
    final messenger = ScaffoldMessenger.of(context);
    final router = context.router;

    final uri = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تم فتح صفحة الدفع في نافذة جديدة'),
            duration: Duration(seconds: 3),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            router.pop();
          }
        });
      }
    }
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
              _checkUrlForRedirect(url);
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkUrlForRedirect(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkUrlForRedirect(String url) {
    if (url.contains('payment-success') ||
        url.contains(widget.successUrlPattern)) {
      _handlePaymentSuccess(url);
    } else if (url.contains('payment-callback')) {
      final uri = Uri.parse(url);
      final status = uri.queryParameters['status'];
      final invoiceId = uri.queryParameters['id'];

      if (status == 'paid' || status == 'success') {
        _handlePaymentSuccess(url, invoiceId: invoiceId);
      } else if (status == 'failed' || status == 'failure') {
        _navigateToFailure();
      }
    } else if (url.contains('payment-failure')) {
      _navigateToFailure();
    }
  }

  void _handlePaymentSuccess(String url, {String? invoiceId}) async {
    if (!mounted) return;

    try {
      String? extractedInvoiceId = invoiceId;

      if (extractedInvoiceId == null) {
        final uri = Uri.parse(url);
        extractedInvoiceId =
            uri.queryParameters['id'] ?? uri.queryParameters['invoice_id'];
      }

      if (extractedInvoiceId != null && extractedInvoiceId.isNotEmpty) {
        final moyasarApiKey = AppConfig.moyasarApiKey;
        final paymentService = PaymentService(apiKey: moyasarApiKey);

        final invoice = await paymentService.getInvoice(extractedInvoiceId);

        if (invoice.status == 'paid') {
          final gamesCountStr = invoice.metadata['games_count'] as String?;
          final gamesCount =
              gamesCountStr != null ? int.tryParse(gamesCountStr) : null;
          final userId = invoice.metadata['user_id'] as String?;

          if (gamesCount != null && gamesCount > 0 && userId != null) {
            final firebaseService = context.read<FirebaseService>();
            await firebaseService.addGamesToUser(userId, gamesCount);

            final userBloc = context.read<UserBloc>();
            userBloc.add(LoadUserEvent(userId: userId));

            if (mounted) {
              context.router.replace(
                PaymentSuccessRoute(
                  invoiceId: extractedInvoiceId,
                  gamesCount: gamesCount,
                ),
              );
            }
            return;
          }
        }
      }

      if (mounted) {
        context.router.replace(
          PaymentSuccessRoute(
            invoiceId: extractedInvoiceId,
            gamesCount: widget.gamesCount,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing payment success: $e');
      if (mounted) {
        context.router.replace(
          PaymentSuccessRoute(
            gamesCount: widget.gamesCount,
          ),
        );
      }
    }
  }

  void _navigateToFailure() {
    if (mounted) {
      context.router.replace(PaymentFailureRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            'إتمام الدفع',
            style: AppTextStyles.largeTvBold.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryRed),
              const SizedBox(height: 24),
              Text(
                'جاري فتح صفحة الدفع...',
                style: AppTextStyles.largeTv,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'يرجى إكمال عملية الدفع في النافذة الجديدة',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'إتمام الدفع',
          style: AppTextStyles.largeTvBold.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: _controller == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed))
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_isLoading)
                  Container(
                    color: AppColors.white,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الدفع'),
        content: const Text('هل أنت متأكد من إلغاء عملية الدفع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.router.pop();
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}
