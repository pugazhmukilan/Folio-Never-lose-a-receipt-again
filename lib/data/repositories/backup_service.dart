import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../models/product.dart';
import '../models/attachment.dart';
import '../models/note.dart';
import 'product_repository.dart';
import 'image_storage_service.dart';

class BackupService {
  final ProductRepository productRepository;
  final ImageStorageService imageStorageService;
  
  BackupService({
    required this.productRepository,
    required this.imageStorageService,
  });
  
  /// Export all data to a ZIP file
  Future<String> exportData() async {
    try {
      // Get temporary directory for creating backup
      final tempDir = await getTemporaryDirectory();
      final backupDir = Directory(path.join(tempDir.path, 'backup_temp'));
      
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
      await backupDir.create(recursive: true);
      
      // Get all data from database
      final products = await productRepository.getAllProducts();
      final attachments = await productRepository.getAllAttachments();
      final notes = await productRepository.getAllNotes();
      
      // Create JSON data
      final Map<String, dynamic> backupData = {
        'version': AppConstants.appVersion,
        'exported_at': DateTime.now().toIso8601String(),
        'products': products.map((p) => p.toJson()).toList(),
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'notes': notes.map((n) => n.toJson()).toList(),
      };
      
      // Write JSON to file
      final jsonFile = File(path.join(backupDir.path, AppConstants.backupDataFileName));
      await jsonFile.writeAsString(jsonEncode(backupData));
      
      // Create images directory in backup
      final imagesBackupDir = Directory(
        path.join(backupDir.path, AppConstants.backupImagesFolder),
      );
      await imagesBackupDir.create(recursive: true);
      
      // Copy all images to backup directory
      for (final attachment in attachments) {
        final imageFile = File(attachment.imagePath);
        if (await imageFile.exists()) {
          final fileName = path.basename(attachment.imagePath);
          final destPath = path.join(imagesBackupDir.path, fileName);
          await imageFile.copy(destPath);
        }
      }
      
      // Create ZIP archive
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipFileName = '${AppConstants.backupFileName}_$timestamp.zip';
      final zipFilePath = path.join(tempDir.path, zipFileName);
      
      // Zip the backup directory
      final encoder = ZipFileEncoder();
      encoder.create(zipFilePath);
      await encoder.addDirectory(backupDir, includeDirName: false);
      encoder.close();
      
      // Clean up temp backup directory
      await backupDir.delete(recursive: true);
      
      return zipFilePath;
    } catch (e) {
      throw Exception('Failed to export data: ${e.toString()}');
    }
  }
  
  /// Import data from a ZIP file
  Future<void> importData(String zipFilePath) async {
    try {
      // Get temporary directory for extracting backup
      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory(path.join(tempDir.path, 'backup_extract'));
      
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);
      
      // Extract ZIP file
      // Extract ZIP file
      final bytes = File(zipFilePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final filePath = path.join(extractDir.path, filename);
          final outFile = File(filePath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(data);
        } else {
          final dirPath = path.join(extractDir.path, filename);
          await Directory(dirPath).create(recursive: true);
        }
      }
      
      // Find data.json (handle both flat zip and nested folder zip)
      File? jsonFile;
      Directory? rootBackupDir;
      
      // Check root first
      final rootDataFile = File(path.join(extractDir.path, AppConstants.backupDataFileName));
      if (await rootDataFile.exists()) {
        jsonFile = rootDataFile;
        rootBackupDir = extractDir;
      } else {
        // Check subdirectories
        final entities = await extractDir.list().toList();
        for (final entity in entities) {
          if (entity is Directory) {
            final subDataFile = File(path.join(entity.path, AppConstants.backupDataFileName));
            if (await subDataFile.exists()) {
              jsonFile = subDataFile;
              rootBackupDir = entity;
              break;
            }
          }
        }
      }
      
      if (jsonFile == null || rootBackupDir == null) {
        throw Exception('Invalid backup file: data.json not found');
      }
      
      final jsonContent = await jsonFile.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonContent);
      
      // Import products
      final List<dynamic> productsJson = backupData['products'] ?? [];
      final Map<int, int> productIdMap = {}; // Old ID -> New ID
      
      for (final productJson in productsJson) {
        final product = Product.fromJson(productJson);
        final oldId = product.id;
        
        // Insert without ID to get new auto-generated ID
        final newId = await productRepository.createProduct(
          product.copyWith(id: null),
        );
        
        if (oldId != null) {
          productIdMap[oldId] = newId;
        }
      }
      
      // Import images and attachments
      final List<dynamic> attachmentsJson = backupData['attachments'] ?? [];
      final imagesDir = await imageStorageService.getImagesDirectory();
      final imagesBackupDir = Directory(
        path.join(rootBackupDir.path, AppConstants.backupImagesFolder),
      );
      
      if (await imagesBackupDir.exists()) {
        for (final attachmentJson in attachmentsJson) {
          final attachment = Attachment.fromJson(attachmentJson);
          final oldProductId = attachment.productId;
          final newProductId = productIdMap[oldProductId];
          
          if (newProductId != null) {
            final oldImagePath = attachment.imagePath;
            final fileName = path.basename(oldImagePath);
            final sourceImagePath = path.join(imagesBackupDir.path, fileName);
            
            if (await File(sourceImagePath).exists()) {
              // Copy image to app directory
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final newFileName = 'img_${timestamp}_$fileName';
              final newImagePath = path.join(imagesDir.path, newFileName);
              
              await File(sourceImagePath).copy(newImagePath);
              
              // Insert attachment with new product ID and image path
              await productRepository.addAttachment(
                Attachment(
                  productId: newProductId,
                  imagePath: newImagePath,
                  imageType: attachment.imageType,
                ),
              );
            }
          }
        }
      }
      
      // Import notes
      final List<dynamic> notesJson = backupData['notes'] ?? [];
      
      for (final noteJson in notesJson) {
        final note = Note.fromJson(noteJson);
        final oldProductId = note.productId;
        final newProductId = productIdMap[oldProductId];
        
        if (newProductId != null) {
          await productRepository.addNote(
            note.copyWith(
              id: null,
              productId: newProductId,
            ),
          );
        }
      }
      
      // Clean up extraction directory
      await extractDir.delete(recursive: true);
    } catch (e) {
      throw Exception('Failed to import data: ${e.toString()}');
    }
  }
}
