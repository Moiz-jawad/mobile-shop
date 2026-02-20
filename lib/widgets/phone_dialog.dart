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
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _descController;
  late TextEditingController _imei1Controller;
  late TextEditingController _imei2Controller;
  late TextEditingController _colorController;
  late TextEditingController _storageController;
  late TextEditingController _batteryHealthController;
  String _condition = 'New';

  @override
  void initState() {
    super.initState();
    final p = widget.phone;
    _brandController = TextEditingController(text: p?.brand ?? widget.initialBrand ?? '');
    _modelController = TextEditingController(text: p?.model ?? '');
    _purchasePriceController = TextEditingController(
        text: p?.purchasePrice != null && p!.purchasePrice > 0 ? p.purchasePrice.toString() : '');
    _sellingPriceController = TextEditingController(
        text: p?.sellingPrice != null && p!.sellingPrice > 0 ? p.sellingPrice.toString() : '');
    _descController = TextEditingController(text: p?.description ?? '');
    _imei1Controller = TextEditingController(text: p?.imei1 ?? '');
    _imei2Controller = TextEditingController(text: p?.imei2 ?? '');
    _colorController = TextEditingController(text: p?.color ?? '');
    _storageController = TextEditingController(text: p?.storage ?? '');
    _batteryHealthController = TextEditingController(text: p?.batteryHealth ?? '');
    _condition = p?.condition ?? 'New';
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final phone = Phone(
        id: widget.phone?.id,
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
        status: widget.phone?.status ?? 'available',
        dateAdded: widget.phone?.dateAdded ?? DateTime.now(),
      );
      Navigator.of(context).pop(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.phone != null;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Phone' : 'Add New Phone',
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
            // Scrollable form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // --- Device Identity ---
                      _sectionLabel(context, '📱 Device Identity'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _brandController,
                              decoration: const InputDecoration(labelText: 'Brand *'),
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: const InputDecoration(labelText: 'Model *'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imei1Controller,
                        decoration: InputDecoration(
                          labelText: 'IMEI 1 *',
                          prefixIcon: const Icon(Icons.fingerprint),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: () => _scanBarcode(_imei1Controller),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.trim().isEmpty ? 'IMEI is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imei2Controller,
                        decoration: InputDecoration(
                          labelText: 'IMEI 2 (optional)',
                          prefixIcon: const Icon(Icons.fingerprint),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: () => _scanBarcode(_imei2Controller),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 16),
                      // --- Specifications ---
                      _sectionLabel(context, '⚙️ Specifications'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _condition,
                              decoration: const InputDecoration(labelText: 'Condition *'),
                              items: const [
                                DropdownMenuItem(value: 'New', child: Text('New')),
                                DropdownMenuItem(value: 'Used', child: Text('Used')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _condition = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _colorController,
                              decoration: const InputDecoration(labelText: 'Color'),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _storageController,
                              decoration: const InputDecoration(
                                labelText: 'Storage',
                                hintText: 'e.g. 128GB',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_condition == 'Used' && _isAppleBrand())
                            Expanded(
                              child: TextFormField(
                                controller: _batteryHealthController,
                                decoration: const InputDecoration(
                                  labelText: 'Battery Health',
                                  hintText: 'e.g. 85%',
                                ),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // --- Pricing ---
                      _sectionLabel(context, '💰 Pricing'),
                      const SizedBox(height: 8),
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
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (double.tryParse(v.trim()) == null) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _sellingPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Selling Price (PKR) *',
                                prefixIcon: Icon(Icons.sell),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (double.tryParse(v.trim()) == null) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // --- Notes ---
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed bottom action buttons
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
                    label: Text(isEditing ? 'Save Changes' : 'Add Phone'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isAppleBrand() {
    final brand = _brandController.text.trim().toLowerCase();
    return brand.contains('apple') || brand.contains('iphone');
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  void _scanBarcode(TextEditingController controller) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerDialog()),
    );
    if (result != null && mounted) {
      controller.text = result;
    }
  }
}
