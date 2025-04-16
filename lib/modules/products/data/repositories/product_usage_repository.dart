import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:myapp/modules/products/domain/models/product_usage.dart';

class ProductUsageRepository {
  final FirebaseFirestore _firestore;

  ProductUsageRepository(this._firestore);

  Future<void> addUsage(String productId, double quantityUsed, ProductUnit unit) async {
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
}
