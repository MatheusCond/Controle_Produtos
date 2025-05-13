enum ProductUnit { kg, liters, unid }

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double quantity;
  final ProductUnit unit;
  final DateTime expirationDate;
  final double minStock;

  ProductModel({
    this.id = '',
    required this.name,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.expirationDate,
    required this.minStock,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? quantity,
    ProductUnit? unit,
    DateTime? expirationDate,
    double? minStock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expirationDate: expirationDate ?? this.expirationDate,
      minStock: minStock ?? this.minStock, // Adicionado
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit.name,
      'expirationDate': expirationDate.toIso8601String(),
      'minStock': minStock,
    };
  }

  // Método fromJson completo
  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductModel(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: ProductUnit.values.firstWhere(
        (e) => e.name == json['unit'],
        orElse: () => ProductUnit.unid,
      ),
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      minStock: (json['minStock'] as num).toDouble(), // Adicionado
    );
  }

  static ProductUnit unitFromString(String value) {
    return ProductUnit.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductUnit.unid,
    );
  }
}
