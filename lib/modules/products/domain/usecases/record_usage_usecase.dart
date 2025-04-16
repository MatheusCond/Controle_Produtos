import 'package:myapp/modules/products/data/repositories/product_usage_repository.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';

class RecordUsageUseCase {
  final ProductUsageRepository repository;

  RecordUsageUseCase(this.repository);

  Future<void> execute(String productId, double quantity, ProductUnit unit) async {
    await repository.addUsage(productId, quantity, unit);
  }
}