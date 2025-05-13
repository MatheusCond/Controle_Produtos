import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:myapp/services/notifications/notification_service.dart';

class StockChecker {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  StockChecker(this._firestore, this._notificationService);

  void startMonitoring() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      for (final doc in snapshot.docs) {
        final product = ProductModel.fromJson(doc.data(), doc.id);
        if (product.quantity <= product.minStock) {
          _notificationService.showLowStockNotification(
            id: product.id.hashCode + 1, // ID diferente da notificação de validade
            productName: product.name,
            currentStock: product.quantity,
          );
        }
      }
    });
  }
}