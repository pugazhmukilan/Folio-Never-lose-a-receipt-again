import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:warranty_vault/core/utils/image_actions.dart';
import '../../data/models/product.dart';
import '../../data/models/rental_data.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as utils;
import '../widgets/full_screen_image_viewer.dart';
import '../widgets/rental_fields_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _selectedCategory = AppConstants.productCategories[0];
  DateTime _purchaseDate = DateTime.now();
  int _warrantyDuration = 12;
  DateTime? _expiryDate;
  RentalData? _rentalData;

  final List<String> _imagePaths = [];
  final List<String> _imageTypes = [];

  @override
  void initState() {
    super.initState();
    // Avoid setState() in initState; compute directly.
    _expiryDate = _computeExpiryDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  DateTime? _computeExpiryDate() {
    return utils.DateTimeUtils.calculateExpiryDate(
      _purchaseDate,
      _warrantyDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Product',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Capture Bill Image Section
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: theme.shadowColor == Colors.transparent
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.receipt_long, color: colorScheme.error, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bill Image (Required)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'OCR extracts dates & amounts automatically',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // FIX: single valid conditional instead of multiple dangling `else` blocks
                    if (!_hasBillImage())
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.error.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long, size: 48, color: colorScheme.error),
                            const SizedBox(height: 12),
                            Text(
                              'Bill Required',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Capture bill to extract information',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _selectImageSource,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text('Add Bill Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Display captured images
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _imagePaths.asMap().entries.map((entry) {
                          final index = entry.key;
                          final imagePath = entry.value;
                          
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImageViewer(
                                        imagePath: imagePath,
                                        imageType: _imageTypes[index],
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(imagePath),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Image type badge
                              if (_imageTypes[index] == AppConstants.imageTypeBill)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.error,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'BILL',
                                      style: TextStyle(
                                        color: colorScheme.onError,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: colorScheme.error,
                                    child: Icon(Icons.close, size: 16, color: colorScheme.onError),
                                  ),
                                ),
                              ),
                              // Download and Share buttons
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () => ImageActions.downloadImage(context, imagePath),
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.black.withOpacity(0.6),
                                        child: const Icon(Icons.download, color: Colors.white, size: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => ImageActions.shareImage(context, imagePath, _imageTypes[index]),
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.black.withOpacity(0.6),
                                        child: const Icon(Icons.share, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _selectImageSource,
                              icon: Icon(Icons.add_photo_alternate, color: colorScheme.onPrimary, size: 18),
                              label: Text(
                                'Add More Images',
                                style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Product Details Section
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: theme.shadowColor == Colors.transparent
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.inventory_2, color: colorScheme.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Product Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                      
                      // Product Name
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.shopping_bag_outlined, color: colorScheme.primary),
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        dropdownColor: theme.scaffoldBackgroundColor,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.category_outlined, color: colorScheme.primary),
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: colorScheme.primary, width: 2),
                          ),
                        ),
                        items: AppConstants.productCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      
                      // Warranty fields - Hide for House Rental
                      if (_selectedCategory != 'House Rental') ...[
                        const SizedBox(height: 16),
                        
                        // Purchase Date
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: InkWell(
                            onTap: _selectPurchaseDate,
                            borderRadius: BorderRadius.circular(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.calendar_today, color: colorScheme.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Purchase Date',
                                        style: TextStyle(
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        utils.DateTimeUtils.formatDisplayDate(_purchaseDate),
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.4)),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Warranty Duration
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.timer, color: colorScheme.primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Warranty Duration',
                                          style: TextStyle(
                                            color: colorScheme.onSurface.withOpacity(0.6),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$_warrantyDuration months',
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: colorScheme.primary,
                                  inactiveTrackColor: colorScheme.outline.withOpacity(0.2),
                                  thumbColor: colorScheme.primary,
                                  overlayColor: colorScheme.primary.withOpacity(0.2),
                                  valueIndicatorColor: colorScheme.primary,
                                  valueIndicatorTextStyle: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: Slider(
                                  value: _warrantyDuration.toDouble(),
                                  min: 3,
                                  max: 60,
                                  divisions: 19,
                                  label: '$_warrantyDuration months',
                                  onChanged: (value) {
                                    setState(() {
                                      _warrantyDuration = value.toInt();
                                      _expiryDate = _computeExpiryDate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Expiry Date (Calculated)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.event_available, color: colorScheme.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Warranty Expires',
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _expiryDate != null
                                          ? utils.DateTimeUtils.formatDisplayDate(_expiryDate!)
                                          : 'Not calculated',
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                            // House Rental Fields (conditional)
              if (_selectedCategory == 'House Rental') ...[
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: theme.shadowColor == Colors.transparent
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.home_work, color: colorScheme.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Rental Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All fields are optional. Add only the information you want to track.',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RentalFieldsWidget(
                        initialData: _rentalData,
                        onDataChanged: (data) {
                          setState(() {
                            _rentalData = data;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],              
              const SizedBox(height: 24),
              
              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _saveProduct,
                  icon: Icon(Icons.save_rounded, color: colorScheme.onPrimary),
                  label: Text(
                    'Save Product',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _selectImageSource() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colorScheme.primary, size: 28),
                title: Text('Camera', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                subtitle: Text('Take a photo', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: colorScheme.secondary, size: 28),
                title: Text('Gallery', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                subtitle: Text('Choose from gallery', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: AppConstants.imageQuality,
      );

      if (!mounted) return;

      if (image != null) {
        // If no bill exists yet, this MUST be tagged as bill
        final bool isBillImage = !_hasBillImage();
        String imageType;

        if (isBillImage) {
          imageType = AppConstants.imageTypeBill;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(source == ImageSource.camera 
                ? 'Bill captured successfully!' 
                : 'Bill image added successfully!'),
              backgroundColor: AppTheme.successGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          final selected = await _selectImageType();
          if (!mounted) return;
          imageType = selected ?? AppConstants.imageTypeProduct;
        }

        if (!mounted) return;
        setState(() {
          _imagePaths.add(image.path);
          _imageTypes.add(imageType);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${source == ImageSource.camera ? "capture" : "pick"} image: ${e.toString()}')),
      );
    }
  }
  
  bool _hasBillImage() {
    return _imageTypes.contains(AppConstants.imageTypeBill);
  }
  
  void _removeImage(int index) {
    // Prevent removing the last bill image
    if (_imageTypes[index] == AppConstants.imageTypeBill && 
        _imageTypes.where((type) => type == AppConstants.imageTypeBill).length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot remove the only bill image. At least one bill is required.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    setState(() {
      _imagePaths.removeAt(index);
      _imageTypes.removeAt(index);
    });
  }
  
  Future<void> _selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (!mounted) return;

    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
        _expiryDate = _computeExpiryDate();
      });
    }
  }
  
  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      if (!_hasBillImage()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bill image is required. Please capture the product bill.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // For House Rental, use current date as dummy dates since they're not relevant
      final isRental = _selectedCategory == 'House Rental';
      
      if (!isRental && _expiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to calculate expiry date')),
        );
        return;
      }
      
      final product = Product(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        purchaseDate: utils.DateTimeUtils.formatISO(isRental ? DateTime.now() : _purchaseDate),
        expiryDate: utils.DateTimeUtils.formatISO(isRental ? DateTime.now() : _expiryDate!),
        warrantyMonths: isRental ? null : _warrantyDuration,
        rentalData: isRental ? _rentalData : null,
      );
      
      context.read<ProductBloc>().add(CreateProduct(
            product: product,
            imagePaths: _imagePaths,
            imageTypes: _imageTypes,
          ));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product saved successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      
      Navigator.of(context).pop();
    }
  }
  
  Future<String?> _selectImageType() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text(
            'Select Image Type',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.receipt_long, color: colorScheme.error),
                title: Text('Bill', style: TextStyle(color: colorScheme.onSurface)),
                onTap: () => Navigator.of(context).pop(AppConstants.imageTypeBill),
              ),
              ListTile(
                leading: Icon(Icons.inventory_2, color: colorScheme.primary),
                title: Text('Product', style: TextStyle(color: colorScheme.onSurface)),
                onTap: () => Navigator.of(context).pop(AppConstants.imageTypeProduct),
              ),
              ListTile(
                leading: const Icon(Icons.book, color: AppTheme.warningOrange),
                title: Text('Manual', style: TextStyle(color: colorScheme.onSurface)),
                onTap: () => Navigator.of(context).pop(AppConstants.imageTypeManual),
              ),
            ],
          ),
        );
      },
    );
  }
}
