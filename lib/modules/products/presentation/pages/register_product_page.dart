import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/product_model.dart';
import '../providers/add_product_provider.dart';
import '../../data/repositories/firebase_product_repository.dart';
import '../../domain/usecases/add_product_usecase.dart';

class RegisterProductPage extends StatelessWidget {
  const RegisterProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => AddProductProvider(
            AddProductUseCase(
              FirebaseProductRepository(FirebaseFirestore.instance),
            ),
          ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cadastrar Produto')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _ProductForm(),
        ),
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddProductProvider>(context);

    return Form(
      key: provider.formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: provider.nameController,
            decoration: const InputDecoration(labelText: 'Nome do Produto'),
            validator: provider.validateName,
          ),
          TextFormField(
            controller: provider.descriptionController,
            decoration: const InputDecoration(labelText: 'Descrição'),
            maxLines: 3,
          ),
          TextFormField(
            controller: provider.quantityController,
            decoration: const InputDecoration(labelText: 'Quantidade'),
            keyboardType: TextInputType.number,
            validator: provider.validateQuantity,
          ),
          DropdownButtonFormField<ProductUnit>(
            value: provider.selectedUnit,
            items:
                ProductUnit.values.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit.name.toUpperCase()),
                  );
                }).toList(),
            onChanged: provider.updateUnit,
            decoration: const InputDecoration(labelText: 'Unidade'),
          ),
          ListTile(
            title: Text(
              provider.selectedDate == null
                  ? 'Selecione a data de validade'
                  : 'Data: ${DateFormat('dd/MM/yyyy').format(provider.selectedDate!)}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => provider.pickDate(context),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: provider.submitForm,
            child: const Text('Cadastrar Produto'),
          ),
        ],
      ),
    );
  }
}
