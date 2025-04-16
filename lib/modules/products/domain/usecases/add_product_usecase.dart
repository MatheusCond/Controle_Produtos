import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:myapp/modules/products/domain/repositories/product_repository.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<void> execute(ProductModel product) async {
    return await repository.addProduct(product);
  }
}