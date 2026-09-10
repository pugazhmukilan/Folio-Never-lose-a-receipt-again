import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/item_field.dart';
import 'item_repository.dart';
import 'image_storage_service.dart';

class BackupService {
  final ItemRepository itemRepository;
  final ImageStorageService imageStorageService;
  
  BackupService({
    required this.itemRepository,
    required this.imageStorageService,
  });
  
  /// Export all data to a ZIP file
  Future<String> exportData() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final backupDir = Directory(path.join(tempDir.path, 'backup_temp'));
      
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
      await backupDir.create(recursive: true);
      
      final itemsWithDetails = await itemRepository.getAllItemsWithDetails();
      final categories = await itemRepository.getAllCategories();
      
      // We do not export PASSWORD fields per spec §6
      final List<Map<String, dynamic>> itemsList = [];
      for (final iwd in itemsWithDetails) {
        final itemMap = iwd.item.toMap();
        
        final List<Map<String, dynamic>> fields = [];
        for (final f in iwd.fields) {
          if (f.fieldType == FieldType.password) continue;
          fields.add(f.toMap());
        }
        itemMap['fields'] = fields;
        itemMap['attachments'] = iwd.attachments.map((a) => a.toMap()).toList();
        
        itemsList.add(itemMap);
      }

      final Map<String, dynamic> backupData = {
        'version': AppConstants.appVersion,
        'schema_version': 7,
        'exported_at': DateTime.now().toIso8601String(),
        'categories': categories.map((c) => c.toMap()).toList(),
        'items': itemsList,
      };
      
      final jsonFile = File(path.join(backupDir.path, AppConstants.backupDataFileName));
      await jsonFile.writeAsString(jsonEncode(backupData));
      
      final imagesBackupDir = Directory(
        path.join(backupDir.path, AppConstants.backupImagesFolder),
      );
      await imagesBackupDir.create(recursive: true);
      
      for (final iwd in itemsWithDetails) {
        for (final attachment in iwd.attachments) {
          final file = File(attachment.path);
          if (await file.exists()) {
            final fileName = path.basename(attachment.path);
            final destPath = path.join(imagesBackupDir.path, fileName);
            await file.copy(destPath);
          }
        }
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipFileName = '${AppConstants.backupFileName}_$timestamp.zip';
      final zipFilePath = path.join(tempDir.path, zipFileName);
      
      final encoder = ZipFileEncoder();
      encoder.create(zipFilePath);
      await encoder.addDirectory(backupDir, includeDirName: false);
      encoder.close();
      
      await backupDir.delete(recursive: true);
      
      return zipFilePath;
    } catch (e) {
      throw Exception('Failed to export data: ${e.toString()}');
    }
  }
  
  /// Import data from a ZIP file
  Future<void> importData(String zipFilePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final extractDir = Directory(path.join(tempDir.path, 'backup_extract'));
      
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
      await extractDir.create(recursive: true);
      
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
      
      File? jsonFile;
      Directory? rootBackupDir;
      
      final rootDataFile = File(path.join(extractDir.path, AppConstants.backupDataFileName));
      if (await rootDataFile.exists()) {
        jsonFile = rootDataFile;
        rootBackupDir = extractDir;
      } else {
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
      
      if (backupData['schema_version'] != 7) {
        // Simple wipe-and-fail for old backups since schema is fully changed
        throw Exception('Incompatible backup version. Only v7 schema backups are supported.');
      }

      await itemRepository.clearAllData();

      // 1. Categories
      final List<dynamic> categoriesJson = backupData['categories'] ?? [];
      final Map<int, int> categoryIdMap = {}; // old -> new
      for (final catMap in categoriesJson) {
        final cat = Category.fromMap(catMap as Map<String, dynamic>);
        final oldId = cat.id;
        final newId = await itemRepository.createCategory(cat.copyWith(id: null));
        if (oldId != null) categoryIdMap[oldId] = newId;
      }

      // 2. Items
      final List<dynamic> itemsJson = backupData['items'] ?? [];
      final imagesBackupDir = Directory(
        path.join(rootBackupDir.path, AppConstants.backupImagesFolder),
      );

      for (final itemMap in itemsJson) {
        final map = itemMap as Map<String, dynamic>;
        
        final item = Item.fromMap(map);
        final oldCatId = item.categoryId;
        final newCatId = oldCatId != null ? categoryIdMap[oldCatId] : null;
        
        final fields = (map['fields'] as List<dynamic>? ?? [])
            .map((e) => ItemField.fromMap(e as Map<String, dynamic>).copyWith(id: null))
            .toList();

        // Process attachments
        final List<String> newAttachmentPaths = [];
        final oldAttachments = (map['attachments'] as List<dynamic>? ?? []);
        for (final attMap in oldAttachments) {
          final oldPath = attMap['path'] as String;
          final fileName = path.basename(oldPath);
          final sourceFile = File(path.join(imagesBackupDir.path, fileName));
          
          if (await sourceFile.exists()) {
            newAttachmentPaths.add(sourceFile.path);
          }
        }

        await itemRepository.createItem(
          item: item.copyWith(id: null, categoryId: newCatId),
          fields: fields,
          attachmentPaths: newAttachmentPaths,
        );
      }
      
      await extractDir.delete(recursive: true);
    } catch (e) {
      throw Exception('Failed to import data: ${e.toString()}');
    }
  }
}
