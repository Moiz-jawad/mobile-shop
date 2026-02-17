class Phone {
  final int? id;
  final String brand;
  final String model;
  final double price;
  final String description;
  final int stock;

  Phone({
    this.id,
    required this.brand,
    required this.model,
    required this.price,
    required this.description,
    this.stock = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'price': price,
      'description': description,
      'stock': stock,
    };
  }

  factory Phone.fromMap(Map<String, dynamic> map) {
    final rawPrice = map['price'];
    final double parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

    final rawStock = map['stock'];
    final int parsedStock = rawStock is int
        ? rawStock
        : int.tryParse(rawStock?.toString() ?? '') ?? 10;

    return Phone(
      id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
      brand: (map['brand'] ?? '').toString(),
      model: (map['model'] ?? '').toString(),
      price: parsedPrice,
      description: (map['description'] ?? '').toString(),
      stock: parsedStock,
    );
  }

  Phone copyWith({
    int? id,
    String? brand,
    String? model,
    double? price,
    String? description,
    int? stock,
  }) {
    return Phone(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      price: price ?? this.price,
      description: description ?? this.description,
      stock: stock ?? this.stock,
    );
  }
}
