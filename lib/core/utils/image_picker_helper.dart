import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Picks an image from [source] so the user can attach a photo to an item.
///
/// Returns the file path of the picked image, or `null` if the user cancels.
class ImagePickerHelper {
  static Future<String?> pick(
    BuildContext context,
    ImageSource source,
  ) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      // Always open the rear camera first — some devices ignore the package
      // default and launch the front lens.
      preferredCameraDevice: CameraDevice.rear,
      // Downscale camera captures to keep stored attachments reasonably sized
      // (avoids giant multi-megapixel originals), and re-encode to JPEG so
      // HEIC files are handled on all platforms.
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );
    return picked?.path;
  }
}