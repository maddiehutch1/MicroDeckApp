import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Product ID registered in App Store Connect and Google Play Console.
/// ⚠️ User action required: create a one-time purchase product with this ID
/// in both App Store Connect and Google Play Console before publishing.
const String kProProductId = 'com.microdeck.pro';

const String _kProPrefKey = 'isProUnlocked';

class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPro = false;
  bool get isPro => _isPro;

  final _proController = StreamController<bool>.broadcast();
  Stream<bool> get proStream => _proController.stream;

  Future<void> init() async {
    _isPro = await _loadProStatus();
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
    );
  }

  Future<bool> _loadProStatus() async {
    try {
      final prefs = SharedPreferencesAsync();
      return await prefs.getBool(_kProPrefKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _setProStatus(bool value) async {
    _isPro = value;
    _proController.add(value);
    try {
      final prefs = SharedPreferencesAsync();
      await prefs.setBool(_kProPrefKey, value);
    } catch (_) {}
  }

  Future<bool> buyPro() async {
    if (_isPro) return true;

    final available = await _iap.isAvailable();
    if (!available) return false;

    final response = await _iap.queryProductDetails({kProProductId});
    if (response.productDetails.isEmpty) {
      debugPrint('PurchaseService: product not found — check App Store Connect / Play Console setup');
      return false;
    }

    final purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == kProProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          _setProStatus(true);
        }
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _proController.close();
  }
}
