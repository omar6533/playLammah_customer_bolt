import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String apiKey;
  final String baseUrl = 'https://api.moyasar.com/v1';

  PaymentService({required this.apiKey});

  Future<PaymentInvoiceResponse> createInvoice({
    required int amount,
    required String description,
    required String callbackUrl,
    required String successUrl,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      print('💰 Creating invoice with amount: $amount');
      print('💰 Description: $description');
      print('💰 Callback URL: $callbackUrl');
      print('💰 Success URL: $successUrl');

      final requestBody = {
        'amount': amount,
        'currency': 'SAR',
        'description': description,
        'callback_url': callbackUrl,
        'success_url': successUrl,
        'metadata': metadata,
      };

      print('💰 Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/invoices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        },
        body: json.encode(requestBody),
      );

      print('💰 Response status: ${response.statusCode}');
      print('💰 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('💰 Invoice created successfully');
        return PaymentInvoiceResponse.fromJson(data);
      } else {
        print('💰 Failed to create invoice: ${response.statusCode}');
        throw PaymentException(
          'Failed to create invoice: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('💰 Exception creating invoice: $e');
      throw PaymentException('Error creating invoice: $e');
    }
  }

  Future<PaymentInvoiceResponse> getInvoice(String invoiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invoices/$invoiceId'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentInvoiceResponse.fromJson(data);
      } else {
        throw PaymentException(
          'Failed to get invoice: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw PaymentException('Error getting invoice: $e');
    }
  }
}

class PaymentInvoiceResponse {
  final String id;
  final String status;
  final int amount;
  final String currency;
  final String description;
  final String url;
  final String callbackUrl;
  final String? successUrl;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  PaymentInvoiceResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.description,
    required this.url,
    required this.callbackUrl,
    this.successUrl,
    required this.metadata,
    required this.createdAt,
  });

  factory PaymentInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInvoiceResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      callbackUrl: json['callback_url'] as String,
      successUrl: json['success_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => message;
}
