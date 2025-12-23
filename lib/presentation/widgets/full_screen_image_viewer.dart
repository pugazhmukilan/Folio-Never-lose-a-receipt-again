import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/utils/image_actions.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String imageType;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    required this.imageType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => ImageActions.downloadImage(context, imagePath),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => ImageActions.shareImage(context, imagePath, imageType),
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }
}
