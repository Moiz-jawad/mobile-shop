import 'package:flutter/material.dart';
import '../models/phone.dart';

class EditPhoneScreen extends StatefulWidget {
  final Phone phone;

  const EditPhoneScreen({super.key, required this.phone});

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _stockController;
  late String _condition;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.phone.brand);
    _modelController = TextEditingController(text: widget.phone.model);
    _priceController = TextEditingController(text: widget.phone.price.toString());
    _descController = TextEditingController(text: widget.phone.description);
    _stockController = TextEditingController(text: widget.phone.stock.toString());
    _condition = widget.phone.condition;
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedPhone = Phone(
        id: widget.phone.id,
        brand: _brandController.text,
        model: _modelController.text,
        price: double.parse(_priceController.text),
        condition: _condition,
        description: _descController.text,
        stock: int.parse(_stockController.text),
      );
      Navigator.pop(context, updatedPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Phone'),
        actions: [
          TextButton.icon(
            onPressed: _saveChanges,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand',
                            prefixIcon: Icon(Icons.business),
                            helperText: 'e.g., Apple, Samsung, Google',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter brand'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model',
                            prefixIcon: Icon(Icons.phone_android),
                            helperText: 'e.g., iPhone 15 Pro, Galaxy S24',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter model'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _condition,
                          decoration: const InputDecoration(
                            labelText: 'Condition',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'New', child: Text('New')),
                            DropdownMenuItem(value: 'Used', child: Text('Used')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _condition = value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Price (PKR)',
                                  prefixIcon: Icon(Icons.payments_outlined),
                                  helperText: 'Unit price',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter price';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Enter a valid number';
                                  }
                                  if (double.parse(value) <= 0) {
                                    return 'Price must be positive';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _stockController,
                                decoration: const InputDecoration(
                                  labelText: 'Stock Quantity',
                                  prefixIcon: Icon(Icons.inventory_2),
                                  helperText: 'Available units',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter stock';
                                  }
                                  final stock = int.tryParse(value);
                                  if (stock == null) {
                                    return 'Enter a valid number';
                                  }
                                  if (stock < 0) {
                                    return 'Cannot be negative';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description),
                            helperText: 'Product details and features',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter description'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
