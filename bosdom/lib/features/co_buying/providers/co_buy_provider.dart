import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/variant_option.dart';
import '../models/co_buy_session.dart';
import '../services/co_buy_pool_service.dart';

/// All buyer-facing co-buy deals, with per-user `joined` state — backs the
/// co-buying list, the marketplace carousel, and the detail screen.
class CoBuyNotifier extends AsyncNotifier<List<CoBuySession>> {
  @override
  Future<List<CoBuySession>> build() => CoBuyPoolService.fetchPools();

  CoBuySession byId(String id) =>
      (state.value ?? const []).firstWhere((s) => s.id == id);

  /// Creates a new co-buy deal, started by the current seller.
  Future<CoBuySession> create({
    required String productName,
    String category = '',
    required String description,
    required double price,
    required double originalPrice,
    required int targetQty,
    required String unitLabel,
    required String perUnitLabel,
    required int minOrderQty,
    required String timeLeft,
    required bool autoRenew,
    List<String> sizes = const [],
    List<ProductColorOption> colorOptions = const [],
    String weight = '',
    String origin = '',
    String grade = '',
    String packaging = '',
    List<File> photos = const [],
  }) async {
    final session = await CoBuyPoolService.createPool(
      productName: productName,
      category: category,
      description: description,
      price: price,
      originalPrice: originalPrice,
      targetQty: targetQty,
      unitLabel: unitLabel,
      perUnitLabel: perUnitLabel,
      minOrderQty: minOrderQty,
      timeLeft: timeLeft,
      autoRenew: autoRenew,
      sizes: sizes,
      colorOptions: colorOptions,
      weight: weight,
      origin: origin,
      grade: grade,
      packaging: packaging,
      photos: photos,
    );
    ref.invalidateSelf();
    await future;
    return session;
  }

  /// Updates the editable fields of an existing deal.
  Future<void> updateDeal(
    String id, {
    required String productName,
    String category = '',
    required String description,
    required double price,
    required double originalPrice,
    required int targetQty,
    required String unitLabel,
    required String perUnitLabel,
    required int minOrderQty,
    required String timeLeft,
    required bool autoRenew,
    List<String> sizes = const [],
    List<ProductColorOption> colorOptions = const [],
    String weight = '',
    String origin = '',
    String grade = '',
    String packaging = '',
    List<File> photos = const [],
  }) async {
    await CoBuyPoolService.updatePool(
      id,
      productName: productName,
      category: category,
      description: description,
      price: price,
      originalPrice: originalPrice,
      targetQty: targetQty,
      unitLabel: unitLabel,
      perUnitLabel: perUnitLabel,
      minOrderQty: minOrderQty,
      timeLeft: timeLeft,
      autoRenew: autoRenew,
      sizes: sizes,
      colorOptions: colorOptions,
      weight: weight,
      origin: origin,
      grade: grade,
      packaging: packaging,
      photos: photos,
    );
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    await CoBuyPoolService.deletePool(id);
    ref.invalidateSelf();
    await future;
  }

  /// Joins [id] with the buyer's chosen [quantity]/variant, or updates an
  /// existing participation to a new quantity. Throws [CoBuyJoinException]
  /// on a rejected request (below the deal's minimum, or above what's left).
  Future<CoBuySession> join(
    String id, {
    required int quantity,
    String? size,
    ProductColorOption? color,
  }) async {
    final updated = await CoBuyPoolService.joinPool(
      id,
      quantity: quantity,
      size: size,
      color: color,
    );
    _replace(updated);
    return updated;
  }

  Future<CoBuySession> leave(String id) async {
    final updated = await CoBuyPoolService.leavePool(id);
    _replace(updated);
    return updated;
  }

  Future<CoBuySession> requestLeave(String id, String reason) async {
    final updated = await CoBuyPoolService.requestLeave(id, reason);
    _replace(updated);
    return updated;
  }

  Future<CoBuySession> payJoin(String id, String paymentMethod) async {
    final updated = await CoBuyPoolService.payJoin(id, paymentMethod);
    _replace(updated);
    return updated;
  }

  void _replace(CoBuySession updated) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final s in current)
        if (s.id == updated.id) updated else s,
    ]);
  }
}

final coBuyProvider = AsyncNotifierProvider<CoBuyNotifier, List<CoBuySession>>(
  CoBuyNotifier.new,
);

/// The current seller's own co-buy deals, for the seller deals dashboard.
final coBuySellerPoolsProvider = FutureProvider.autoDispose<List<CoBuySession>>(
  (ref) {
    return CoBuyPoolService.fetchMyPools();
  },
);

/// A single co-buy deal by id, for the create/edit form when opened to edit
/// an existing deal — fetched independently of [coBuyProvider] since the
/// seller may reach the edit form without ever having loaded the
/// buyer-facing deal list.
final coBuyPoolByIdProvider = FutureProvider.autoDispose
    .family<CoBuySession, String>((ref, id) => CoBuyPoolService.fetchPool(id));
