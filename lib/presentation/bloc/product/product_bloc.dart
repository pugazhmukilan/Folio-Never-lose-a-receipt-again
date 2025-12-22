import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/image_storage_service.dart';
import '../../../data/models/attachment.dart';
import '../../../data/models/product_with_details.dart';
import '../../../core/utils/date_utils.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  final ImageStorageService imageStorageService;

  // Cache the last list the UI was showing so switching to detail-related states
  // doesn't make the products list screen appear empty when navigating back.
  List<ProductWithDetails>? _cachedProducts;
  
  ProductBloc({
    required this.productRepository,
    required this.imageStorageService,
  }) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<AddAttachment>(_onAddAttachment);
    on<DeleteAttachment>(_onDeleteAttachment);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<LoadExpiringProducts>(_onLoadExpiringProducts);
  }

  void _updateCachedProductsFromState(ProductState s) {
    if (s is ProductsLoaded) {
      _cachedProducts = s.products;
    } else if (s is ProductSearchResults) {
      _cachedProducts = s.results;
    } else if (s is ProductsFiltered) {
      _cachedProducts = s.products;
    } else if (s is ProductDetailsLoaded) {
      // Preserve the cached list if it exists on the details state.
      if (s.allProducts != null) {
        _cachedProducts = s.allProducts;
      }
    }
  }
  
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final products = await productRepository.getAllProductsWithDetails();
      _cachedProducts = products;
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductError('Failed to load products: ${e.toString()}'));
    }
  }
  
  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _updateCachedProductsFromState(state);
      
      emit(ProductLoading());
      final productWithDetails = await productRepository.getProductWithDetails(event.productId);
      
      if (productWithDetails != null) {
        emit(ProductDetailsLoaded(productWithDetails, allProducts: _cachedProducts));
      } else {
        emit(const ProductError('Product not found'));
      }
    } catch (e) {
      emit(ProductError('Failed to load product details: ${e.toString()}'));
    }
  }
  
  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      
      // Insert product
      final productId = await productRepository.createProduct(event.product);
      
      // Save images and create attachments
      for (int i = 0; i < event.imagePaths.length; i++) {
        final imagePath = event.imagePaths[i];
        final imageType = event.imageTypes[i];
        
        // Save image to app directory
        final savedPath = await imageStorageService.saveImageFromPath(imagePath);
        
        // Create attachment record
        final attachment = Attachment(
          productId: productId,
          imagePath: savedPath,
          imageType: imageType,
        );

        await productRepository.addAttachment(attachment);
      }
      
      // Reload all products
      final products = await productRepository.getAllProductsWithDetails();
      _cachedProducts = products;
      emit(ProductsLoaded(products));
      emit(const ProductOperationSuccess('Product created successfully'));
    } catch (e) {
      emit(ProductError('Failed to create product: ${e.toString()}'));
    }
  }
  
  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      
      final success = await productRepository.updateProduct(event.product);
      
      if (success) {
        final products = await productRepository.getAllProductsWithDetails();
        _cachedProducts = products;
        emit(ProductsLoaded(products));
        emit(const ProductOperationSuccess('Product updated successfully'));
      } else {
        emit(const ProductError('Failed to update product'));
      }
    } catch (e) {
      emit(ProductError('Failed to update product: ${e.toString()}'));
    }
  }
  
  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      
      // Get attachments to delete images
      final attachments = await productRepository.getAttachments(event.productId);
      
      // Delete product from database
      final success = await productRepository.deleteProduct(event.productId);
      
      if (success) {
        // Delete associated images
        for (final attachment in attachments) {
          await imageStorageService.deleteImage(attachment.imagePath);
        }
        
        final products = await productRepository.getAllProductsWithDetails();
        _cachedProducts = products;
        emit(ProductsLoaded(products));
        emit(const ProductOperationSuccess('Product deleted successfully'));
      } else {
        emit(const ProductError('Failed to delete product'));
      }
    } catch (e) {
      emit(ProductError('Failed to delete product: ${e.toString()}'));
    }
  }
  
  Future<void> _onAddAttachment(
    AddAttachment event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _updateCachedProductsFromState(state);
      emit(ProductLoading());
      
      // Save image to app directory
      final savedPath = await imageStorageService.saveImageFromPath(event.imagePath);
      
      // Create attachment record
      final attachment = Attachment(
        productId: event.productId,
        imagePath: savedPath,
        imageType: event.imageType,
      );

      await productRepository.addAttachment(attachment);
      
      // Reload product details
      final productWithDetails = await productRepository.getProductWithDetails(event.productId);
      if (productWithDetails != null) {
        emit(ProductDetailsLoaded(productWithDetails, allProducts: _cachedProducts));
        emit(const ProductOperationSuccess('Image added successfully'));
      }
    } catch (e) {
      emit(ProductError('Failed to add attachment: ${e.toString()}'));
    }
  }
  
  Future<void> _onDeleteAttachment(
    DeleteAttachment event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _updateCachedProductsFromState(state);
      emit(ProductLoading());
      
      // Delete attachment from database
      final success = await productRepository.deleteAttachment(event.attachmentId);
      
      if (success) {
        // Delete image file
        await imageStorageService.deleteImage(event.imagePath);
        
        emit(const ProductOperationSuccess('Image deleted successfully'));
      } else {
        emit(const ProductError('Failed to delete attachment'));
      }
    } catch (e) {
      emit(ProductError('Failed to delete attachment: ${e.toString()}'));
    }
  }
  
  Future<void> _onAddNote(
    AddNote event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _updateCachedProductsFromState(state);
      emit(ProductLoading());
      
      await productRepository.addNote(event.note);
      
      // Reload product details
      final productWithDetails = await productRepository.getProductWithDetails(event.note.productId);
      if (productWithDetails != null) {
        emit(ProductDetailsLoaded(productWithDetails, allProducts: _cachedProducts));
        emit(const ProductOperationSuccess('Note added successfully'));
      }
    } catch (e) {
      emit(ProductError('Failed to add note: ${e.toString()}'));
    }
  }
  
  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _updateCachedProductsFromState(state);
      emit(ProductLoading());
      
      await productRepository.updateNote(event.note);
      
      // Reload product details
      final productWithDetails = await productRepository.getProductWithDetails(event.note.productId);
      if (productWithDetails != null) {
        emit(ProductDetailsLoaded(productWithDetails, allProducts: _cachedProducts));
        emit(const ProductOperationSuccess('Note updated successfully'));
      }
    } catch (e) {
      emit(ProductError('Failed to update note: ${e.toString()}'));
    }
  }
  
  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _updateCachedProductsFromState(state);
      emit(ProductLoading());
      
      await productRepository.deleteNote(event.noteId);
      
      emit(const ProductOperationSuccess('Note deleted successfully'));
    } catch (e) {
      emit(ProductError('Failed to delete note: ${e.toString()}'));
    }
  }
  
  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      
      if (event.query.isEmpty) {
        final products = await productRepository.getAllProductsWithDetails();
        _cachedProducts = products;
        emit(ProductsLoaded(products));
      } else {
        final products = await productRepository.searchProducts(event.query);
        final productsWithDetails = <ProductWithDetails>[];
        
        for (final product in products) {
          final details = await productRepository.getProductWithDetails(product.id!);
          if (details != null) {
            productsWithDetails.add(details);
          }
        }
        
        emit(ProductSearchResults(productsWithDetails, event.query));
      }
    } catch (e) {
      emit(ProductError('Failed to search products: ${e.toString()}'));
    }
  }
  
  Future<void> _onFilterProductsByCategory(
    FilterProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      
      final products = await productRepository.getProductsByCategory(event.category);
      final productsWithDetails = <ProductWithDetails>[];
      
      for (final product in products) {
        final details = await productRepository.getProductWithDetails(product.id!);
        if (details != null) {
          productsWithDetails.add(details);
        }
      }
      
      _cachedProducts = productsWithDetails;
      emit(ProductsFiltered(productsWithDetails, event.category));
    } catch (e) {
      emit(ProductError('Failed to filter products: ${e.toString()}'));
    }
  }
  
  Future<void> _onLoadExpiringProducts(
    LoadExpiringProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      
      final currentDate = AppDateUtils.formatDate(DateTime.now());
      final futureDate = AppDateUtils.formatDate(
        DateTime.now().add(Duration(days: event.days)),
      );
      
      final products = await productRepository.getExpiringProducts(currentDate, futureDate);
      final productsWithDetails = <ProductWithDetails>[];
      
      for (final product in products) {
        final details = await productRepository.getProductWithDetails(product.id!);
        if (details != null) {
          productsWithDetails.add(details);
        }
      }
      
      emit(ExpiringProductsLoaded(productsWithDetails, event.days));
    } catch (e) {
      emit(ProductError('Failed to load expiring products: ${e.toString()}'));
    }
  }
}
