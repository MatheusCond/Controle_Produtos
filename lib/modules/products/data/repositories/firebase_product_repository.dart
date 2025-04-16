import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:myapp/modules/products/domain/repositories/product_repository.dart';

class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;

  FirebaseProductRepository(this._firestore);

  @override
  Future<void> addProduct(ProductModel product) async {
    // Adiciona o produto e obtém o ID gerado
    final docRef = await _firestore
        .collection('products')
        .add(product.toJson());

    // Atualiza o modelo com o ID gerado (opcional)
    await docRef.update({'id': docRef.id});
  }
}
