import 'package:flutter/material.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:myapp/modules/products/domain/usecases/record_usage_usecase.dart';

class UsageProvider extends ChangeNotifier {
  final RecordUsageUseCase recordUsageUseCase;
  final TextEditingController quantityController = TextEditingController();

  UsageProvider(this.recordUsageUseCase);

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty || double.tryParse(value) == null) {
      return 'Quantidade inválida';
    }
    return null;
  }

  Future<void> recordUsage(String productId, ProductUnit unit, BuildContext context) async {
    if (quantityController.text.isEmpty) return;

    final quantity = double.parse(quantityController.text);
    await recordUsageUseCase.execute(productId, quantity, unit);
    quantityController.clear();
    Navigator.pop(context);
  }
}