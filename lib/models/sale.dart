class Sale {
  final int? id;
  final int phoneId;
  final String phoneBrand;
  final String phoneModel;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime timestamp;

  Sale({
    this.id,
    required this.phoneId,
    required this.phoneBrand,
    required this.phoneModel,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneId': phoneId,
      'phoneBrand': phoneBrand,
      'phoneModel': phoneModel,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      phoneId: map['phoneId'],
      phoneBrand: map['phoneBrand'],
      phoneModel: map['phoneModel'],
      quantity: map['quantity'],
      unitPrice: (map['unitPrice'] as num).toDouble(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
