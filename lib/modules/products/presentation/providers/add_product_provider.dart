import 'package:flutter/material.dart';
import 'package:myapp/modules/products/domain/models/product_model.dart';
import 'package:myapp/modules/products/domain/usecases/add_product_usecase.dart';
import 'package:myapp/services/notifications/notification_service.dart';

class AddProductProvider extends ChangeNotifier {
  final AddProductUseCase addProductUseCase;

  AddProductProvider(this.addProductUseCase);

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  ProductUnit selectedUnit = ProductUnit.unid;
  DateTime? selectedDate;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome obrigatório';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty || double.tryParse(value) == null) {
      return 'Quantidade inválida';
    }
    return null;
  }

  String? validateMinStock(String? value) {
    if (value == null || value.isEmpty || double.tryParse(value) == null) {
      return 'Valor inválido';
    }
    return null;
  }

  void updateUnit(ProductUnit? unit) {
    if (unit != null) {
      selectedUnit = unit;
      notifyListeners();
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  Future<void> submitForm() async {
    if (formKey.currentState!.validate() && selectedDate != null) {
      final product = ProductModel(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        quantity: double.parse(quantityController.text),
        unit: selectedUnit,
        expirationDate: selectedDate!,
        minStock: double.parse(minStockController.text),
      );

      await addProductUseCase.execute(product);
      _scheduleNotifications(product);
      clearForm();
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    quantityController.clear();
    selectedUnit = ProductUnit.unid;
    selectedDate = null;
    notifyListeners();
  }

  void _scheduleNotifications(ProductModel product) {
    final notificationService = NotificationService();

    notificationService.scheduleExpirationNotification(
      id: product.id.hashCode,
      title: 'Validade Próxima',
      body: '${product.name} vence em 5 dias!',
      expirationDate: product.expirationDate,
    );
  }
}
