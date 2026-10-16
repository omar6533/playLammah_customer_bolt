import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A purchasable package, managed from the admin "Packages" page.
class GamePackage {
  final String id;
  final String title;
  final double priceSar;
  final Color color;
  final int gameCount;

  const GamePackage({
    required this.id,
    required this.title,
    required this.priceSar,
    required this.color,
    required this.gameCount,
  });

  int get priceInHalalas => (priceSar * 100).round();

  /// Moyasar won't charge less than 1 SAR, so a discount can't go below that.
  int discountedHalalas(int discountPercent) {
    if (discountPercent <= 0) return priceInHalalas;
    final discounted = (priceInHalalas * (100 - discountPercent) / 100).round();
    return discounted < 100 ? 100 : discounted;
  }

  static String formatSar(int halalas) {
    final sar = halalas / 100;
    return 'SAR ${sar == sar.roundToDouble() ? sar.toInt() : sar.toStringAsFixed(2)}';
  }

  String get price => formatSar(priceInHalalas);

  factory GamePackage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final hex = ((d['color'] as String?) ?? '#D64453').replaceFirst('#', '');
    return GamePackage(
      id: doc.id,
      title: (d['title_ar'] as String?) ?? '',
      priceSar: (d['price_sar'] as num?)?.toDouble() ?? 0,
      color: Color(int.tryParse('FF$hex', radix: 16) ?? 0xFFD64453),
      gameCount: (d['games_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class PromoCode {
  final String code;
  final int discountPercent;
  const PromoCode({required this.code, required this.discountPercent});
}

class PromoCodeException implements Exception {
  final String message;
  const PromoCodeException(this.message);
  @override
  String toString() => message;
}

class StoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Active packages in admin-defined order. Filtering is done client-side so
  /// no composite Firestore index is needed.
  Future<List<GamePackage>> getActivePackages() async {
    final snap = await _db.collection('packages').orderBy('display_order').get();
    return snap.docs
        .where((d) => (d.data()['is_active'] as bool?) ?? true)
        .map(GamePackage.fromFirestore)
        .where((p) => p.gameCount > 0 && p.priceSar > 0)
        .toList();
  }

  Future<PromoCode> validatePromoCode(String raw) async {
    final code = raw.trim().toUpperCase();
    if (code.isEmpty) throw const PromoCodeException('أدخل رمز الخصم');
    final doc = await _db.collection('promo_codes').doc(code).get();
    final d = doc.data();
    if (!doc.exists || d == null) throw const PromoCodeException('رمز الخصم غير صحيح');
    if ((d['is_active'] as bool?) == false) throw const PromoCodeException('رمز الخصم غير فعّال');
    final expiresAt = (d['expires_at'] as Timestamp?)?.toDate();
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      throw const PromoCodeException('انتهت صلاحية رمز الخصم');
    }
    final maxUses = (d['max_uses'] as num?)?.toInt();
    final used = (d['used_count'] as num?)?.toInt() ?? 0;
    if (maxUses != null && used >= maxUses) {
      throw const PromoCodeException('تم استخدام رمز الخصم بالكامل');
    }
    final percent = (d['discount_percent'] as num?)?.toInt() ?? 0;
    if (percent <= 0) throw const PromoCodeException('رمز الخصم غير صحيح');
    return PromoCode(code: code, discountPercent: percent.clamp(1, 99));
  }

  Future<void> recordPromoUse(String code) => _db
      .collection('promo_codes')
      .doc(code)
      .update({'used_count': FieldValue.increment(1)});
}
