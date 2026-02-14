import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:trivia_game/bloc/auth/auth_state.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../routes/app_router.dart';
import '../services/payment_service.dart';
import '../services/app_service.dart';
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
  ScaffoldMessengerState? _messenger;
  StackRouter? _router;
  bool _isDisposed = false;
  bool _isProcessingPayment = false;
  String? _processedInvoiceId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDisposed && mounted) {
      _messenger = ScaffoldMessenger.of(context);
      _router = context.router;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        if (kIsWeb) {
          _openPaymentInNewTab();
        } else {
          _initializeController();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollTimer?.cancel();
    _controller = null;
    super.dispose();
  }

  Future<void> _openPaymentInNewTab() async {
    if (_isDisposed) return;

    final uri = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );

      if (mounted && !_isDisposed && _messenger != null) {
        _messenger!.showSnackBar(
          const SnackBar(
            content: Text('تم فتح صفحة الدفع في نافذة جديدة'),
            duration: Duration(seconds: 3),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && !_isDisposed && _router != null) {
            _router!.pop();
          }
        });
      }
    }
  }

  void _initializeController() {
    if (_isDisposed) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted && !_isDisposed) {
              setState(() {
                _isLoading = true;
              });
              _checkUrlForRedirect(url);
            }
          },
          onPageFinished: (String url) {
            if (mounted && !_isDisposed) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (!_isDisposed) {
              _checkUrlForRedirect(request.url);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkUrlForRedirect(String url) {
    if (_isDisposed) return;

    print('🌐 URL changed: $url');

    // Check if URL redirects back to our domain with payment status
    if (url.contains('playlammh.com') ||
        url.contains('allmahgame.firebaseapp.com')) {
      final uri = Uri.parse(url);
      final status = uri.queryParameters['status'];
      final invoiceId =
          uri.queryParameters['invoice_id'] ?? uri.queryParameters['id'];

      print('🏠 Redirected to domain with status: $status');

      if (status == 'paid' || status == 'success') {
        print('✅ Payment confirmed via domain redirect');
        _handlePaymentSuccess(url, invoiceId: invoiceId);
        return;
      } else if (status == 'failed' || status == 'failure') {
        print('❌ Payment failed via domain redirect');
        _navigateToFailure();
        return;
      }
    }

    // Check if URL contains "paid" status (Moyasar invoice URLs)
    if (url.contains('/invoices/') && url.contains('?')) {
      print('🔍 Detected Moyasar invoice URL, checking status...');
      _checkMoyasarInvoiceStatus(url);
      return;
    }

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

  void _checkMoyasarInvoiceStatus(String url) async {
    if (!mounted || _isDisposed) return;

    try {
      // Extract invoice ID from URL like: https://checkout.moyasar.com/invoices/50dc9a7b-9efd-41aa-ac8a-5a84b36e8467?lang=en
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 2 &&
          pathSegments[pathSegments.length - 2] == 'invoices') {
        final invoiceId = pathSegments.last;
        print('📋 Extracted invoice ID: $invoiceId');

        final moyasarApiKey = AppConfig.moyasarApiKey;
        final paymentService = PaymentService(apiKey: moyasarApiKey);

        // Check invoice status
        print('🔄 Fetching invoice status from Moyasar...');
        final invoice = await paymentService.getInvoice(invoiceId);
        print('📊 Invoice status: ${invoice.status}');

        if (invoice.status == 'paid') {
          print('✅ Payment confirmed as PAID');
          _handlePaymentSuccess(url, invoiceId: invoiceId);
        } else if (invoice.status == 'failed') {
          print('❌ Payment failed');
          _navigateToFailure();
        } else {
          print('⏳ Payment status: ${invoice.status} - waiting...');
          // Continue monitoring for status change
        }
      }
    } catch (e) {
      debugPrint('Error checking Moyasar invoice status: $e');
    }
  }

  void _handlePaymentSuccess(String url, {String? invoiceId}) async {
    if (!mounted || _isDisposed) return;

    // Prevent duplicate processing
    if (_isProcessingPayment) {
      print('⏭️  Already processing payment, skipping...');
      return;
    }

    if (invoiceId != null && _processedInvoiceId == invoiceId) {
      print('⏭️  Invoice $invoiceId already processed, skipping...');
      return;
    }

    _isProcessingPayment = true;
    if (invoiceId != null) {
      _processedInvoiceId = invoiceId;
    }

    print('🎉 _handlePaymentSuccess called');
    print('📄 Invoice ID: $invoiceId');

    // Use singleton AppService instead of context-dependent providers
    final appService = AppService();
    UserBloc? userBloc;
    StackRouter? router;
    String? currentUserId;

    try {
      userBloc = context.read<UserBloc>();
      router = _router ?? context.router;

      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        currentUserId = authState.userId;
      }
    } catch (e) {
      debugPrint('Error reading context in _handlePaymentSuccess: $e');
      _isProcessingPayment = false;
      return;
    }

    if (userBloc == null || router == null) {
      print('❌ Missing required services');
      _isProcessingPayment = false;
      return;
    }

    try {
      String? extractedInvoiceId = invoiceId;

      if (extractedInvoiceId == null) {
        final uri = Uri.parse(url);
        extractedInvoiceId =
            uri.queryParameters['id'] ?? uri.queryParameters['invoice_id'];
      }

      print('📋 Final invoice ID: $extractedInvoiceId');

      if (extractedInvoiceId != null && extractedInvoiceId.isNotEmpty) {
        final moyasarApiKey = AppConfig.moyasarApiKey;
        final paymentService = PaymentService(apiKey: moyasarApiKey);

        print('🔍 Fetching invoice details...');
        final invoice = await paymentService.getInvoice(extractedInvoiceId);
        print('📊 Invoice status: ${invoice.status}');
        print('🎮 Invoice metadata: ${invoice.metadata}');

        if (invoice.status == 'paid') {
          print('✅ Invoice is PAID, processing...');

          final gamesCountStr = invoice.metadata['games_count'] as String?;
          final gamesCount =
              gamesCountStr != null ? int.tryParse(gamesCountStr) : null;
          final userId =
              invoice.metadata['user_id'] as String? ?? currentUserId;

          print('🎯 Games count from metadata: $gamesCount');
          print('👤 User ID: $userId');

          if (gamesCount != null && gamesCount > 0 && userId != null) {
            print('💾 Adding $gamesCount games to user $userId');
            await appService.addGamesToUser(userId, gamesCount);
            print('✅ Games added successfully');

            // Record payment transaction
            print('📝 Recording payment transaction...');
            try {
              await appService.recordPayment(
                userId: userId,
                userEmail: invoice.metadata['user_email'] as String? ?? '',
                userName: invoice.metadata['user_name'] as String? ?? '',
                userMobile: invoice.metadata['user_mobile'] as String? ?? '',
                packageId: invoice.metadata['package_id'] as String? ?? '',
                packageTitle:
                    invoice.metadata['package_title'] as String? ?? '',
                gamesCount: gamesCount,
                amountInHalalas: invoice.amount,
                invoiceId: extractedInvoiceId,
                paymentStatus: 'completed',
                metadata: invoice.metadata,
              );
              print('✅ Payment transaction recorded');
            } catch (e) {
              print('⚠️ Failed to record payment: $e');
              // Continue anyway, the important part (adding games) succeeded
            }

            print('🔄 Reloading user profile...');
            userBloc.add(LoadUserEvent(userId: userId));

            if (mounted && !_isDisposed) {
              print('🎊 Navigating to success screen with $gamesCount games');
              router.replace(
                PaymentSuccessRoute(
                  invoiceId: extractedInvoiceId,
                  gamesCount: gamesCount,
                ),
              );
            }
            return;
          } else {
            print('⚠️ Missing games count or user ID in invoice metadata');
          }
        } else {
          print('⚠️ Invoice status is not "paid": ${invoice.status}');
        }
      }

      // Fallback: use games count from widget
      print('⚠️ Using fallback games count: ${widget.gamesCount}');
      if (mounted && !_isDisposed) {
        router.replace(
          PaymentSuccessRoute(
            invoiceId: extractedInvoiceId,
            gamesCount: widget.gamesCount,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error processing payment success: $e');
      _isProcessingPayment = false;
      if (mounted && !_isDisposed) {
        router.replace(
          PaymentSuccessRoute(
            gamesCount: widget.gamesCount,
          ),
        );
      }
    }
  }

  void _navigateToFailure() {
    if (mounted && !_isDisposed && _router != null) {
      _router!.replace(PaymentFailureRoute());
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
                style: AppTextStyles.bodyBold,
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
    if (_isDisposed) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إلغاء الدفع'),
        content: const Text('هل أنت متأكد من إلغاء عملية الدفع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (!_isDisposed && _router != null) {
                // Go back to dashboard/landing page
                _router!.popUntilRoot();
                _router!.replace(const LandingRoute());
              }
            },
            child: const Text('نعم، العودة للوحة التحكم'),
          ),
        ],
      ),
    );
  }
}
