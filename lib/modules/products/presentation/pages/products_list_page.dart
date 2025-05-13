import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/modules/products/data/repositories/product_usage_repository.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:myapp/modules/products/presentation/widgets/product_list_tile.dart';
import 'package:provider/provider.dart';

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usageRepo = context.read<ProductUsageRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/register'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar produtos'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products =
              snapshot.data!.docs.map((doc) {
                return ProductModel(
                  id: doc.id,
                  name: doc['name'] as String,
                  description: doc['description'] as String,
                  quantity: (doc['quantity'] as num).toDouble(),
                  unit: ProductModel.unitFromString(doc['unit'] as String),
                  expirationDate: DateTime.parse(
                    doc['expirationDate'] as String,
                  ),
                  minStock: (doc['minStock'] as num).toDouble(),
                );
              }).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder:
                (context, index) => ProductListTile(
                  product: products[index],
                  usageStream: usageRepo.getUsageHistory(products[index].id),
                  dailyAverageStream: usageRepo.getDailyAverageStream(
                    products[index].id,
                  ),
                ),
          );
        },
      ),
    );
  }
}
