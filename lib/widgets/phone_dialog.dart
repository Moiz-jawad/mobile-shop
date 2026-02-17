import 'package:flutter/material.dart';
import '../models/phone.dart';

class PhoneDialog extends StatefulWidget {
  final Phone? phone;

  const PhoneDialog({super.key, this.phone});

  @override
  State<PhoneDialog> createState() => _PhoneDialogState();
}

class _PhoneDialogState extends State<PhoneDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.phone?.brand ?? '');
    _modelController = TextEditingController(text: widget.phone?.model ?? '');
    _priceController = TextEditingController(
        text: widget.phone?.price != null ? widget.phone!.price.toString() : '');
    _descController = TextEditingController(text: widget.phone?.description ?? '');
    _stockController = TextEditingController(
        text: widget.phone?.stock != null ? widget.phone!.stock.toString() : '10');
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.phone == null ? 'Add Phone' : 'Edit Phone'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter brand' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter model' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (PKR)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter price';
                  if (double.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter stock quantity';
                  final stock = int.tryParse(value);
                  if (stock == null) return 'Enter a valid number';
                  if (stock < 0) return 'Stock cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter description' : null,
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
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final phone = Phone(
                id: widget.phone?.id,
                brand: _brandController.text,
                model: _modelController.text,
                price: double.parse(_priceController.text),
                description: _descController.text,
                stock: int.parse(_stockController.text),
              );
              Navigator.pop(context, phone);
            }
          },
          child: Text(widget.phone == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
