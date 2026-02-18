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
  late TextEditingController _quantityController;
  late TextEditingController _customerNameController;
  late TextEditingController _customerContactController;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _customerNameController = TextEditingController();
    _customerContactController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customerNameController.dispose();
    _customerContactController.dispose();
    super.dispose();
  }

  double get _totalPrice => widget.phone.price * _quantity;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sell Phone'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phone info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.phone.brand} ${widget.phone.model}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unit Price: ${NumberFormat('#,##0', 'en_US').format(widget.phone.price)} PKR',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Available Stock: ${widget.phone.stock}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: widget.phone.stock <= 5
                                ? Colors.orange
                                : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (widget.phone.imei1 != null || widget.phone.imei2 != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'IMEI: ${[widget.phone.imei1, widget.phone.imei2].where((e) => e != null).join(" / ")}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blueGrey,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Quantity input
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.shopping_cart),
                  helperText: 'Number of units to sell',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _quantity = int.tryParse(value) ?? 1;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Enter a valid quantity';
                  }
                  if (qty > widget.phone.stock) {
                    return 'Not enough stock (available: ${widget.phone.stock})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Customer info
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Customer Details (Optional)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
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
              // Total price
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${NumberFormat('#,##0', 'en_US').format(_totalPrice)} PKR',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'quantity': _quantity,
                'customerName': _customerNameController.text.isEmpty ? null : _customerNameController.text,
                'customerContact': _customerContactController.text.isEmpty ? null : _customerContactController.text,
              });
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Confirm Sale'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
