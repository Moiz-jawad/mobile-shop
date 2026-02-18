// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/phone.dart';
import '../models/sale.dart';
import '../providers/phone_provider.dart';
import '../providers/sales_provider.dart';
import '../services/export_service.dart';
import '../widgets/phone_card.dart';
import '../widgets/phone_dialog.dart';
import '../widgets/sell_dialog.dart';
import 'edit_phone_screen.dart';

class BrandInventoryScreen extends StatefulWidget {
  final String brandName;

  const BrandInventoryScreen({super.key, required this.brandName});

  @override
  State<BrandInventoryScreen> createState() => _BrandInventoryScreenState();
}

class _BrandInventoryScreenState extends State<BrandInventoryScreen> {
  String _searchQuery = '';

  void _navigateToEditScreen(Phone phone) async {
    final result = await Navigator.push<Phone>(
      context,
      MaterialPageRoute(builder: (context) => EditPhoneScreen(phone: phone)),
    );

    if (result != null && mounted) {
      try {
        await context.read<PhoneProvider>().updatePhone(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Phone updated'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this phone record?'),
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
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SellDialog(phone: phone),
    );

    if (result != null && mounted) {
      // Mark phone as sold
      await context.read<PhoneProvider>().markAsSold(phone.id!);

      // Log the sale
      final sale = Sale(
        phoneId: phone.id!,
        phoneBrand: phone.brand,
        phoneModel: phone.model,
        phoneImei: phone.imei1,
        purchasePrice: phone.purchasePrice,
        sellingPrice: phone.sellingPrice,
        paymentMethod: result['paymentMethod'],
        timestamp: DateTime.now(),
        customerName: result['customerName'],
        customerContact: result['customerContact'],
      );
      await context.read<SalesProvider>().logSale(sale);

      // Show receipt option
      _showReceiptOption(sale, phone);
    }
  }

  void _showReceiptOption(Sale sale, Phone phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Sale confirmed!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'PRINT RECEIPT',
          textColor: Colors.white,
          onPressed: () {
            PdfExportService.exportReceipt(sale, phone);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brandName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by model, IMEI, color...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: Consumer<PhoneProvider>(
        builder: (context, provider, child) {
          // Filter: only available phones for this brand, matching search query
          final phones = provider.allPhones.where((p) {
            if (p.brand != widget.brandName) return false;
            if (p.status != 'available') return false;

            if (_searchQuery.isEmpty) return true;

            final query = _searchQuery.toLowerCase();
            return p.model.toLowerCase().contains(query) ||
                p.imei1.toLowerCase().contains(query) ||
                (p.imei2?.toLowerCase().contains(query) ?? false) ||
                (p.color?.toLowerCase().contains(query) ?? false) ||
                (p.storage?.toLowerCase().contains(query) ?? false) ||
                p.sellingPrice.toString().contains(query);
          }).toList();

          if (phones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mobile_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No available phones for ${widget.brandName}',
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
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: phones.length,
            itemBuilder: (context, index) {
              final phone = phones[index];
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPhoneDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPhoneDialog(BuildContext context) async {
    final result = await showDialog<Phone>(
      context: context,
      builder: (context) => PhoneDialog(initialBrand: widget.brandName),
    );

    if (result != null && mounted) {
      final provider = context.read<PhoneProvider>();
      final messenger = ScaffoldMessenger.of(context);
      try {
        await provider.addPhone(result);
        messenger.showSnackBar(
          const SnackBar(content: Text('✅ Phone added successfully'), backgroundColor: Colors.green),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
