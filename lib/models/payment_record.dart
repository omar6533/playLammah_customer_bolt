import 'package:equatable/equatable.dart';

class PaymentRecord extends Equatable {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String userMobile;
  final String packageId;
  final String packageTitle;
  final int gamesCount;
  final int amountInHalalas;
  final String currency;
  final String invoiceId;
  final String paymentStatus;
  final String createdAt;
  final Map<String, dynamic>? metadata;

  const PaymentRecord({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.userMobile,
    required this.packageId,
    required this.packageTitle,
    required this.gamesCount,
    required this.amountInHalalas,
    this.currency = 'SAR',
    required this.invoiceId,
    required this.paymentStatus,
    required this.createdAt,
    this.metadata,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userEmail: json['user_email'] as String,
      userName: json['user_name'] as String,
      userMobile: json['user_mobile'] as String,
      packageId: json['package_id'] as String,
      packageTitle: json['package_title'] as String,
      gamesCount: json['games_count'] as int,
      amountInHalalas: json['amount_in_halalas'] as int,
      currency: json['currency'] as String? ?? 'SAR',
      invoiceId: json['invoice_id'] as String,
      paymentStatus: json['payment_status'] as String,
      createdAt: json['created_at'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_email': userEmail,
      'user_name': userName,
      'user_mobile': userMobile,
      'package_id': packageId,
      'package_title': packageTitle,
      'games_count': gamesCount,
      'amount_in_halalas': amountInHalalas,
      'currency': currency,
      'invoice_id': invoiceId,
      'payment_status': paymentStatus,
      'created_at': createdAt,
      'metadata': metadata,
    };
  }

  PaymentRecord copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    String? userMobile,
    String? packageId,
    String? packageTitle,
    int? gamesCount,
    int? amountInHalalas,
    String? currency,
    String? invoiceId,
    String? paymentStatus,
    String? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userMobile: userMobile ?? this.userMobile,
      packageId: packageId ?? this.packageId,
      packageTitle: packageTitle ?? this.packageTitle,
      gamesCount: gamesCount ?? this.gamesCount,
      amountInHalalas: amountInHalalas ?? this.amountInHalalas,
      currency: currency ?? this.currency,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userEmail,
        userName,
        userMobile,
        packageId,
        packageTitle,
        gamesCount,
        amountInHalalas,
        currency,
        invoiceId,
        paymentStatus,
        createdAt,
        metadata,
      ];
}
