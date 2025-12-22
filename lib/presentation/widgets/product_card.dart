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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final product = productWithDetails.product;
    final expiryDate = utils.DateTimeUtils.parseISO(product.expiryDate);
    final coverImagePath = productWithDetails.coverImagePath;
    
    // Calculate expiry status
    Color expiryColor = AppTheme.successGreen;
    String expiryText = '';
    IconData expiryIcon = Icons.check_circle_outline;
    
    if (expiryDate != null) {
      if (utils.DateTimeUtils.isExpired(expiryDate)) {
        expiryColor = AppTheme.errorRed;
        expiryText = 'Expired';
        expiryIcon = Icons.cancel_outlined;
      } else if (utils.DateTimeUtils.isExpiringSoon(
        expiryDate,
        AppConstants.notificationReminderDays,
      )) {
        expiryColor = AppTheme.warningOrange;
        final days = utils.DateTimeUtils.getDaysUntilExpiry(expiryDate);
        expiryText = '$days days left';
        expiryIcon = Icons.warning_amber_outlined;
      } else {
        final days = utils.DateTimeUtils.getDaysUntilExpiry(expiryDate);
        expiryText = '$days days';
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isLight
            ? const []
            : [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.18),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.03),
                  blurRadius: 0,
                  offset: const Offset(0, -1),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: colorScheme.onSurface.withOpacity(0.08),
            highlightColor: colorScheme.onSurface.withOpacity(0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                Stack(
                  children: [
                    if (coverImagePath != null)
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: Image.file(
                          File(coverImagePath),
                          fit: BoxFit.cover,
                          cacheWidth: AppConstants.imageCacheWidthThumbnail,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    
                    // Expiry Badge (Top Right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.scrim.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: expiryColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              expiryIcon,
                              size: 12,
                              color: expiryColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              expiryText,
                              style: TextStyle(
                                color: expiryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Product Info
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      
                      // Category with Icon
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(product.category),
                            size: 13,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.category,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      // Purchase Date
                      if (product.purchaseDate.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              utils.DateTimeUtils.formatDisplayDate(
                                utils.DateTimeUtils.parseISO(product.purchaseDate) ?? DateTime.now(),
                              ),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices_outlined;
      case 'Appliances':
        return Icons.kitchen_outlined;
      case 'Furniture':
        return Icons.chair_outlined;
      case 'Clothing':
        return Icons.checkroom_outlined;
      case 'Automotive':
        return Icons.directions_car_outlined;
      case 'Home & Garden':
        return Icons.home_outlined;
      case 'Sports & Fitness':
        return Icons.fitness_center_outlined;
      case 'Tools':
        return Icons.build_outlined;
      case 'Jewelry':
        return Icons.diamond_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
