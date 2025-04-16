import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/modules/products/data/repositories/product_usage_repository.dart';
import 'package:myapp/modules/products/domain/usecases/record_usage_usecase.dart';
import 'package:myapp/modules/products/presentation/pages/home_page.dart';
import 'package:myapp/modules/products/presentation/pages/products_list_page.dart';
import 'package:myapp/modules/products/presentation/providers/usage_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'modules/products/presentation/pages/register_product_page.dart'; // Importe a página de cadastro

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<ProductUsageRepository>(
          create:
              (context) =>
                  ProductUsageRepository(context.read<FirebaseFirestore>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => UsageProvider(
                RecordUsageUseCase(context.read<ProductUsageRepository>()),
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(), // Página inicial com navegação
      routes: {
        '/register': (context) => const RegisterProductPage(),
        '/list': (context) => const ProductsListPage(),
      },
    );
  }
}
