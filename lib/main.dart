import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_shop/providers/phone_provider.dart';
import 'package:mobile_shop/providers/sales_provider.dart';
import 'package:mobile_shop/providers/sync_provider.dart';
import 'package:mobile_shop/services/sync_service.dart';
import 'package:mobile_shop/providers/theme_provider.dart';
import 'package:mobile_shop/services/hive_service.dart';
import 'package:mobile_shop/services/sales_service.dart';
import 'package:mobile_shop/widgets/app_navigation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await HiveService.init();
  await SalesService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhoneProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize sync only once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final syncProvider = context.read<SyncProvider>();
      await syncProvider.init();

      // After sync completes, reload providers so UI reflects cloud data
      syncProvider.addListener(() {
        if (syncProvider.state == SyncState.synced) {
          context.read<PhoneProvider>().loadPhones();
          context.read<SalesProvider>().loadSales();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Shop Manager',
      themeMode: themeProvider.themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const AppNavigation(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: brightness,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.teal.withValues(alpha: 0.1)
            : Colors.teal.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
