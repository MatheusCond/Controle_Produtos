enum ProductUnit { kg, liters, unid }

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double quantity;
  final ProductUnit unit;
  final DateTime expirationDate;

  ProductModel({
    this.id = '',
    required this.name,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.expirationDate,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? quantity,
    ProductUnit? unit,
    DateTime? expirationDate,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit.name,
      'expirationDate': expirationDate.toIso8601String(),
    };
  }

  static ProductUnit unitFromString(String value) {
    return ProductUnit.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductUnit.unid,
    );
  }
}
