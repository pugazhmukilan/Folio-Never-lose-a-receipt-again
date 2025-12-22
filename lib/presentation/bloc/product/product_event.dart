import 'package:equatable/equatable.dart';
import '../../../data/models/product.dart';
import '../../../data/models/note.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  
  @override
  List<Object?> get props => [];
}

/// Load all products
class LoadProducts extends ProductEvent {}

/// Load single product with details
class LoadProductDetails extends ProductEvent {
  final int productId;
  
  const LoadProductDetails(this.productId);
  
  @override
  List<Object?> get props => [productId];
}

/// Create new product
class CreateProduct extends ProductEvent {
  final Product product;
  final List<String> imagePaths;
  final List<String> imageTypes;
  final String? ocrExtractedText;
  final List<DateTime>? ocrExtractedDates;
  final List<double>? ocrExtractedAmounts;
  
  const CreateProduct({
    required this.product,
    required this.imagePaths,
    required this.imageTypes,
    this.ocrExtractedText,
    this.ocrExtractedDates,
    this.ocrExtractedAmounts,
  });
  
  @override
  List<Object?> get props => [
        product,
        imagePaths,
        imageTypes,
        ocrExtractedText,
        ocrExtractedDates,
        ocrExtractedAmounts,
      ];
}

/// Update existing product
class UpdateProduct extends ProductEvent {
  final Product product;
  
  const UpdateProduct(this.product);
  
  @override
  List<Object?> get props => [product];
}

/// Delete product
class DeleteProduct extends ProductEvent {
  final int productId;
  
  const DeleteProduct(this.productId);
  
  @override
  List<Object?> get props => [productId];
}

/// Add attachment to product
class AddAttachment extends ProductEvent {
  final int productId;
  final String imagePath;
  final String imageType;
  
  const AddAttachment({
    required this.productId,
    required this.imagePath,
    required this.imageType,
  });
  
  @override
  List<Object?> get props => [productId, imagePath, imageType];
}

/// Delete attachment
class DeleteAttachment extends ProductEvent {
  final int attachmentId;
  final String imagePath;
  
  const DeleteAttachment({
    required this.attachmentId,
    required this.imagePath,
  });
  
  @override
  List<Object?> get props => [attachmentId, imagePath];
}

/// Add note to product
class AddNote extends ProductEvent {
  final Note note;
  
  const AddNote(this.note);
  
  @override
  List<Object?> get props => [note];
}

/// Update note
class UpdateNote extends ProductEvent {
  final Note note;
  
  const UpdateNote(this.note);
  
  @override
  List<Object?> get props => [note];
}

/// Delete note
class DeleteNote extends ProductEvent {
  final int noteId;
  
  const DeleteNote(this.noteId);
  
  @override
  List<Object?> get props => [noteId];
}

/// Search products
class SearchProducts extends ProductEvent {
  final String query;
  
  const SearchProducts(this.query);
  
  @override
  List<Object?> get props => [query];
}

/// Filter products by category
class FilterProductsByCategory extends ProductEvent {
  final String category;
  
  const FilterProductsByCategory(this.category);
  
  @override
  List<Object?> get props => [category];
}

/// Load expiring products
class LoadExpiringProducts extends ProductEvent {
  final int days;
  
  const LoadExpiringProducts(this.days);
  
  @override
  List<Object?> get props => [days];
}
