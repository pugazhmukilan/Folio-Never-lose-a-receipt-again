import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/product_with_details.dart';
import '../../data/database/database_helper.dart';
import '../../core/utils/date_utils.dart' as utils;
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/image_actions.dart';

class ProductCard extends StatefulWidget {
  final ProductWithDetails productWithDetails;
  final VoidCallback onTap;
  
  const ProductCard({
    super.key,
    required this.productWithDetails,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  IconData _categoryIcon = Icons.category_outlined;

  @override
  void initState() {
    super.initState();
    _loadCategoryIcon();
  }

  Future<void> _loadCategoryIcon() async {
    try {
      final category = await _dbHelper.getCategoryByName(widget.productWithDetails.product.category);
      if (category != null && mounted) {
        setState(() {
          _categoryIcon = _getIconFromName(category.iconName);
        });
      }
    } catch (e) {
      // Use default icon on error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final product = widget.productWithDetails.product;
    final expiryDate = utils.DateTimeUtils.parseISO(product.expiryDate);
    final coverImagePath = widget.productWithDetails.coverImagePath;
    
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
            onTap: widget.onTap,
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
                    
                    // Action Buttons (Bottom Right)
                    if (coverImagePath != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.download, color: Colors.white, size: 16),
                                onPressed: () {
                                  final imagePaths = widget.productWithDetails.attachments
                                      .map((a) => a.imagePath)
                                      .toList();
                                  ImageActions.downloadImages(context, imagePaths, product.name);
                                },
                                tooltip: 'Download All Images',
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.share, color: Colors.white, size: 16),
                                onPressed: () {
                                  final imagePaths = widget.productWithDetails.attachments
                                      .map((a) => a.imagePath)
                                      .toList();
                                  ImageActions.shareImages(context, imagePaths, product.name);
                                },
                                tooltip: 'Share All Images',
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(6),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Expiry Badge (Top Right) - Don't show for House Rental
                    if (product.category != 'House Rental')
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
                            _categoryIcon,
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
  
  IconData _getIconFromName(String iconName) {
    final iconMap = {
      'category': Icons.category_outlined,
      'devices': Icons.devices_outlined,
      'kitchen': Icons.kitchen_outlined,
      'weekend': Icons.chair_outlined,
      'directions_car': Icons.directions_car_outlined,
      'handyman': Icons.build_outlined,
      'yard': Icons.home_outlined,
      'checkroom': Icons.checkroom_outlined,
      'sports_soccer': Icons.fitness_center_outlined,
      'menu_book': Icons.menu_book_outlined,
      'home': Icons.home_work_outlined,
      'computer': Icons.computer_outlined,
      'phone_android': Icons.phone_android_outlined,
      'camera_alt': Icons.camera_alt_outlined,
      'watch': Icons.watch_outlined,
      'headphones': Icons.headphones_outlined,
      'tv': Icons.tv_outlined,
      'sports_esports': Icons.sports_esports_outlined,
      'fitness_center': Icons.fitness_center_outlined,
      'restaurant': Icons.restaurant_outlined,
      'local_cafe': Icons.local_cafe_outlined,
      'shopping_bag': Icons.shopping_bag_outlined,
      'work': Icons.work_outlined,
      'school': Icons.school_outlined,
      'medical_services': Icons.medical_services_outlined,
      'pets': Icons.pets_outlined,
      'child_care': Icons.child_care_outlined,
      'music_note': Icons.music_note_outlined,
      'palette': Icons.palette_outlined,
      'build': Icons.build_outlined,
      'brush': Icons.brush_outlined,
      'extension': Icons.extension_outlined,
    };
    return iconMap[iconName] ?? Icons.category_outlined;
  }
}
