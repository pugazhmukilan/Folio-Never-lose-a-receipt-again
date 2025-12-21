import 'package:equatable/equatable.dart';
import '../../../data/models/product_with_details.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class ProductInitial extends ProductState {}

/// Loading state
class ProductLoading extends ProductState {}

/// Products loaded successfully
class ProductsLoaded extends ProductState {
  final List<ProductWithDetails> products;
  
  const ProductsLoaded(this.products);
  
  @override
  List<Object?> get props => [products];
}

/// Single product details loaded
class ProductDetailsLoaded extends ProductState {
  final ProductWithDetails productWithDetails;
  final List<ProductWithDetails>? allProducts;
  
  const ProductDetailsLoaded(this.productWithDetails, {this.allProducts});
  
  @override
  List<Object?> get props => [productWithDetails, allProducts];
}

/// Product operation successful
class ProductOperationSuccess extends ProductState {
  final String message;
  
  const ProductOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Product operation error
class ProductError extends ProductState {
  final String message;
  
  const ProductError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Search results loaded
class ProductSearchResults extends ProductState {
  final List<ProductWithDetails> results;
  final String query;
  
  const ProductSearchResults(this.results, this.query);
  
  @override
  List<Object?> get props => [results, query];
}

/// Filtered products loaded
class ProductsFiltered extends ProductState {
  final List<ProductWithDetails> products;
  final String filter;
  
  const ProductsFiltered(this.products, this.filter);
  
  @override
  List<Object?> get props => [products, filter];
}
