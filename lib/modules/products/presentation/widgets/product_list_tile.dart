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
  final Stream<double> dailyAverageStream;

  const ProductListTile({
    super.key,
    required this.product,
    required this.usageStream,
    required this.dailyAverageStream,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
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
            StreamBuilder<double>(
              stream: dailyAverageStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data! <= 0) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      'Previsão: Insira dados de consumo',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                }

                final dailyAverage = snapshot.data!;
                final daysRemaining = product.quantity / dailyAverage;
                final forecastDate = DateTime.now().add(
                  Duration(days: daysRemaining.ceil()),
                );

                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_graph,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Previsão de término: ${DateFormat('dd/MM/yyyy').format(forecastDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getForecastColor(
                            forecastDate,
                            product.expirationDate,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getForecastColor(DateTime forecastDate, DateTime expirationDate) {
    if (forecastDate.isAfter(expirationDate)) return Colors.red;
    if (forecastDate.difference(DateTime.now()).inDays < 7)
      return Colors.orange;
    return Colors.green;
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
            decoration: const InputDecoration(
              labelText: 'Quantidade Usada',
              hintText: 'Ex: 2.5',
            ),
            validator: provider.validateQuantity,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed:
                  () => provider.recordUsage(product.id, product.unit, context),
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }
}
