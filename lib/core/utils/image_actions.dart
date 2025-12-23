import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ImageActions {
  static Future<void> downloadImage(BuildContext context, String imagePath) async {
    PermissionStatus status;
    
    if (Platform.isAndroid) {
      status = await Permission.storage.request();
      
      if (status.isDenied) {
         status = await Permission.photos.request();
      }
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted || status.isLimited) {
      try {
        final Uint8List imageData = await File(imagePath).readAsBytes();
        final result = await ImageGallerySaverPlus.saveImage(
          imageData,
          name: 'bill_image_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        if (result['isSuccess'] == true) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image saved to gallery')),
            );
          }
        } else {
          throw Exception(result['errorMessage']);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save image: $e')),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Please enable it in settings.'),
          ),
        );
        openAppSettings();
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    }
  }

  static Future<void> shareImage(BuildContext context, String imagePath, String imageType) async {
    try {
      await Share.shareXFiles([XFile(imagePath)], text: 'Sharing $imageType');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share image: $e')),
        );
      }
    }
  }

  // Download multiple images
  static Future<void> downloadImages(BuildContext context, List<String> imagePaths, String productName) async {
    if (imagePaths.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No images to download')),
        );
      }
      return;
    }

    PermissionStatus status;
    
    if (Platform.isAndroid) {
      status = await Permission.storage.request();
      
      if (status.isDenied) {
         status = await Permission.photos.request();
      }
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted || status.isLimited) {
      int successCount = 0;
      int failCount = 0;

      for (String imagePath in imagePaths) {
        try {
          final Uint8List imageData = await File(imagePath).readAsBytes();
          final result = await ImageGallerySaverPlus.saveImage(
            imageData,
            name: 'bill_${productName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
          );
          
          if (result['isSuccess'] == true) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
        }
      }

      if (context.mounted) {
        if (successCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$successCount image(s) saved to gallery${failCount > 0 ? ', $failCount failed' : ''}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save images')),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Please enable it in settings.'),
          ),
        );
        openAppSettings();
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    }
  }

  // Share multiple images
  static Future<void> shareImages(BuildContext context, List<String> imagePaths, String productName) async {
    if (imagePaths.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No images to share')),
        );
      }
      return;
    }

    try {
      final List<XFile> files = imagePaths.map((path) => XFile(path)).toList();
      await Share.shareXFiles(files, text: 'Sharing images of $productName');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share images: $e')),
        );
      }
    }
  }
}
