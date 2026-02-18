import 'package:flutter/material.dart';
import '../models/phone.dart';
import 'barcode_scanner_dialog.dart';

class PhoneDialog extends StatefulWidget {
  final Phone? phone;
  final String? initialBrand;

  const PhoneDialog({super.key, this.phone, this.initialBrand});

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
  late TextEditingController _imei1Controller;
  late TextEditingController _imei2Controller;
  String _condition = 'New';

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(
        text: widget.phone?.brand ?? widget.initialBrand ?? '');
    _modelController = TextEditingController(text: widget.phone?.model ?? '');
    _priceController = TextEditingController(
        text: widget.phone?.price != null ? widget.phone!.price.toString() : '');
    _descController = TextEditingController(text: widget.phone?.description ?? '');
    _stockController = TextEditingController(
        text: widget.phone?.stock != null ? widget.phone!.stock.toString() : '10');
    _imei1Controller = TextEditingController(text: widget.phone?.imei1 ?? '');
    _imei2Controller = TextEditingController(text: widget.phone?.imei2 ?? '');
    _condition = widget.phone?.condition ?? 'New';
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _stockController.dispose();
    _imei1Controller.dispose();
    _imei2Controller.dispose();
    super.dispose();
  }

  void _submitForm() {
    debugPrint('📝 Submit button pressed');
    if (_formKey.currentState!.validate()) {
      debugPrint('📝 Form validated successfully');
      final phone = Phone(
        id: widget.phone?.id,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        condition: _condition,
        description: _descController.text.trim(),
        stock: int.parse(_stockController.text.trim()),
        imei1: _imei1Controller.text.trim().isEmpty ? null : _imei1Controller.text.trim(),
        imei2: _imei2Controller.text.trim().isEmpty ? null : _imei2Controller.text.trim(),
      );
      debugPrint('📝 Phone created: ${phone.brand} ${phone.model}, price: ${phone.price}');
      Navigator.of(context).pop(phone);
      debugPrint('📝 Navigator.pop called with phone');
    } else {
      debugPrint('📝 Form validation FAILED');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.phone != null;
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Phone' : 'Add Phone',
                      style: Theme.of(context).textTheme.titleLarge,
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
            // Scrollable form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: 'Brand *',
                          prefixIcon: Icon(Icons.phone_android),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: 'Model *',
                          prefixIcon: Icon(Icons.devices),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _condition,
                              decoration: const InputDecoration(labelText: 'Condition'),
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
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              decoration: const InputDecoration(
                                labelText: 'Stock *',
                                prefixIcon: Icon(Icons.inventory_2),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Required';
                                final stock = int.tryParse(value.trim());
                                if (stock == null) return 'Invalid';
                                if (stock < 0) return 'Min 0';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (PKR) *',
                          prefixIcon: Icon(Icons.payments),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Required';
                          if (double.tryParse(value.trim()) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imei1Controller,
                        decoration: InputDecoration(
                          labelText: 'IMEI 1 (optional)',
                          prefixIcon: const Icon(Icons.numbers),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: () => _scanBarcode(_imei1Controller),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imei2Controller,
                        decoration: InputDecoration(
                          labelText: 'IMEI 2 (optional)',
                          prefixIcon: const Icon(Icons.numbers),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: () => _scanBarcode(_imei2Controller),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed bottom action buttons - ALWAYS visible
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
                    onPressed: _submitForm,
                    icon: Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(isEditing ? 'Save' : 'Add Phone'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scanBarcode(TextEditingController controller) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerDialog()),
    );
    if (result != null) {
      controller.text = result;
    }
  }
}
