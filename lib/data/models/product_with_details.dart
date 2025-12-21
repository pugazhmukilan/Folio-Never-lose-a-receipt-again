import 'package:equatable/equatable.dart';
import 'product.dart';
import 'attachment.dart';
import 'note.dart';

/// Complete product data model with all related entities
class ProductWithDetails extends Equatable {
  final Product product;
  final List<Attachment> attachments;
  final List<Note> notes;
  
  const ProductWithDetails({
    required this.product,
    required this.attachments,
    required this.notes,
  });
  
  /// Get the cover image (first attachment) path
  String? get coverImagePath {
    if (attachments.isEmpty) return null;
    return attachments.first.imagePath;
  }
  
  /// Get bill images
  List<Attachment> get billImages {
    return attachments.where((a) => a.imageType == 'bill').toList();
  }
  
  /// Get product images
  List<Attachment> get productImages {
    return attachments.where((a) => a.imageType == 'product').toList();
  }
  
  /// Get manual images
  List<Attachment> get manualImages {
    return attachments.where((a) => a.imageType == 'manual').toList();
  }
  
  /// Create a copy with updated fields
  ProductWithDetails copyWith({
    Product? product,
    List<Attachment>? attachments,
    List<Note>? notes,
  }) {
    return ProductWithDetails(
      product: product ?? this.product,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
    );
  }
  
  @override
  List<Object?> get props => [product, attachments, notes];
  
  @override
  String toString() {
    return 'ProductWithDetails{product: $product, attachments: ${attachments.length}, notes: ${notes.length}}';
  }
}
