import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/product.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/ocr/ocr_bloc.dart';
import '../bloc/ocr/ocr_event.dart';
import '../bloc/ocr/ocr_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart' as utils;
import '../widgets/common_widgets.dart';

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
  
  final List<String> _imagePaths = [];
  final List<String> _imageTypes = [];
  
  bool _isOcrProcessing = false;
  String? _ocrExtractedText;
  List<DateTime> _ocrExtractedDates = [];
  List<double> _ocrExtractedAmounts = [];
  
  @override
  void initState() {
    super.initState();
    _calculateExpiryDate();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  void _calculateExpiryDate() {
    setState(() {
      _expiryDate = utils.DateTimeUtils.calculateExpiryDate(
        _purchaseDate,
        _warrantyDuration,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocListener<OcrBloc, OcrState>(
        listener: (context, state) {
          if (state is OcrProcessing) {
            setState(() => _isOcrProcessing = true);
          } else if (state is OcrSuccess) {
            setState(() => _isOcrProcessing = false);
            _handleOcrResult(state);
          } else if (state is OcrError) {
            setState(() => _isOcrProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
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
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
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
                              color: const Color(0xFFFF6B6B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.receipt_long, color: Color(0xFFFF6B6B), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bill Image (Required)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'OCR extracts dates & amounts automatically',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.6),
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
                            color: const Color(0xFFFF6B6B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.receipt_long, size: 48, color: Color(0xFFFF6B6B)),
                              const SizedBox(height: 12),
                              const Text(
                                'Bill Required',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Capture bill to extract information',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _captureImage,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Capture Bill'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B6B),
                                  foregroundColor: Colors.white,
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(imagePath),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
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
                                        color: const Color(0xFFFF6B6B),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'BILL',
                                        style: TextStyle(
                                          color: Colors.white,
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
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
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
                                onPressed: _captureImage,
                                icon: const Icon(Icons.add_a_photo, color: Colors.black, size: 18),
                                label: const Text(
                                  'Add More',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ECDC4),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            if (_ocrExtractedText != null) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _showOcrData,
                                  icon: const Icon(Icons.text_snippet, size: 18),
                                  label: const Text('OCR Data'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF4ECDC4),
                                    side: const BorderSide(color: Color(0xFF4ECDC4)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],

                      if (_isOcrProcessing)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: LoadingIndicator(
                            message: 'Scanning bill...',
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Product Details Section
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
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
                              color: const Color(0xFF4ECDC4).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.inventory_2, color: Color(0xFF4ECDC4), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Product Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                        
                        // Product Name
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                            prefixIcon: Icon(Icons.shopping_bag_outlined, color: const Color(0xFF4ECDC4)),
                            filled: true,
                            fillColor: const Color(0xFF2A2A2A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
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
                          dropdownColor: const Color(0xFF2A2A2A),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                            prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF4ECDC4)),
                            filled: true,
                            fillColor: const Color(0xFF2A2A2A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
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
                        
                        const SizedBox(height: 16),
                        
                        // Purchase Date
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
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
                                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.calendar_today, color: Color(0xFF4ECDC4), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Purchase Date',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        utils.DateTimeUtils.formatDisplayDate(_purchaseDate),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white.withOpacity(0.4)),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Warranty Duration
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
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
                                      color: const Color(0xFF4ECDC4).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.timer, color: Color(0xFF4ECDC4), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Warranty Duration',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$_warrantyDuration months',
                                          style: const TextStyle(
                                            color: Colors.white,
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
                                  activeTrackColor: const Color(0xFF4ECDC4),
                                  inactiveTrackColor: const Color(0xFF3A3A3A),
                                  thumbColor: const Color(0xFF4ECDC4),
                                  overlayColor: const Color(0xFF4ECDC4).withOpacity(0.2),
                                  valueIndicatorColor: const Color(0xFF4ECDC4),
                                  valueIndicatorTextStyle: const TextStyle(
                                    color: Colors.black,
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
                                      _calculateExpiryDate();
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
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.event_available, color: Color(0xFF4ECDC4), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Warranty Expires',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _expiryDate != null
                                          ? utils.DateTimeUtils.formatDisplayDate(_expiryDate!)
                                          : 'Not calculated',
                                      style: const TextStyle(
                                        color: Colors.white,
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
                    ),
                  ),
                
                
                const SizedBox(height: 24),
                
                // Save Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44B9B0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _saveProduct,
                    icon: const Icon(Icons.save_rounded, color: Colors.black),
                    label: const Text(
                      'Save Product',
                      style: TextStyle(
                        color: Colors.black,
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
      ),
    );
  }
  
  Future<void> _captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: AppConstants.imageQuality,
      );
      
      if (image != null) {
        // If no bill exists yet, this MUST be tagged as bill
        final bool isBillImage = !_hasBillImage();
        String imageType;
        
        if (isBillImage) {
          imageType = AppConstants.imageTypeBill;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bill captured! Processing with OCR...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          imageType = await _selectImageType() ?? AppConstants.imageTypeProduct;
        }
        
        setState(() {
          _imagePaths.add(image.path);
          _imageTypes.add(imageType);
        });
        
        // Process bill images with OCR to extract information
        if (imageType == AppConstants.imageTypeBill) {
          context.read<OcrBloc>().add(ProcessImageOcr(image.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: ${e.toString()}')),
      );
    }
  }
  
  bool _hasBillImage() {
    return _imageTypes.contains(AppConstants.imageTypeBill);
  }
  
  // bool _hasBillImage() {
  //   return _imageTypes.contains(AppConstants.imageTypeBill);
  // }
  
  void _removeImage(int index) {
    // Prevent removing the last bill image
    if (_imageTypes[index] == AppConstants.imageTypeBill && 
        _imageTypes.where((type) => type == AppConstants.imageTypeBill).length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot remove the only bill image. At least one bill is required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _imagePaths.removeAt(index);
      _imageTypes.removeAt(index);
    });
  }
  
  void _handleOcrResult(OcrSuccess ocrResult) {
    // Store OCR data for future use
    setState(() {
      _ocrExtractedText = ocrResult.extractedText;
      _ocrExtractedDates = ocrResult.extractedDates;
      _ocrExtractedAmounts = ocrResult.extractedAmounts;
    });
    
    // Auto-fill purchase date if found
    if (ocrResult.extractedDates.isNotEmpty) {
      final detectedDate = ocrResult.extractedDates.first;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Date Detected'),
          content: Text(
            'Found date: ${utils.DateTimeUtils.formatDisplayDate(detectedDate)}\n\nUse this as purchase date?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _purchaseDate = detectedDate;
                  _calculateExpiryDate();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    }
    
    // Show detected amounts
    if (ocrResult.extractedAmounts.isNotEmpty) {
      final detectedAmount = ocrResult.extractedAmounts.last;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detected amount: ₹${detectedAmount.toStringAsFixed(2)}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  Future<void> _selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _purchaseDate) {
      setState(() {
        _purchaseDate = picked;
        _calculateExpiryDate();
      });
    }
  }
  
  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      if (!_hasBillImage()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill image is required. Please capture the product bill.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      if (_expiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to calculate expiry date')),
        );
        return;
      }
      
      final product = Product(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        purchaseDate: utils.DateTimeUtils.formatISO(_purchaseDate),
        expiryDate: utils.DateTimeUtils.formatISO(_expiryDate!),
        warrantyMonths: _warrantyDuration,
      );
      
      context.read<ProductBloc>().add(CreateProduct(
            product: product,
            imagePaths: _imagePaths,
            imageTypes: _imageTypes,
            ocrExtractedText: _ocrExtractedText,
            ocrExtractedDates: _ocrExtractedDates.isNotEmpty ? _ocrExtractedDates : null,
            ocrExtractedAmounts: _ocrExtractedAmounts.isNotEmpty ? _ocrExtractedAmounts : null,
          ));
      
      // Show success message with OCR summary
      if (_ocrExtractedText != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Product saved with OCR data: ${_ocrExtractedDates.length} dates, ${_ocrExtractedAmounts.length} amounts extracted',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      Navigator.of(context).pop();
    }
  }
  
  Future<String?> _selectImageType() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Select Image Type',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.receipt_long, color: Color(0xFFFF6B6B)),
                title: const Text('Bill', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(context).pop(AppConstants.imageTypeBill),
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2, color: Color(0xFF4ECDC4)),
                title: const Text('Product', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(context).pop(AppConstants.imageTypeProduct),
              ),
              ListTile(
                leading: const Icon(Icons.book, color: Color(0xFFFFA726)),
                title: const Text('Manual', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(context).pop(AppConstants.imageTypeManual),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showOcrData() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Row(
            children: [
              Icon(Icons.text_snippet, color: Color(0xFF4ECDC4)),
              SizedBox(width: 8),
              Text(
                'Extracted OCR Data',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_ocrExtractedDates.isNotEmpty) ...[
                  const Text(
                    'Dates Found:',
                    style: TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._ocrExtractedDates.map((date) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text(
                          '• ${utils.DateTimeUtils.formatDisplayDate(date)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  const SizedBox(height: 12),
                ],
                if (_ocrExtractedAmounts.isNotEmpty) ...[
                  const Text(
                    'Amounts Found:',
                    style: TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._ocrExtractedAmounts.map((amount) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text(
                          '• ₹${amount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  const SizedBox(height: 12),
                ],
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                const Text(
                  'Full Extracted Text:',
                  style: TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _ocrExtractedText ?? 'No text extracted',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF4ECDC4)),
              ),
            ),
          ],
        );
      },
    );
  }
}
