class Sale {
  final int? id;
  final int phoneId;
  final String phoneBrand;
  final String phoneModel;
  final String phoneImei;       // Exact device sold
  final double purchasePrice;   // What shop paid (for profit calc)
  final double sellingPrice;    // What customer paid
  final double profit;          // sellingPrice - purchasePrice
  final String? paymentMethod;  // 'Cash', 'Card', 'Installment'
  final DateTime timestamp;
  final String? customerName;
  final String? customerContact;

  Sale({
    this.id,
    required this.phoneId,
    required this.phoneBrand,
    required this.phoneModel,
    required this.phoneImei,
    required this.purchasePrice,
    required this.sellingPrice,
    double? profit,
    this.paymentMethod,
    required this.timestamp,
    this.customerName,
    this.customerContact,
  }) : profit = profit ?? (sellingPrice - purchasePrice);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneId': phoneId,
      'phoneBrand': phoneBrand,
      'phoneModel': phoneModel,
      'phoneImei': phoneImei,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'profit': profit,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
      'customerName': customerName,
      'customerContact': customerContact,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    final sellingPrice = _parseDouble(map['sellingPrice'] ?? map['totalPrice'] ?? map['unitPrice']);
    final purchasePrice = _parseDouble(map['purchasePrice']);
    
    return Sale(
      id: map['id'],
      phoneId: map['phoneId'] is int ? map['phoneId'] : int.tryParse('${map['phoneId']}') ?? 0,
      phoneBrand: (map['phoneBrand'] ?? '').toString(),
      phoneModel: (map['phoneModel'] ?? '').toString(),
      phoneImei: (map['phoneImei'] ?? '').toString(),
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      profit: _parseDouble(map['profit']),
      paymentMethod: map['paymentMethod']?.toString(),
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
      customerName: map['customerName']?.toString(),
      customerContact: map['customerContact']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
