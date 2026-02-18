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
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SellDialog(phone: phone),
    );
    
    if (result != null && mounted) {
      final int quantity = result['quantity'];
      final String? customerName = result['customerName'];
      final String? customerContact = result['customerContact'];

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
          customerName: customerName,
          customerContact: customerContact,
        );
        await context.read<SalesProvider>().logSale(sale);
        
        // Show option to print receipt
        _showReceiptOption(sale, phone);
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
                hintText: 'Search ${widget.brandName} phones...',
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
          // Filter phones by brand and search query using UNFILTERED list
          final phones = provider.allPhones.where((p) {
            final matchesBrand = p.brand == widget.brandName;
            if (!matchesBrand) return false;

            if (_searchQuery.isEmpty) return true;

            final query = _searchQuery.toLowerCase();
            return p.model.toLowerCase().contains(query) ||
                p.price.toString().contains(query) ||
                (p.imei1?.toLowerCase().contains(query) ?? false) ||
                (p.imei2?.toLowerCase().contains(query) ?? false);
          }).toList();

          if (phones.isEmpty) {
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
                    'No phones found for ${widget.brandName}',
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
      builder: (context) => PhoneDialog(
        initialBrand: widget.brandName,
      ),
    );

    if (result != null && mounted) {
      final provider = context.read<PhoneProvider>();
      final messenger = ScaffoldMessenger.of(context);
      try {
        await provider.addPhone(result);
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('✅ Phone added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('❌ Error adding phone: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
