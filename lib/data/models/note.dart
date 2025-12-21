import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int? id;
  final int productId;
  final String content;
  final String createdAt;
  
  const Note({
    this.id,
    required this.productId,
    required this.content,
    required this.createdAt,
  });
  
  /// Convert Note to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'content': content,
      'created_at': createdAt,
    };
  }
  
  /// Create Note from Map (database query result)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      content: map['content'] as String,
      createdAt: map['created_at'] as String,
    );
  }
  
  /// Create a copy of Note with some fields updated
  Note copyWith({
    int? id,
    int? productId,
    String? content,
    String? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  /// Convert to JSON for backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'content': content,
      'created_at': createdAt,
    };
  }
  
  /// Create from JSON for restore
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int?,
      productId: json['product_id'] as int,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
    );
  }
  
  @override
  List<Object?> get props => [id, productId, content, createdAt];
  
  @override
  String toString() {
    return 'Note{id: $id, productId: $productId, content: $content, createdAt: $createdAt}';
  }
}
