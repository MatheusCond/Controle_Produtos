import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';

class ProductUsage {
  final String id;
  final String productId;
  final double quantityUsed;
  final ProductUnit unit;
  final DateTime timestamp;

  ProductUsage({
    this.id = '',
    required this.productId,
    required this.quantityUsed,
    required this.unit,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantityUsed': quantityUsed,
      'unit': unit.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

static ProductUsage fromJson(Map<String, dynamic> json, String id) {
  return ProductUsage(
    id: id,
    productId: json['productId'] as String? ?? 'ID_NÃO_ENCONTRADO',
    quantityUsed: (json['quantityUsed'] as num?)?.toDouble() ?? 0.0,
    unit: json['unit'] != null 
        ? ProductUnit.values.firstWhere(
            (e) => e.name == json['unit'],
            orElse: () => ProductUnit.unid,
          )
        : ProductUnit.unid, // Fallback seguro
    timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
}
