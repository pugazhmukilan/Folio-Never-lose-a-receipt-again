import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/product_with_details.dart';
import '../../core/utils/date_utils.dart' as utils;
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductWithDetails productWithDetails;
  final VoidCallback onTap;
  
  const ProductCard({
    super.key,
    required this.productWithDetails,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final product = productWithDetails.product;
    final expiryDate = utils.DateTimeUtils.parseISO(product.expiryDate);
    final coverImagePath = productWithDetails.coverImagePath;
    
    // Calculate expiry status
    Color expiryColor = AppTheme.activeColor;
    String expiryText = '';
    
    if (expiryDate != null) {
      if (utils.DateTimeUtils.isExpired(expiryDate)) {
        expiryColor = AppTheme.expiringColor;
        expiryText = 'Expired';
      } else if (utils.DateTimeUtils.isExpiringSoon(
        expiryDate,
        AppConstants.notificationReminderDays,
      )) {
        expiryColor = AppTheme.warningColor;
        final days = utils.DateTimeUtils.getDaysUntilExpiry(expiryDate);
        expiryText = '$days days left';
      } else {
        final days = utils.DateTimeUtils.getDaysUntilExpiry(expiryDate);
        expiryText = '$days days';
      }
    }
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            if (coverImagePath != null)
              AspectRatio(
                aspectRatio: 1.0,
                child: Image.file(
                  File(coverImagePath),
                  fit: BoxFit.cover,
                  cacheWidth: AppConstants.imageCacheWidthThumbnail,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
              )
            else
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.receipt_long, size: 50),
                ),
              ),
            
            // Product Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Category
                  Text(
                    product.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Expiry Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: expiryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: expiryColor),
                    ),
                    child: Text(
                      expiryText,
                      style: TextStyle(
                        color: expiryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
