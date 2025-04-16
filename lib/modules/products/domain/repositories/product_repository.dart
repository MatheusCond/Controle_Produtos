import 'package:myapp/modules/products/domain/models/product_model.dart';

abstract class ProductRepository {
  Future<void> addProduct(ProductModel product);
}