import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
  final String name;
  final String purchaseDate;
  final String expiryDate;
  final int? warrantyMonths;
  final String category;
  final int? notificationId;
  
  const Product({
    this.id,
    required this.name,
    required this.purchaseDate,
    required this.expiryDate,
    this.warrantyMonths,
    required this.category,
    this.notificationId,
  });
  
  /// Convert Product to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purchase_date': purchaseDate,
      'expiry_date': expiryDate,
      'warranty_months': warrantyMonths,
      'category': category,
      'notification_id': notificationId,
    };
  }
  
  /// Create Product from Map (database query result)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      purchaseDate: map['purchase_date'] as String,
      expiryDate: map['expiry_date'] as String,
      warrantyMonths: map['warranty_months'] as int?,
      category: map['category'] as String,
      notificationId: map['notification_id'] as int?,
    );
  }
  
  /// Create a copy of Product with some fields updated
  Product copyWith({
    int? id,
    String? name,
    String? purchaseDate,
    String? expiryDate,
    int? warrantyMonths,
    String? category,
    int? notificationId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      category: category ?? this.category,
      notificationId: notificationId ?? this.notificationId,
    );
  }
  
  /// Convert to JSON for backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'purchase_date': purchaseDate,
      'expiry_date': expiryDate,
      'warranty_months': warrantyMonths,
      'category': category,
      'notification_id': notificationId,
    };
  }
  
  /// Create from JSON for restore
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String,
      purchaseDate: json['purchase_date'] as String,
      expiryDate: json['expiry_date'] as String,
      warrantyMonths: json['warranty_months'] as int?,
      category: json['category'] as String,
      notificationId: json['notification_id'] as int?,
    );
  }
  
  @override
  List<Object?> get props => [id, name, purchaseDate, expiryDate, warrantyMonths, category, notificationId];
  
  @override
  String toString() {
    return 'Product{id: $id, name: $name, category: $category, purchaseDate: $purchaseDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths}';
  }
}
