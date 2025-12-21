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
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: BlocListener<OcrBloc, OcrState>(
        listener: (context, state) {
          if (state is OcrProcessing) {
            setState(() {
              _isOcrProcessing = true;
            });
          } else if (state is OcrSuccess) {
            setState(() {
              _isOcrProcessing = false;
            });
            _handleOcrResult(state);
          } else if (state is OcrError) {
            setState(() {
              _isOcrProcessing = false;
            });
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.camera_alt, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Capture Bill Image',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_imagePaths.isEmpty)
                          ElevatedButton.icon(
                            onPressed: _captureImage,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Take Photo'),
                          )
                        else
                          Column(
                            children: [
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
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.red,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              _removeImage(index);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _captureImage,
                                icon: const Icon(Icons.add_a_photo),
                                label: const Text('Add More'),
                              ),
                            ],
                          ),
                        
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
                ),
                
                const SizedBox(height: 16),
                
                // Product Details Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Product Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            prefixIcon: Icon(Icons.inventory_2),
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
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            prefixIcon: Icon(Icons.category),
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
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Purchase Date'),
                          subtitle: Text(utils.DateTimeUtils.formatDisplayDate(_purchaseDate)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _selectPurchaseDate,
                        ),
                        
                        const Divider(),
                        
                        // Warranty Duration
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.timer),
                          title: const Text('Warranty Duration'),
                          subtitle: Text('$_warrantyDuration months'),
                        ),
                        
                        Slider(
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
                        
                        const Divider(),
                        
                        // Expiry Date (Calculated)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_available),
                          title: const Text('Warranty Expires'),
                          subtitle: Text(
                            _expiryDate != null
                                ? utils.DateTimeUtils.formatDisplayDate(_expiryDate!)
                                : 'Not calculated',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Save Button
                ElevatedButton.icon(
                  onPressed: _saveProduct,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Product'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
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
        setState(() {
          _imagePaths.add(image.path);
          _imageTypes.add(AppConstants.imageTypeBill);
        });
        
        // Process first image with OCR
        if (_imagePaths.length == 1) {
          context.read<OcrBloc>().add(ProcessImageOcr(image.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: ${e.toString()}')),
      );
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
      _imageTypes.removeAt(index);
    });
  }
  
  void _handleOcrResult(OcrSuccess ocrResult) {
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
      if (_imagePaths.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image')),
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
      );
      
      context.read<ProductBloc>().add(CreateProduct(
            product: product,
            imagePaths: _imagePaths,
            imageTypes: _imageTypes,
          ));
      
      Navigator.of(context).pop();
    }
  }
}
