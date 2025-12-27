# PDF Attachment Feature Implementation

## Overview
Added comprehensive PDF document support to the warranty management app, allowing users to attach, view, and share PDF files alongside images for products.

## Features Implemented

### 1. **PDF Picking & Storage**
- **Location**: [add_product_screen.dart](lib/presentation/screens/add_product_screen.dart)
- **Functionality**:
  - Added PDF option to attachment source selector
  - Implemented `_pickPdfDocument()` method using FilePicker
  - PDFs are copied to app documents directory with timestamp-based naming
  - PDFs stored in same attachment system with type `AppConstants.imageTypePdf`

### 2. **PDF Display in Grid**
- **Location**: [add_product_screen.dart](lib/presentation/screens/add_product_screen.dart)
- **Functionality**:
  - PDF thumbnails show red PDF icon instead of image preview
  - "PDF" badge displayed on PDF attachments
  - Download/Share buttons hidden for PDFs (different handling required)
  - Tap opens PDF viewer (to be implemented)

### 3. **PDF Management in Product Details**
- **Location**: [product_detail_screen.dart](lib/presentation/screens/product_detail_screen.dart)
- **Functionality**:
  - Added `_addPdfDocument()` method for adding PDFs to existing products
  - Updated attachment source selector to include PDF option
  - Implemented `_openPdf()` using open_file package
  - Implemented `_sharePdf()` using share_plus package
  - PDF attachments show PDF icon with share button

### 4. **PDF Carousel Display**
- **Location**: [image_carousel.dart](lib/presentation/widgets/image_carousel.dart)
- **Functionality**:
  - Carousel now detects PDF attachments
  - Displays PDF placeholder with icon and "Tap to open" text
  - Tapping PDF opens in external viewer using OpenFile
  - Download/Share buttons hidden for PDF items

### 5. **Constants & Dependencies**
- **Added Constant**: `imageTypePdf = 'pdf'` in [app_constants.dart](lib/core/constants/app_constants.dart)
- **New Dependencies**:
  - `open_file: ^3.5.9` - Opens PDFs in external viewer
  - Uses existing `file_picker: ^8.1.4` for PDF selection
  - Uses existing `path_provider` for storage location
  - Uses existing `share_plus` for PDF sharing

## Files Modified

1. **pubspec.yaml**
   - Added `open_file: ^3.5.9` dependency

2. **lib/core/constants/app_constants.dart**
   - Added `imageTypePdf` constant

3. **lib/presentation/screens/add_product_screen.dart**
   - Added imports: `file_picker`, `path_provider`
   - Updated `_selectImageSource()` to include PDF option
   - Added `_pickPdfDocument()` method
   - Updated attachment grid to handle PDF display

4. **lib/presentation/screens/product_detail_screen.dart**
   - Added imports: `file_picker`, `path_provider`, `open_file`, `share_plus`
   - Updated `_addImage()` to handle PDF selection
   - Added `_addPdfDocument()` method
   - Added `_showAttachmentSourceDialog()` with PDF option
   - Added `_openPdf()` method
   - Added `_sharePdf()` method
   - Updated attachment display to show PDF icons with share button
   - Removed unused `_showImageSourceDialog()` method

5. **lib/presentation/widgets/image_carousel.dart**
   - Added import: `open_file`
   - Updated carousel items to detect and display PDFs
   - Added `_openPdf()` method
   - PDF items show placeholder with tap-to-open functionality

## User Flow

### Adding PDF to New Product
1. User taps "Add More Images" button
2. Bottom sheet shows three options: Camera, Gallery, **PDF Document**
3. User selects "PDF Document"
4. File picker opens showing only PDF files
5. User selects PDF
6. PDF is copied to app directory and added to attachment list
7. PDF shows as red icon with "PDF" badge in grid

### Adding PDF to Existing Product
1. User opens product details
2. Taps "Add" button in Attachments section
3. Bottom sheet shows three options: Camera, Gallery, **PDF Document**
4. Same flow as above

### Viewing PDFs
- In product carousel: Tap PDF placeholder to open in external viewer
- In attachment grid: Tap PDF icon to open in external viewer
- Share button available on PDF attachments

## Database Schema
No database changes required - PDFs use existing `product_images` table:
- `id`: Primary key
- `product_id`: Foreign key to products
- `image_path`: File path to PDF
- `image_type`: Set to 'pdf'

## Testing Checklist
- [x] PDF picker opens and filters PDF files only
- [x] PDF files are copied to app directory
- [x] PDFs display correctly in attachment grids
- [x] PDF icon and badge show in add product screen
- [x] PDFs persist after product creation
- [x] PDF attachments appear in product details
- [x] Tap PDF in carousel opens external viewer
- [x] Share PDF functionality works
- [ ] PDFs included in product PDF export (Future enhancement)

## Future Enhancements
1. **PDF Merging**: When exporting product as PDF, merge attached PDF documents
2. **PDF Preview**: Show first page thumbnail instead of generic icon
3. **PDF Annotations**: Allow adding notes or highlights to PDFs
4. **Multiple PDF Selection**: Allow selecting multiple PDFs at once

## Known Limitations
- PDFs are not merged when exporting product as PDF (currently only mentioned in export)
- No preview of PDF content (shows generic icon)
- PDF must be opened in external app (no in-app viewer)

## Technical Notes
- PDFs stored with timestamp-based naming: `pdf_<milliseconds>.pdf`
- External viewer depends on platform (OS default PDF viewer)
- OpenFile package handles platform-specific PDF opening
- Share functionality uses XFile to share PDF documents
