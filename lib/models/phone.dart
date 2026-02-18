class Phone {
  final int? id;

  // Identity
  final String brand;
  final String model;
  final String imei1;       // Required - primary IMEI
  final String? imei2;      // Optional - dual SIM

  // Specifications
  final String condition;   // 'New' or 'Used'
  final String? color;      // Black, White, Gold, etc.
  final String? storage;    // 64GB, 128GB, 256GB, etc.
  final String? batteryHealth; // For used phones: "85%", "92%"

  // Pricing
  final double purchasePrice;  // What the shop paid
  final double sellingPrice;   // Listed price for customer

  // Lifecycle
  final String status;         // 'available', 'sold', 'returned', 'defective'
  final DateTime dateAdded;
  final DateTime? dateSold;

  // Notes
  final String? description;

  Phone({
    this.id,
    required this.brand,
    required this.model,
    required this.imei1,
    this.imei2,
    required this.condition,
    this.color,
    this.storage,
    this.batteryHealth,
    required this.purchasePrice,
    required this.sellingPrice,
    this.status = 'available',
    DateTime? dateAdded,
    this.dateSold,
    this.description,
  }) : dateAdded = dateAdded ?? DateTime.now();

  /// Profit margin for this phone
  double get profit => sellingPrice - purchasePrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'imei1': imei1,
      'imei2': imei2,
      'condition': condition,
      'color': color,
      'storage': storage,
      'batteryHealth': batteryHealth,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'status': status,
      'dateAdded': dateAdded.toIso8601String(),
      'dateSold': dateSold?.toIso8601String(),
      'description': description,
    };
  }

  factory Phone.fromMap(Map<String, dynamic> map) {
    return Phone(
      id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
      brand: (map['brand'] ?? '').toString(),
      model: (map['model'] ?? '').toString(),
      imei1: (map['imei1'] ?? '').toString(),
      imei2: _nullableString(map['imei2']),
      condition: (map['condition'] ?? 'New').toString(),
      color: _nullableString(map['color']),
      storage: _nullableString(map['storage']),
      batteryHealth: _nullableString(map['batteryHealth']),
      purchasePrice: _parseDouble(map['purchasePrice']),
      sellingPrice: _parseDouble(map['sellingPrice'] ?? map['price']),
      status: (map['status'] ?? 'available').toString(),
      dateAdded: DateTime.tryParse(map['dateAdded']?.toString() ?? '') ?? DateTime.now(),
      dateSold: DateTime.tryParse(map['dateSold']?.toString() ?? ''),
      description: _nullableString(map['description']),
    );
  }

  Phone copyWith({
    int? id,
    String? brand,
    String? model,
    String? imei1,
    String? imei2,
    String? condition,
    String? color,
    String? storage,
    String? batteryHealth,
    double? purchasePrice,
    double? sellingPrice,
    String? status,
    DateTime? dateAdded,
    DateTime? dateSold,
    String? description,
  }) {
    return Phone(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      imei1: imei1 ?? this.imei1,
      imei2: imei2 ?? this.imei2,
      condition: condition ?? this.condition,
      color: color ?? this.color,
      storage: storage ?? this.storage,
      batteryHealth: batteryHealth ?? this.batteryHealth,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      status: status ?? this.status,
      dateAdded: dateAdded ?? this.dateAdded,
      dateSold: dateSold ?? this.dateSold,
      description: description ?? this.description,
    );
  }

  // Helper parsers
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }
}
