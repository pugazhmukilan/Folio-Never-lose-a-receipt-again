import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class ImageStorageService {
  static ImageStorageService? _instance;
  
  ImageStorageService._();
  
  factory ImageStorageService() {
    _instance ??= ImageStorageService._();
    return _instance!;
  }
  
  /// Get the app's document directory for storing images
  Future<Directory> getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'warranty_images'));
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    return imagesDir;
  }
  
  /// Save image from XFile to app directory
  Future<String> saveImage(XFile imageFile) async {
    final imagesDir = await getImagesDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(imageFile.path);
    final fileName = 'img_$timestamp$extension';
    final savedPath = path.join(imagesDir.path, fileName);
    
    // Copy the file to the new location
    await File(imageFile.path).copy(savedPath);
    
    return savedPath;
  }
  
  /// Save image from File path to app directory
  Future<String> saveImageFromPath(String sourcePath) async {
    final imagesDir = await getImagesDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(sourcePath);
    final fileName = 'img_$timestamp$extension';
    final savedPath = path.join(imagesDir.path, fileName);
    
    // Copy the file to the new location
    await File(sourcePath).copy(savedPath);
    
    return savedPath;
  }
  
  /// Delete image file
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Delete multiple images
  Future<void> deleteImages(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await deleteImage(imagePath);
    }
  }
  
  /// Check if image file exists
  Future<bool> imageExists(String imagePath) async {
    final file = File(imagePath);
    return await file.exists();
  }
  
  /// Get image file
  File getImageFile(String imagePath) {
    return File(imagePath);
  }
  
  /// Get all images in the storage directory
  Future<List<String>> getAllImagePaths() async {
    final imagesDir = await getImagesDirectory();
    if (!await imagesDir.exists()) return [];
    
    final List<FileSystemEntity> entities = await imagesDir.list().toList();
    final List<String> imagePaths = [];
    
    for (final entity in entities) {
      if (entity is File) {
        imagePaths.add(entity.path);
      }
    }
    
    return imagePaths;
  }
  
  /// Clear all images from storage
  Future<void> clearAllImages() async {
    final imagesDir = await getImagesDirectory();
    if (await imagesDir.exists()) {
      await imagesDir.delete(recursive: true);
      await imagesDir.create(recursive: true);
    }
  }
  
  /// Get storage size in bytes
  Future<int> getStorageSize() async {
    final imagesDir = await getImagesDirectory();
    if (!await imagesDir.exists()) return 0;
    
    int totalSize = 0;
    final List<FileSystemEntity> entities = await imagesDir.list().toList();
    
    for (final entity in entities) {
      if (entity is File) {
        final stat = await entity.stat();
        totalSize += stat.size;
      }
    }
    
    return totalSize;
  }
  
  /// Format bytes to human-readable size
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
