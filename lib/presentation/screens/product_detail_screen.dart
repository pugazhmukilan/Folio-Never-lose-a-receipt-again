import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/note.dart';
import '../../data/models/product_with_details.dart';
import '../../data/models/rental_data.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../widgets/image_carousel.dart';
import '../widgets/common_widgets.dart';
import '../widgets/rental_fields_widget.dart';
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
          // Show edit icon for both rental and non-rental categories
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductDetailsLoaded) {
                final product = state.productWithDetails.product;
                if (product.category == 'House Rental') {
                  // Edit rental data
                  return IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit rental details',
                    onPressed: () => _showEditRentalDialog(product),
                  );
                } else {
                  // Edit warranty
                  return IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit warranty',
                    onPressed: () => _showEditWarrantyDialog(product),
                  );
                }
              }
              return const SizedBox.shrink();
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
                
                // Purchase & Expiry Details Card - Hide for House Rental
                if (product.category != 'House Rental')
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
                                // House Rental Details Section
                if (product.category == 'House Rental' && product.rentalData != null)
                  _buildRentalDetailsSection(product.rentalData!),
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
  
  Future<void> _showEditRentalDialog(dynamic product) async {
    if (product.rentalData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No rental data found')),
      );
      return;
    }

    RentalData? updatedRentalData = product.rentalData;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Rental Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                ),
                // Rental Fields
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: RentalFieldsWidget(
                      initialData: product.rentalData,
                      onDataChanged: (data) {
                        updatedRentalData = data;
                      },
                    ),
                  ),
                ),
                // Dialog Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (updatedRentalData != null) {
                            final updated = product.copyWith(
                              rentalData: updatedRentalData,
                            );
                            context.read<ProductBloc>().add(UpdateProduct(updated));
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Rental details updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
      // Show dialog to select image source
      final imageSource = await _showImageSourceDialog(context);
      
      if (imageSource == null) return;
      
      final XFile? image = await _imagePicker.pickImage(
        source: imageSource,
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
  
  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Options
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  size: 28,
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  size: 28,
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
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
  
  Widget _buildRentalDetailsSection(RentalData rentalData) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        const SizedBox(height: 16),
        
        // Tenant Information Card
        if (rentalData.tenantName != null || rentalData.tenantPhone != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Tenant Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (rentalData.tenantName != null)
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Tenant Name',
                      value: rentalData.tenantName!,
                    ),
                  if (rentalData.tenantPhone != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _makePhoneCall(rentalData.tenantPhone!),
                      child: _buildDetailRow(
                        icon: Icons.phone,
                        label: 'Phone Number',
                        value: rentalData.tenantPhone!,
                        valueColor: colorScheme.primary,
                      ),
                    ),
                  ],
                  if (rentalData.tenantEmail != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: rentalData.tenantEmail!,
                    ),
                  ],
                  if (rentalData.emergencyContact != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _makePhoneCall(rentalData.emergencyContact!),
                      child: _buildDetailRow(
                        icon: Icons.contact_phone,
                        label: 'Emergency Contact',
                        value: rentalData.emergencyContact!,
                        valueColor: colorScheme.primary,
                      ),
                    ),
                  ],
                  if (rentalData.familyMembers != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.family_restroom,
                      label: 'Family Members',
                      value: '${rentalData.familyMembers}',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        
        // Property Details Card
        if (rentalData.propertyAddress != null || rentalData.propertyType != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.home_work, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Property Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (rentalData.propertyAddress != null)
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: rentalData.propertyAddress!,
                    ),
                  if (rentalData.propertyType != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.home,
                      label: 'Property Type',
                      value: rentalData.propertyType!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        
        // Financial Details Card
        if (rentalData.monthlyRent != null || rentalData.securityDeposit != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Financial Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (rentalData.monthlyRent != null)
                    _buildDetailRow(
                      icon: Icons.currency_rupee,
                      label: 'Monthly Rent',
                      value: '₹${rentalData.monthlyRent}',
                      valueColor: colorScheme.primary,
                    ),
                  if (rentalData.securityDeposit != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.account_balance_wallet,
                      label: 'Security Deposit',
                      value: '₹${rentalData.securityDeposit}',
                    ),
                  ],
                  if (rentalData.paymentDueDate != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Payment Due Date',
                      value: 'Every ${rentalData.paymentDueDate}',
                    ),
                  ],
                  if (rentalData.paymentMethod != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.payment,
                      label: 'Payment Method',
                      value: rentalData.paymentMethod!,
                    ),
                  ],
                  
                  // Extra Charges
                  if (rentalData.extraCharges != null && rentalData.extraCharges!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Divider(height: 1, color: colorScheme.outline.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Extra Charges',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...rentalData.extraCharges!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                            Text(
                              '₹${entry.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    Divider(height: 1, color: colorScheme.outline.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Monthly',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${rentalData.getTotalMonthlyCharges().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        
        // Lease Information Card
        if (rentalData.agreementNumber != null || rentalData.lockInPeriodMonths != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Lease Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (rentalData.agreementNumber != null)
                    _buildDetailRow(
                      icon: Icons.numbers,
                      label: 'Agreement Number',
                      value: rentalData.agreementNumber!,
                    ),
                  if (rentalData.lockInPeriodMonths != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.lock_clock,
                      label: 'Lock-in Period',
                      value: '${rentalData.lockInPeriodMonths} months',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        
        // Utilities Card
        if (rentalData.electricityMeterReading != null || 
            rentalData.waterMeterReading != null || 
            rentalData.gasConnectionNumber != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.electrical_services, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Utilities',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (rentalData.electricityMeterReading != null)
                    _buildDetailRow(
                      icon: Icons.bolt,
                      label: 'Electricity Meter',
                      value: rentalData.electricityMeterReading!,
                    ),
                  if (rentalData.waterMeterReading != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.water_drop,
                      label: 'Water Meter',
                      value: rentalData.waterMeterReading!,
                    ),
                  ],
                  if (rentalData.gasConnectionNumber != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.local_fire_department,
                      label: 'Gas Connection',
                      value: rentalData.gasConnectionNumber!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }
}
