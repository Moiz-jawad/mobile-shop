import 'package:flutter/material.dart';
import 'package:mobile_shop/models/sale.dart';
import 'package:mobile_shop/providers/sales_provider.dart';
import 'package:mobile_shop/services/export_service.dart';
import 'package:provider/provider.dart';
import '../providers/phone_provider.dart';
import '../widgets/phone_card.dart';
import '../widgets/phone_dialog.dart';
import '../widgets/sell_dialog.dart';
import '../screens/edit_phone_screen.dart';
import '../models/phone.dart';

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
    final result = await showDialog<Phone>(
      context: context,
      builder: (context) => PhoneDialog(phone: phone),
    );

    if (result != null && mounted) {
      final provider = context.read<PhoneProvider>();
      if (phone == null) {
        await provider.addPhone(result);
      } else {
        await provider.updatePhone(result);
      }
    }
  }

  void _navigateToEditScreen(Phone phone) async {
    final result = await Navigator.push<Phone>(
      context,
      MaterialPageRoute(builder: (context) => EditPhoneScreen(phone: phone)),
    );

    if (result != null && mounted) {
      await context.read<PhoneProvider>().updatePhone(result);
    }
  }

  void _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this phone record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<PhoneProvider>().deletePhone(id);
    }
  }

  void _handleSell(Phone phone) async {
    final quantity = await showDialog<int>(
      context: context,
      builder: (context) => SellDialog(phone: phone),
    );

    if (quantity != null && mounted) {
      final success = await context.read<PhoneProvider>().sellPhone(
        phone.id!,
        quantity,
      );

      if (success && mounted) {
        // Log the sale
        final sale = Sale(
          phoneId: phone.id!,
          phoneBrand: phone.brand,
          phoneModel: phone.model,
          quantity: quantity,
          unitPrice: phone.price,
          totalPrice: phone.price * quantity,
          timestamp: DateTime.now(),
        );
        await context.read<SalesProvider>().logSale(sale);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Sold $quantity unit(s) of ${phone.brand} ${phone.model}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Sale failed. Not enough stock.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
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
                  hintText: 'Search by brand, model or price...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<PhoneProvider>(
                  builder: (context, provider, child) {
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
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: provider.phones.length,
                      itemBuilder: (context, index) {
                        final phone = provider.phones[index];
                        return PhoneCard(
                          phone: phone,
                          onEdit: () => _navigateToEditScreen(phone),
                          onDelete: () => _confirmDelete(phone.id!),
                          onSell: () => _handleSell(phone),
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
