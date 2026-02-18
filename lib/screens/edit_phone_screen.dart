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
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _descController;
  late TextEditingController _imei1Controller;
  late TextEditingController _imei2Controller;
  late TextEditingController _colorController;
  late TextEditingController _storageController;
  late TextEditingController _batteryHealthController;
  late String _condition;

  @override
  void initState() {
    super.initState();
    final p = widget.phone;
    _brandController = TextEditingController(text: p.brand);
    _modelController = TextEditingController(text: p.model);
    _purchasePriceController = TextEditingController(text: p.purchasePrice.toString());
    _sellingPriceController = TextEditingController(text: p.sellingPrice.toString());
    _descController = TextEditingController(text: p.description ?? '');
    _imei1Controller = TextEditingController(text: p.imei1);
    _imei2Controller = TextEditingController(text: p.imei2 ?? '');
    _colorController = TextEditingController(text: p.color ?? '');
    _storageController = TextEditingController(text: p.storage ?? '');
    _batteryHealthController = TextEditingController(text: p.batteryHealth ?? '');
    _condition = p.condition;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _descController.dispose();
    _imei1Controller.dispose();
    _imei2Controller.dispose();
    _colorController.dispose();
    _storageController.dispose();
    _batteryHealthController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedPhone = widget.phone.copyWith(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        imei1: _imei1Controller.text.trim(),
        imei2: _imei2Controller.text.trim().isEmpty ? null : _imei2Controller.text.trim(),
        condition: _condition,
        color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        storage: _storageController.text.trim().isEmpty ? null : _storageController.text.trim(),
        batteryHealth: _batteryHealthController.text.trim().isEmpty ? null : _batteryHealthController.text.trim(),
        purchasePrice: double.parse(_purchasePriceController.text.trim()),
        sellingPrice: double.parse(_sellingPriceController.text.trim()),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
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
                // Device Identity
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📱 Device Identity',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand *',
                            prefixIcon: Icon(Icons.business),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model *',
                            prefixIcon: Icon(Icons.phone_android),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _imei1Controller,
                          decoration: const InputDecoration(
                            labelText: 'IMEI 1 *',
                            prefixIcon: Icon(Icons.fingerprint),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'IMEI is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _imei2Controller,
                          decoration: const InputDecoration(
                            labelText: 'IMEI 2 (optional)',
                            prefixIcon: Icon(Icons.fingerprint),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Specifications
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚙️ Specifications',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _condition,
                          decoration: const InputDecoration(
                            labelText: 'Condition *',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'New', child: Text('New')),
                            DropdownMenuItem(value: 'Used', child: Text('Used')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _condition = v);
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _colorController,
                                decoration: const InputDecoration(
                                  labelText: 'Color',
                                  prefixIcon: Icon(Icons.palette),
                                ),
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _storageController,
                                decoration: const InputDecoration(
                                  labelText: 'Storage',
                                  prefixIcon: Icon(Icons.storage),
                                  hintText: '128GB',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_condition == 'Used' && (_brandController.text.trim().toLowerCase().contains('apple') || _brandController.text.trim().toLowerCase().contains('iphone'))) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _batteryHealthController,
                            decoration: const InputDecoration(
                              labelText: 'Battery Health',
                              prefixIcon: Icon(Icons.battery_full),
                              hintText: '85%',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pricing
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💰 Pricing',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _purchasePriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Purchase Price (PKR) *',
                                  prefixIcon: Icon(Icons.shopping_bag),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (double.tryParse(v) == null) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _sellingPriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Selling Price (PKR) *',
                                  prefixIcon: Icon(Icons.sell),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (double.tryParse(v) == null) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        prefixIcon: Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom buttons
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
                    FilledButton.icon(
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
