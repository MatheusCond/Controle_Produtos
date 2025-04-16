import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:provider/provider.dart';
import '../../domain/models/product_usage.dart';
import '../providers/usage_provider.dart';

class UsageHistoryDialog extends StatelessWidget {
  final String productId;
  final Stream<List<ProductUsage>> usageStream;

  const UsageHistoryDialog({
    super.key,
    required this.productId,
    required this.usageStream,
  });

  String _getUnitSymbol(ProductUnit unit) {
    return switch (unit) {
      ProductUnit.kg => 'kg',
      ProductUnit.liters => 'litros',
      ProductUnit.unid => 'unid',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Histórico de Uso'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<ProductUsage>>(
          stream: usageStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Erro: ${snapshot.error}');
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final usages = snapshot.data!;

            return ListView.builder(
              itemCount: usages.length,
              itemBuilder: (context, index) {
                final usage = usages[index];
                return ListTile(
                  title: Text(
                    '${usage.quantityUsed} ${_getUnitSymbol(usage.unit)}',
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(usage.timestamp),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
