// lib/modules/products/presentation/pages/inventory_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../domain/models/product_model.dart';
import '../providers/dashboard_provider.dart';

class InventoryDashboardPage extends StatelessWidget {
  const InventoryDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral do Estoque'),
        actions: [_buildFilterChips(context)],
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
                final data = doc.data() as Map<String, dynamic>;

                return ProductModel.fromJson(data, doc.id);
              }).toList();

          return Consumer<DashboardProvider>(
            builder: (context, provider, _) {
              final filteredProducts = provider.applyFilters(products);
              return _buildProductList(filteredProducts);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Row(
      children: [
        FilterChip(
          label: const Text('Vencimento Próximo'),
          selected: provider.showExpiringSoon,
          onSelected: (value) => provider.toggleExpiringSoonFilter(value),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Estoque Baixo'),
          selected: provider.showLowStock,
          onSelected: (value) => provider.toggleLowStockFilter(value),
        ),
      ],
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    if (products.isEmpty) {
      return const Center(child: Text('Nenhum produto encontrado'));
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InventoryProductItem(product: product);
      },
    );
  }
}

class InventoryProductItem extends StatelessWidget {
  final ProductModel product;

  const InventoryProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Produto', product.name),
            _buildInfoRow(
              'Quantidade',
              '${product.quantity} ${product.unit.name}',
            ),
            _buildInfoRow('Estoque Mínimo', product.minStock.toString()),
            _buildInfoRow(
              'Validade',
              DateFormat('dd/MM/yyyy').format(product.expirationDate),
            ),
            _buildForecastInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildForecastInfo() {
    // Implemente a lógica de previsão usando o código existente
    return const Text('Previsão de término: 15/12/2024'); // Exemplo
  }
}
