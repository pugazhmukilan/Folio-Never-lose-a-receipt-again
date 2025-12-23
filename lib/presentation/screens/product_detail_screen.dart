import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/note.dart';
import '../../data/models/product_with_details.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../widgets/image_carousel.dart';
import '../widgets/common_widgets.dart';
import '../../core/utils/date_utils.dart' as utils;
import '../../core/constants/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  
  const ProductDetailScreen({super.key, required this.productId});
  
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _imagePicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProductDetails(widget.productId));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit warranty',
            onPressed: () {
              final state = context.read<ProductBloc>().state;
              if (state is ProductDetailsLoaded) {
                _showEditWarrantyDialog(state.productWithDetails.product);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Reload product details
            context.read<ProductBloc>().add(LoadProductDetails(widget.productId));
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingIndicator(message: 'Loading product...');
          }

          // After an update, ProductBloc temporarily emits ProductsLoaded and/or
          // ProductOperationSuccess. This screen only knows how to render
          // ProductDetailsLoaded, so treat these as a refresh state.
          if (state is ProductsLoaded || state is ProductOperationSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<ProductBloc>().add(LoadProductDetails(widget.productId));
              }
            });
            return const LoadingIndicator(message: 'Refreshing product...');
          }
          
          if (state is ProductError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<ProductBloc>().add(LoadProductDetails(widget.productId));
              },
            );
          }
          
          if (state is ProductDetailsLoaded) {
            return _buildProductDetails(state.productWithDetails);
          }
          
          return const EmptyState(
            icon: Icons.error_outline,
            title: 'Product not found',
          );
        },
      ),
    );
  }
  
  Widget _buildProductDetails(ProductWithDetails productWithDetails) {
    final product = productWithDetails.product;
    final attachments = productWithDetails.attachments;
    final notes = productWithDetails.notes;
    
    final purchaseDate = utils.DateTimeUtils.parseISO(product.purchaseDate);
    final expiryDate = utils.DateTimeUtils.parseISO(product.expiryDate);
    final warrantyMonths = product.warrantyMonths;
    
    final imagePaths = attachments.map((a) => a.imagePath).toList();
    final imageTypes = attachments.map((a) => a.imageType).toList();
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Carousel
          if (imagePaths.isNotEmpty)
            ImageCarousel(
              imagePaths: imagePaths,
              imageTypes: imageTypes,
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined, size: 80),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                // Category
                Chip(
                  label: Text(product.category),
                  avatar: const Icon(Icons.category_outlined, size: 16),
                ),
                
                const SizedBox(height: 16),
                
                // Purchase & Expiry Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildDetailRow(
                            icon: Icons.shopping_cart_outlined,
                          label: 'Purchase Date',
                          value: purchaseDate != null
                              ? utils.DateTimeUtils.formatDisplayDate(purchaseDate)
                              : 'N/A',
                        ),
                        if (warrantyMonths != null) ...[
                          const SizedBox(height: 16),
                          Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: Icons.timer_outlined,
                            label: 'Warranty Duration',
                            value: '$warrantyMonths months',
                          ),
                        ],
                        const SizedBox(height: 16),
                        Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                            icon: Icons.event_available_outlined,
                          label: 'Warranty Expires',
                          value: expiryDate != null
                              ? utils.DateTimeUtils.formatDisplayDate(expiryDate)
                              : 'N/A',
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                            icon: Icons.timer_outlined,
                          label: 'Status',
                          value: expiryDate != null
                              ? utils.DateTimeUtils.getExpiryStatusText(expiryDate)
                              : 'N/A',
                          valueColor: expiryDate != null
                              ? (utils.DateTimeUtils.isExpired(expiryDate)
                                  ? Colors.red
                                  : Colors.green)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                // if (productWithDetails.hasPendingBillExtraction) ...[
                //   const SizedBox(height: 12),
                //   SizedBox(
                //     width: double.infinity,
                //     child: ElevatedButton.icon(
                //       onPressed: () {
                //         context
                //             .read<ProductBloc>()
                //             .add(ExtractBillUsefulInfo(widget.productId));
                //       },
                //       icon: const Icon(Icons.auto_awesome_outlined),
                //       label: const Text('Extract useful info'),
                //     ),
                //   ),
                // ],
                
                const SizedBox(height: 16),
                
                // Images Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Images (${attachments.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: _addImage,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                if (attachments.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: attachments.length,
                      itemBuilder: (context, index) {
                        final attachment = attachments[index];
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(attachment.imagePath),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  cacheWidth: AppConstants.imageCacheWidthThumbnail,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    iconSize: 16,
                                    icon: Icon(
                                      Icons.close,
                                      color: Theme.of(context).colorScheme.onError,
                                    ),
                                    onPressed: () {
                                      _confirmDeleteAttachment(
                                        context,
                                        attachment.id!,
                                        attachment.imagePath,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Notes Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notes (${notes.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddNoteDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                if (notes.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No notes yet',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...notes.map((note) {
                    final createdAt = utils.DateTimeUtils.parseISO(note.createdAt);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(note.content),
                        subtitle: createdAt != null
                            ? Text(
                                utils.DateTimeUtils.formatDisplayDate(createdAt),
                                style: const TextStyle(fontSize: 12),
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<ProductBloc>().add(DeleteNote(note.id!));
                          },
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int? _deriveWarrantyMonths({required DateTime purchaseDate, required DateTime expiryDate}) {
    // Best-effort derivation for legacy products that only stored expiryDate.
    // Assumes expiry is roughly purchaseDate + N months.
    final diffMonths = (expiryDate.year - purchaseDate.year) * 12 + (expiryDate.month - purchaseDate.month);
    if (diffMonths <= 0) return null;
    return diffMonths;
  }

  Future<void> _showEditWarrantyDialog(dynamic product) async {
    final purchaseDate = utils.DateTimeUtils.parseISO(product.purchaseDate);
    final expiryDate = utils.DateTimeUtils.parseISO(product.expiryDate);

    if (purchaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit warranty: invalid purchase date')),
      );
      return;
    }

    final derivedMonths = expiryDate != null
        ? _deriveWarrantyMonths(purchaseDate: purchaseDate, expiryDate: expiryDate)
        : null;

    int selectedMonths = product.warrantyMonths ?? derivedMonths ?? 12;
    selectedMonths = selectedMonths.clamp(3, 60);

    DateTime previewExpiry = utils.DateTimeUtils.calculateExpiryDate(purchaseDate, selectedMonths);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit warranty period'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Duration: $selectedMonths months'),
                  Slider(
                    value: selectedMonths.toDouble(),
                    min: 3,
                    max: 60,
                    divisions: 19,
                    label: '$selectedMonths months',
                    onChanged: (value) {
                      setDialogState(() {
                        selectedMonths = value.toInt();
                        previewExpiry = utils.DateTimeUtils.calculateExpiryDate(purchaseDate, selectedMonths);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('New expiry: ${utils.DateTimeUtils.formatDisplayDate(previewExpiry)}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updated = product.copyWith(
                      warrantyMonths: selectedMonths,
                      expiryDate: utils.DateTimeUtils.formatISO(previewExpiry),
                    );

                    context.read<ProductBloc>().add(UpdateProduct(updated));
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _addImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: AppConstants.imageQuality,
      );
      
      if (image != null) {
        // Show dialog to select image type
        final imageType = await _showImageTypeDialog(context);
        
        if (imageType != null) {
          context.read<ProductBloc>().add(AddAttachment(
                productId: widget.productId,
                imagePath: image.path,
                imageType: imageType,
              ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add image: ${e.toString()}')),
      );
    }
  }
  
  Future<String?> _showImageTypeDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Image Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Bill'),
                onTap: () => Navigator.of(context).pop(AppConstants.imageTypeBill),
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Product'),
                onTap: () => Navigator.of(context).pop(AppConstants.imageTypeProduct),
              ),
              ListTile(
                leading: const Icon(Icons.book_outlined),
                title: const Text('Manual'),
                onTap: () => Navigator.of(context).pop(AppConstants.imageTypeManual),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _confirmDeleteAttachment(
    BuildContext context,
    int attachmentId,
    String imagePath,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ProductBloc>().add(DeleteAttachment(
                      attachmentId: attachmentId,
                      imagePath: imagePath,
                    ));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAddNoteDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter your note...',
            ),
            maxLines: 3,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final note = Note(
                    productId: widget.productId,
                    content: controller.text.trim(),
                    createdAt: DateTime.now().toIso8601String(),
                  );
                  
                  context.read<ProductBloc>().add(AddNote(note));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text(
            'Are you sure you want to delete this product? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ProductBloc>().add(DeleteProduct(widget.productId));
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
