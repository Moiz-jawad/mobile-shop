import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_shop/providers/phone_provider.dart';
import 'package:mobile_shop/providers/sales_provider.dart';
import 'package:mobile_shop/services/hive_service.dart';
import 'package:mobile_shop/services/sales_service.dart';
import 'package:mobile_shop/widgets/app_navigation.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive once for the whole app
  await Hive.initFlutter();
  
  await HiveService.init();
  await SalesService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhoneProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
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
      debugShowCheckedModeBanner: false,
      title: 'Mobile Shop Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.teal.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AppNavigation(),
    );
  }
}
