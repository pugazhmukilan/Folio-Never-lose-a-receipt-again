import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'rental_data.dart';

class Product extends Equatable {
  final int? id;
  final String name;
  final String purchaseDate;
  final String expiryDate;
  final int? warrantyMonths;
  final String category;
  final int? notificationId;
  final RentalData? rentalData; // For House Rental category
  
  const Product({
    this.id,
    required this.name,
    required this.purchaseDate,
    required this.expiryDate,
    this.warrantyMonths,
    required this.category,
    this.notificationId,
    this.rentalData,
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
      'rental_data': rentalData != null ? rentalData!.toJsonString() : null,
    };
  }
  
  /// Create Product from Map (database query result)
  factory Product.fromMap(Map<String, dynamic> map) {
    RentalData? rental;
    if (map['rental_data'] != null && map['rental_data'] is String && (map['rental_data'] as String).isNotEmpty) {
      try {
        rental = RentalData.fromJsonString(map['rental_data'] as String);
      } catch (e) {
        rental = null;
      }
    }
    
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      purchaseDate: map['purchase_date'] as String,
      expiryDate: map['expiry_date'] as String,
      warrantyMonths: map['warranty_months'] as int?,
      category: map['category'] as String,
      notificationId: map['notification_id'] as int?,
      rentalData: rental,
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
    RentalData? rentalData,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      category: category ?? this.category,
      notificationId: notificationId ?? this.notificationId,
      rentalData: rentalData ?? this.rentalData,
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
      'rental_data': rentalData?.toJson(),
    };
  }
  
  /// Create from JSON for restore
  factory Product.fromJson(Map<String, dynamic> json) {
    RentalData? rental;
    if (json['rental_data'] != null) {
      try {
        rental = RentalData.fromJson(json['rental_data'] as Map<String, dynamic>);
      } catch (e) {
        rental = null;
      }
    }
    
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String,
      purchaseDate: json['purchase_date'] as String,
      expiryDate: json['expiry_date'] as String,
      warrantyMonths: json['warranty_months'] as int?,
      category: json['category'] as String,
      notificationId: json['notification_id'] as int?,
      rentalData: rental,
    );
  }
  
  @override
  List<Object?> get props => [id, name, purchaseDate, expiryDate, warrantyMonths, category, notificationId, rentalData];
  
  @override
  String toString() {
    return 'Product{id: $id, name: $name, category: $category, purchaseDate: $purchaseDate, expiryDate: $expiryDate, warrantyMonths: $warrantyMonths}';
  }
}
