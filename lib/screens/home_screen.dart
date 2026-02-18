import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/export_service.dart';
import '../providers/phone_provider.dart';
import '../widgets/phone_dialog.dart';
import '../models/phone.dart';
import '../providers/theme_provider.dart';
import '../widgets/brand_card.dart';
import 'brand_inventory_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhoneProvider>().loadPhones();
    });
  }

  /// Public method to show add phone dialog - can be called externally
  void showAddPhoneDialog() {
    _showPhoneDialog();
  }

  void _showPhoneDialog({Phone? phone}) async {
    debugPrint('📋 _showPhoneDialog called. Editing: ${phone != null}');
    
    final result = await showDialog<Phone>(
      context: context,
      builder: (ctx) => PhoneDialog(phone: phone),
    );

    debugPrint('📋 Dialog result: ${result != null ? "${result.brand} ${result.model}" : "NULL (user cancelled)"}');

    if (result != null && mounted) {
      final provider = context.read<PhoneProvider>();
      final messenger = ScaffoldMessenger.of(context);
      try {
        if (phone == null) {
          debugPrint('📋 Calling provider.addPhone...');
          await provider.addPhone(result);
          debugPrint('📋 provider.addPhone completed! phones count: ${provider.allPhones.length}');
          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('✅ Phone added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await provider.updatePhone(result);
          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('✅ Phone updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('❌ Error in _showPhoneDialog: $e');
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('❌ Error saving phone: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Inventory',
            onPressed: () async {
              final phones = context.read<PhoneProvider>().phones;
              if (phones.isNotEmpty) {
                await PdfExportService.exportInventory(phones);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No inventory to export')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) =>
                    context.read<PhoneProvider>().setSearchQuery(value),
                decoration: const InputDecoration(
                  hintText: 'Search by brand, model, IMEI, color...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<PhoneProvider>(
                  builder: (context, provider, child) {
                    debugPrint('🔄 Consumer rebuilding. phones: ${provider.phones.length}, allPhones: ${provider.allPhones.length}, isLoading: ${provider.isLoading}');
                    
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.phones.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mobile_off_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No records found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap the + button to add your first phone',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Group phones by brand
                    final Map<String, int> brandCounts = {};
                    for (var phone in provider.phones) {
                      brandCounts[phone.brand] = (brandCounts[phone.brand] ?? 0) + 1;
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: brandCounts.length,
                          itemBuilder: (context, index) {
                            final brand = brandCounts.keys.elementAt(index);
                            final count = brandCounts[brand]!;
                            return BrandCard(
                              brandName: brand,
                              itemCount: count,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BrandInventoryScreen(brandName: brand),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPhoneDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Phone'),
      ),
    );
  }
}
