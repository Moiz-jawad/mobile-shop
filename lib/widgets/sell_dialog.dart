import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/phone.dart';

class SellDialog extends StatefulWidget {
  final Phone phone;

  const SellDialog({super.key, required this.phone});

  @override
  State<SellDialog> createState() => _SellDialogState();
}

class _SellDialogState extends State<SellDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _customerContactController;
  String _paymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController();
    _customerContactController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.phone;
    final profit = phone.sellingPrice - phone.purchasePrice;
    final isProfit = profit >= 0;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 550),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.sell, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Confirm Sale',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Phone info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${phone.brand} ${phone.model}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            if (phone.color != null || phone.storage != null)
                              Text(
                                [phone.color, phone.storage].where((e) => e != null).join(' • '),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'IMEI: ${phone.imei1}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.blueGrey,
                                    fontFamily: 'monospace',
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price & Profit
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isProfit ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isProfit ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Selling Price:'),
                                Text(
                                  '${NumberFormat('#,##0', 'en_US').format(phone.sellingPrice)} PKR',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Purchase Price:'),
                                Text(
                                  '${NumberFormat('#,##0', 'en_US').format(phone.purchasePrice)} PKR',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isProfit ? '📈 Profit:' : '📉 Loss:',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${NumberFormat('#,##0', 'en_US').format(profit.abs())} PKR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isProfit ? Colors.green[700] : Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment method
                      DropdownButtonFormField<String>(
                        initialValue: _paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Cash', child: Text('💵 Cash')),
                          DropdownMenuItem(value: 'Card', child: Text('💳 Card')),
                          DropdownMenuItem(value: 'Installment', child: Text('📋 Installment')),
                          DropdownMenuItem(value: 'Bank Transfer', child: Text('🏦 Bank Transfer')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _paymentMethod = v);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Customer details
                      Text(
                        'Customer Details (Optional)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customerContactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed bottom buttons
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'paymentMethod': _paymentMethod,
                        'customerName': _customerNameController.text.isEmpty
                            ? null
                            : _customerNameController.text.trim(),
                        'customerContact': _customerContactController.text.isEmpty
                            ? null
                            : _customerContactController.text.trim(),
                      });
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm Sale'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
