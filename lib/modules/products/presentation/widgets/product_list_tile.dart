import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:myapp/modules/products/domain/models/product_usage.dart';
import 'package:provider/provider.dart';
import '../providers/usage_provider.dart';
import 'usage_history_dialog.dart';

class ProductListTile extends StatelessWidget {
  final ProductModel product;
  final Stream<List<ProductUsage>> usageStream;

  const ProductListTile({
    super.key,
    required this.product,
    required this.usageStream,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Adicione um Card como ancestral
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estoque: ${product.quantity} ${product.unit.name}'),
            Text(
              'Validade: ${DateFormat('dd/MM/yyyy').format(product.expirationDate)}',
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) => UsageHistoryDialog(
                          productId: product.id,
                          usageStream: usageStream,
                        ),
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => _showUsageDialog(context, product.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsageDialog(BuildContext context, String productId) {
    final provider = Provider.of<UsageProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Registrar Uso'),
          content: TextFormField(
            controller: provider.quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantidade Usada'),
            validator: provider.validateQuantity,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed:
                  () => provider.recordUsage(
                    product.id,
                    product.unit,
                    context,
                  ),
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }
}
