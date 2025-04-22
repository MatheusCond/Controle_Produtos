import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:myapp/modules/products/domain/models/product_usage.dart';

class ProductUsageRepository {
  final FirebaseFirestore _firestore;

  ProductUsageRepository(this._firestore);

  Future<void> addUsage(
    String productId,
    double quantityUsed,
    ProductUnit unit,
  ) async {
    final productRef = _firestore.collection('products').doc(productId);

    // Use uma transação para garantir atomicidade
    await _firestore.runTransaction((transaction) async {
      // 1. Atualize o estoque do produto
      final productDoc = await transaction.get(productRef);
      final currentQuantity = productDoc['quantity'] as double;
      final newQuantity = currentQuantity - quantityUsed;

      transaction.update(productRef, {'quantity': newQuantity});

      // 2. Registre o uso
      transaction.set(productRef.collection('usages').doc(), {
        'productId': productId,
        'quantityUsed': quantityUsed,
        'unit': unit.name,
        'timestamp':
            FieldValue.serverTimestamp(), // Usa o timestamp do servidor
      });
    });
  }

  Stream<List<ProductUsage>> getUsageHistory(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('usages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ProductUsage.fromJson(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<Map<String, dynamic>> calculateStockForecast(String productId) async {
    final usageSnapshot =
        await _firestore
            .collection('products')
            .doc(productId)
            .collection('usages')
            .orderBy('timestamp', descending: true)
            .get();

    final usages =
        usageSnapshot.docs
            .map((doc) => ProductUsage.fromJson(doc.data(), doc.id))
            .toList();

    if (usages.isEmpty) return {'average': 0.0, 'daysRemaining': 0};

    // Calcula consumo total e período
    final totalConsumed = usages.fold(
      0.0,
      (sum, usage) => sum + usage.quantityUsed,
    );
    final firstDate = usages.last.timestamp;
    final lastDate = usages.first.timestamp;
    final days = lastDate.difference(firstDate).inDays + 1;

    final dailyAverage = totalConsumed / days;

    return {
      'average': dailyAverage,
      'daysRemaining': days > 0 ? dailyAverage : 0,
    };
  }

  Stream<double> getDailyAverageStream(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('usages')
        .snapshots()
        .asyncMap((snapshot) async {
          final result = await calculateStockForecast(productId);
          return result['average'] as double;
        });
  }
}
