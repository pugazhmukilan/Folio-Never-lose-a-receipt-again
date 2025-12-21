import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final int? id;
  final int productId;
  final String imagePath;
  final String imageType;
  
  const Attachment({
    this.id,
    required this.productId,
    required this.imagePath,
    required this.imageType,
  });
  
  /// Convert Attachment to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'image_path': imagePath,
      'image_type': imageType,
    };
  }
  
  /// Create Attachment from Map (database query result)
  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      imagePath: map['image_path'] as String,
      imageType: map['image_type'] as String,
    );
  }
  
  /// Create a copy of Attachment with some fields updated
  Attachment copyWith({
    int? id,
    int? productId,
    String? imagePath,
    String? imageType,
  }) {
    return Attachment(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      imagePath: imagePath ?? this.imagePath,
      imageType: imageType ?? this.imageType,
    );
  }
  
  /// Convert to JSON for backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'image_path': imagePath,
      'image_type': imageType,
    };
  }
  
  /// Create from JSON for restore
  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as int?,
      productId: json['product_id'] as int,
      imagePath: json['image_path'] as String,
      imageType: json['image_type'] as String,
    );
  }
  
  @override
  List<Object?> get props => [id, productId, imagePath, imageType];
  
  @override
  String toString() {
    return 'Attachment{id: $id, productId: $productId, imageType: $imageType, imagePath: $imagePath}';
  }
}
