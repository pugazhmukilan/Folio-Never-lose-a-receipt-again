import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/product.dart';
import '../models/attachment.dart';
import '../models/note.dart';
import '../models/category.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;
  
  // Singleton pattern
  DatabaseHelper._();
  
  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }
  
  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    
    final db = await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Hot-reload safe: ensure expected columns exist even if the database was
    // opened before a version bump/migration was applied.
    await _ensureWarrantyMonthsColumn(db);

    return db;
  }

  Future<void> _ensureWarrantyMonthsColumn(Database db) async {
    try {
      final columns = await db.rawQuery(
        'PRAGMA table_info(${AppConstants.tableProducts})',
      );

      final hasWarrantyMonths = columns.any((c) => c['name'] == 'warranty_months');
      if (!hasWarrantyMonths) {
        await db.execute('''
          ALTER TABLE ${AppConstants.tableProducts}
          ADD COLUMN warranty_months INTEGER
        ''');
      }
      
      final hasRentalData = columns.any((c) => c['name'] == 'rental_data');
      if (!hasRentalData) {
        await db.execute('''
          ALTER TABLE ${AppConstants.tableProducts}
          ADD COLUMN rental_data TEXT
        ''');
      }
    } catch (_) {
      // If anything goes wrong (e.g., table doesn't exist yet during initial create),
      // ignore here; create/migration paths will handle it.
    }
  }
  
  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create products table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProducts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        purchase_date TEXT NOT NULL,
        expiry_date TEXT NOT NULL,
        warranty_months INTEGER,
        category TEXT NOT NULL,
        notification_id INTEGER,
        rental_data TEXT
      )
    ''');
    
    // Create attachments table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableAttachments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        image_type TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES ${AppConstants.tableProducts} (id) ON DELETE CASCADE
      )
    ''');
    
    // Create notes table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableNotes} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES ${AppConstants.tableProducts} (id) ON DELETE CASCADE
      )
    ''');
    
    // OCR feature removed - table no longer created
    
    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_attachments_product_id 
      ON ${AppConstants.tableAttachments} (product_id)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_notes_product_id 
      ON ${AppConstants.tableNotes} (product_id)
    ''');
    
    // OCR index removed
    
    // Create categories table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCategories} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon_name TEXT NOT NULL,
        is_system INTEGER DEFAULT 0,
        is_rental_type INTEGER DEFAULT 0
      )
    ''');
    
    // Seed default categories
    await _seedDefaultCategories(db);
  }
  
  /// Seed default categories
  Future<void> _seedDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'Electronics', 'icon_name': 'devices', 'is_system': 1, 'is_rental_type': 0},
      {'name': 'Appliances', 'icon_name': 'kitchen', 'is_system': 1, 'is_rental_type': 0},
      {'name': 'Furniture', 'icon_name': 'weekend', 'is_system': 1, 'is_rental_type': 0},
      {'name': 'Automotive', 'icon_name': 'directions_car', 'is_system': 1, 'is_rental_type': 0},
      {'name': 'Tools', 'icon_name': 'handyman', 'is_system': 1, 'is_rental_type': 0},
      {'name': 'Home & Garden', 'icon_name': 'yard', 'is_system': 1, 'is_rental_type': 0},
      {'name': 'Fashion', 'icon_name': 'checkroom', 'is_system': 1, 'is_rental_type': 0},
      {'name': 'Sports & Outdoors', 'icon_name': 'sports_soccer', 'is_system': 1, 'is_rental_type': 0},
      {'name': 'Books & Media', 'icon_name': 'menu_book', 'is_system': 1, 'is_rental_type': 0},
      {'name': 'House Rental', 'icon_name': 'home', 'is_system': 1, 'is_rental_type': 1},
      {'name': 'Other', 'icon_name': 'category', 'is_system': 1, 'is_rental_type': 0},
    ];
    
    for (final category in defaultCategories) {
      await db.insert(AppConstants.tableCategories, category);
    }
  }
  
  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // OCR feature removed - no longer creating OCR table
    // Old databases may still have the table, but it will be ignored

    // Upgrade from version 2 to 3: Add warranty months to products table
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE ${AppConstants.tableProducts}
        ADD COLUMN warranty_months INTEGER
      ''');
    }
    
    // Upgrade from version 3 to 4: Add rental data for House Rental category
    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE ${AppConstants.tableProducts}
        ADD COLUMN rental_data TEXT
      ''');
    }
    
    // Upgrade from version 4 to 5: Add categories table
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE ${AppConstants.tableCategories} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          icon_name TEXT NOT NULL,
          is_system INTEGER DEFAULT 0,
          is_rental_type INTEGER DEFAULT 0
        )
      ''');
      
      await _seedDefaultCategories(db);
    }
  }
  
  // ==================== PRODUCT OPERATIONS ====================
  
  /// Insert a new product
  Future<int> insertProduct(Product product) async {
    final db = await database;
    await _ensureWarrantyMonthsColumn(db);
    return await db.insert(
      AppConstants.tableProducts,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get all products
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableProducts,
      orderBy: 'id DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }
  
  /// Get product by ID
  Future<Product?> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }
  
  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableProducts,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'expiry_date ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }
  
  /// Search products by name
  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableProducts,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }
  
  /// Update product
  Future<int> updateProduct(Product product) async {
    final db = await database;
    await _ensureWarrantyMonthsColumn(db);
    return await db.update(
      AppConstants.tableProducts,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }
  
  /// Delete product and related data
  Future<int> deleteProduct(int id) async {
    final db = await database;
    
    // Delete related attachments
    await db.delete(
      AppConstants.tableAttachments,
      where: 'product_id = ?',
      whereArgs: [id],
    );
    
    // Delete related notes
    await db.delete(
      AppConstants.tableNotes,
      where: 'product_id = ?',
      whereArgs: [id],
    );
    
    // Delete product
    return await db.delete(
      AppConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Get products expiring soon
  Future<List<Product>> getExpiringProducts(String currentDate, String futureDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableProducts,
      where: 'expiry_date >= ? AND expiry_date <= ?',
      whereArgs: [currentDate, futureDate],
      orderBy: 'expiry_date ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }
  
  // ==================== ATTACHMENT OPERATIONS ====================
  
  /// Insert a new attachment
  Future<int> insertAttachment(Attachment attachment) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableAttachments,
      attachment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get all attachments for a product
  Future<List<Attachment>> getAttachmentsByProductId(int productId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableAttachments,
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'id ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Attachment.fromMap(maps[i]);
    });
  }
  
  /// Get attachments by type for a product
  Future<List<Attachment>> getAttachmentsByType(int productId, String imageType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableAttachments,
      where: 'product_id = ? AND image_type = ?',
      whereArgs: [productId, imageType],
      orderBy: 'id ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Attachment.fromMap(maps[i]);
    });
  }
  
  /// Update attachment
  Future<int> updateAttachment(Attachment attachment) async {
    final db = await database;
    return await db.update(
      AppConstants.tableAttachments,
      attachment.toMap(),
      where: 'id = ?',
      whereArgs: [attachment.id],
    );
  }
  
  /// Delete attachment
  Future<int> deleteAttachment(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableAttachments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Get all attachments (for backup)
  Future<List<Attachment>> getAllAttachments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableAttachments,
    );
    
    return List.generate(maps.length, (i) {
      return Attachment.fromMap(maps[i]);
    });
  }
  
  // ==================== NOTE OPERATIONS ====================
  
  /// Insert a new note
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableNotes,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get all notes for a product
  Future<List<Note>> getNotesByProductId(int productId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableNotes,
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  
  /// Update note
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      AppConstants.tableNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  /// Delete note
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableNotes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Get all notes (for backup)
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableNotes,
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  
  // ==================== UTILITY OPERATIONS ====================
  
  /// Get total count of products
  Future<int> getProductsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableProducts}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  /// Close database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
  
  /// Delete database (for testing or reset)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
  
  /// Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(AppConstants.tableNotes);
    await db.delete(AppConstants.tableAttachments);
    await db.delete(AppConstants.tableProducts);
  }
  
  // ==================== CATEGORY OPERATIONS ====================
  
  /// Insert a new category
  Future<int> insertCategory(Category category) async {
    final db = await database;
    
    // Check for duplicate names (case-insensitive)
    final existing = await getCategoryByName(category.name);
    if (existing != null) {
      throw Exception('A category with this name already exists');
    }
    
    return await db.insert(
      AppConstants.tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
  
  /// Get all categories
  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCategories,
      orderBy: 'is_system DESC, name ASC', // System categories first, then alphabetical
    );
    
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }
  
  /// Get category by ID
  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }
  
  /// Get category by name (case-insensitive)
  Future<Category?> getCategoryByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCategories,
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
    );
    
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }
  
  /// Update category
  Future<int> updateCategory(Category category) async {
    final db = await database;
    
    // Check if it's a system category
    final existing = await getCategoryById(category.id!);
    if (existing?.isSystem == true) {
      throw Exception('System categories cannot be modified');
    }
    
    // Check for duplicate names (excluding current category)
    final duplicate = await getCategoryByName(category.name);
    if (duplicate != null && duplicate.id != category.id) {
      throw Exception('A category with this name already exists');
    }
    
    return await db.update(
      AppConstants.tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }
  
  /// Delete category
  Future<int> deleteCategory(int id) async {
    final db = await database;
    
    // Check if it's a system category
    final category = await getCategoryById(id);
    if (category?.isSystem == true) {
      throw Exception('System categories cannot be deleted');
    }
    
    // Check if category is in use by any products
    final productsUsingCategory = await db.query(
      AppConstants.tableProducts,
      where: 'category = ?',
      whereArgs: [category?.name],
      limit: 1,
    );
    
    if (productsUsingCategory.isNotEmpty) {
      throw Exception('Cannot delete category that is in use by products');
    }
    
    return await db.delete(
      AppConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Check if category name is available (for validation)
  Future<bool> isCategoryNameAvailable(String name, {int? excludeId}) async {
    final category = await getCategoryByName(name);
    if (category == null) return true;
    if (excludeId != null && category.id == excludeId) return true;
    return false;
  }
  
  /// Get count of products using a category
  Future<int> getProductCountByCategory(String categoryName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableProducts} WHERE category = ?',
      [categoryName],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
