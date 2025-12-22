import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/attachment.dart';
import '../models/note.dart';
import '../models/product_with_details.dart';

class ProductRepository {
  final DatabaseHelper _databaseHelper;
  
  ProductRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();
  
  // ==================== PRODUCT OPERATIONS ====================
  
  /// Create a new product
  Future<int> createProduct(Product product) async {
    return await _databaseHelper.insertProduct(product);
  }
  
  /// Get all products
  Future<List<Product>> getAllProducts() async {
    return await _databaseHelper.getAllProducts();
  }
  
  /// Get product by ID
  Future<Product?> getProductById(int id) async {
    return await _databaseHelper.getProductById(id);
  }
  
  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    return await _databaseHelper.getProductsByCategory(category);
  }
  
  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    return await _databaseHelper.searchProducts(query);
  }
  
  /// Update product
  Future<bool> updateProduct(Product product) async {
    final result = await _databaseHelper.updateProduct(product);
    return result > 0;
  }
  
  /// Delete product
  Future<bool> deleteProduct(int id) async {
    final result = await _databaseHelper.deleteProduct(id);
    return result > 0;
  }
  
  /// Get products expiring soon
  Future<List<Product>> getExpiringProducts(String currentDate, String futureDate) async {
    return await _databaseHelper.getExpiringProducts(currentDate, futureDate);
  }
  
  /// Get product with all details (attachments and notes)
  Future<ProductWithDetails?> getProductWithDetails(int productId) async {
    final product = await _databaseHelper.getProductById(productId);
    if (product == null) return null;
    
    final attachments = await _databaseHelper.getAttachmentsByProductId(productId);
    final notes = await _databaseHelper.getNotesByProductId(productId);
    
    return ProductWithDetails(
      product: product,
      attachments: attachments,
      notes: notes,
    );
  }
  
  /// Get all products with their attachments (for dashboard)
  Future<List<ProductWithDetails>> getAllProductsWithDetails() async {
    final products = await _databaseHelper.getAllProducts();
    final List<ProductWithDetails> productsWithDetails = [];
    
    for (final product in products) {
      final attachments = await _databaseHelper.getAttachmentsByProductId(product.id!);
      final notes = await _databaseHelper.getNotesByProductId(product.id!);
      
      productsWithDetails.add(
        ProductWithDetails(
          product: product,
          attachments: attachments,
          notes: notes,
        ),
      );
    }
    
    return productsWithDetails;
  }
  
  /// Get products count
  Future<int> getProductsCount() async {
    return await _databaseHelper.getProductsCount();
  }
  
  // ==================== ATTACHMENT OPERATIONS ====================
  
  /// Add attachment to product
  Future<int> addAttachment(Attachment attachment) async {
    return await _databaseHelper.insertAttachment(attachment);
  }
  
  /// Get attachments for product
  Future<List<Attachment>> getAttachments(int productId) async {
    return await _databaseHelper.getAttachmentsByProductId(productId);
  }
  
  /// Get attachments by type
  Future<List<Attachment>> getAttachmentsByType(int productId, String imageType) async {
    return await _databaseHelper.getAttachmentsByType(productId, imageType);
  }
  
  /// Delete attachment
  Future<bool> deleteAttachment(int id) async {
    final result = await _databaseHelper.deleteAttachment(id);
    return result > 0;
  }
  
  /// Get all attachments
  Future<List<Attachment>> getAllAttachments() async {
    return await _databaseHelper.getAllAttachments();
  }
  
  // ==================== NOTE OPERATIONS ====================
  
  /// Add note to product
  Future<int> addNote(Note note) async {
    return await _databaseHelper.insertNote(note);
  }
  
  /// Get notes for product
  Future<List<Note>> getNotes(int productId) async {
    return await _databaseHelper.getNotesByProductId(productId);
  }
  
  /// Update note
  Future<bool> updateNote(Note note) async {
    final result = await _databaseHelper.updateNote(note);
    return result > 0;
  }
  
  /// Delete note
  Future<bool> deleteNote(int id) async {
    final result = await _databaseHelper.deleteNote(id);
    return result > 0;
  }
  
  /// Get all notes
  Future<List<Note>> getAllNotes() async {
    return await _databaseHelper.getAllNotes();
  }
  
  /// Clear all data from database
  Future<void> clearAllData() async {
    await _databaseHelper.clearAllData();
  }
}
