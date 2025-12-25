import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product_with_details.dart';
import '../models/rental_data.dart';
import '../../core/utils/date_utils.dart' as utils;

class PdfService {
  Future<File> generateProductPdf(ProductWithDetails productWithDetails) async {
    final pdf = pw.Document();
    final product = productWithDetails.product;
    
    // Pre-load all images before building the PDF
    final loadedImages = await _loadAllImages(productWithDetails.attachments);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'WarrantyVault',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Product Details Export',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Icon(
                  pw.IconData(0xe850), // receipt icon
                  size: 40,
                  color: PdfColors.blue700,
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 2, color: PdfColors.blue700),
          pw.SizedBox(height: 20),
          
          // Product Information
          _buildSection('Product Information', [
            _buildField('Product Name', product.name),
            _buildField('Category', product.category),
            _buildField(
              'Purchase Date',
              () {
                final date = utils.DateTimeUtils.parseISO(product.purchaseDate);
                return date != null 
                    ? utils.DateTimeUtils.formatDisplayDate(date)
                    : product.purchaseDate;
              }(),
            ),
            if (product.category != 'House Rental')
              _buildField(
                'Expiry Date',
                () {
                  final date = utils.DateTimeUtils.parseISO(product.expiryDate);
                  return date != null 
                      ? utils.DateTimeUtils.formatDisplayDate(date)
                      : product.expiryDate;
                }(),
              ),
            if (product.warrantyMonths != null)
              _buildField('Warranty Period', '${product.warrantyMonths} months'),
          ]),
          
          pw.SizedBox(height: 20),
          
          // Rental Information (if applicable)
          if (product.category == 'House Rental' && product.rentalData != null)
            _buildRentalSection(product.rentalData!),
          
          // Image count info (actual images will be on separate pages)
          if (loadedImages.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSection('Product Images', [
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blue200, width: 1),
                ),
                child: pw.Row(
                  children: [
                    pw.Icon(
                      pw.IconData(0xe3f4), // image icon
                      size: 24,
                      color: PdfColors.blue700,
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Text(
                        '${loadedImages.length} image(s) attached\n(See following pages for full-size images)',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey800,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ],
          
          // Notes Section
          if (productWithDetails.notes.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildSection('Notes', 
              productWithDetails.notes.map((note) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue200),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        note.content,
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        utils.DateTimeUtils.formatDisplayDate(
                          DateTime.parse(note.createdAt),
                        ),
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          
          // Footer
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated by WarrantyVault',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'Date: ${utils.DateTimeUtils.formatDisplayDate(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    
    // Add a separate full-page for each image
    for (int i = 0; i < loadedImages.length; i++) {
      final imageData = loadedImages[i];
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Image header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue700,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'Image ${i + 1} of ${loadedImages.length}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 12),
                // Full-size image
                pw.Expanded(
                  child: pw.Center(
                    child: imageData['image'] != null
                        ? pw.Image(
                            imageData['image'],
                            fit: pw.BoxFit.contain,
                          )
                        : pw.Container(
                            padding: const pw.EdgeInsets.all(20),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.red50,
                              border: pw.Border.all(color: PdfColors.red200, width: 2),
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Text(
                              imageData['error'] ?? 'Failed to load image',
                              style: const pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.red700,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
    
    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/product_${product.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  /// Load all images from attachment file paths
  Future<List<Map<String, dynamic>>> _loadAllImages(List<dynamic> attachments) async {
    final List<Map<String, dynamic>> loadedImages = [];
    
    for (int i = 0; i < attachments.length; i++) {
      try {
        final attachment = attachments[i];
        final imagePath = attachment.imagePath as String;
        final file = File(imagePath);
        
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final image = pw.MemoryImage(bytes);
          
          loadedImages.add({
            'image': image,
            'path': imagePath,
            'index': i + 1,
          });
        } else {
          loadedImages.add({
            'image': null,
            'error': 'Image file not found',
            'path': imagePath,
            'index': i + 1,
          });
        }
      } catch (e) {
        print('Error loading image ${i + 1} for PDF: $e');
        loadedImages.add({
          'image': null,
          'error': 'Failed to load image: $e',
          'index': i + 1,
        });
      }
    }
    
    return loadedImages;
  }
  
  pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blue700, width: 2),
            ),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
        ),
        if (children.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          ...children,
        ],
      ],
    );
  }
  
  pw.Widget _buildField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey900,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  pw.Widget _buildRentalSection(RentalData rentalData) {
    final fields = <pw.Widget>[];
    
    if (rentalData.tenantName != null) {
      fields.add(_buildField('Tenant Name', rentalData.tenantName!));
    }
    if (rentalData.tenantPhone != null) {
      fields.add(_buildField('Phone', rentalData.tenantPhone!));
    }
    if (rentalData.tenantEmail != null) {
      fields.add(_buildField('Email', rentalData.tenantEmail!));
    }
    if (rentalData.propertyAddress != null) {
      fields.add(_buildField('Property Address', rentalData.propertyAddress!));
    }
    if (rentalData.propertyType != null) {
      fields.add(_buildField('Property Type', rentalData.propertyType!));
    }
    if (rentalData.monthlyRent != null) {
      fields.add(_buildField('Monthly Rent', '₹${rentalData.monthlyRent}'));
    }
    if (rentalData.securityDeposit != null) {
      fields.add(_buildField('Security Deposit', '₹${rentalData.securityDeposit}'));
    }
    if (rentalData.leaseStartDate != null) {
      fields.add(_buildField('Lease Start', rentalData.leaseStartDate!));
    }
    if (rentalData.leaseEndDate != null) {
      fields.add(_buildField('Lease End', rentalData.leaseEndDate!));
    }
    
    return _buildSection('Rental Information', fields);
  }
  
  Future<void> sharePdf(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.path.split('/').last,
    );
  }
  
  Future<void> printPdf(File pdfFile) async {
    await Printing.layoutPdf(
      onLayout: (format) => pdfFile.readAsBytes(),
    );
  }
}
