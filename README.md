# WarrantyVault

A professional offline-first mobile application for managing product warranties, bills, and receipts. Built with Flutter using clean architecture and BLoC pattern.

## Features

### Core Functionality
- **Digital Bill Storage**: Scan and store product bills using OCR technology
- **Warranty Management**: Track warranty periods with automatic expiry notifications
- **Product Organization**: Categorize products (Electronics, Appliances, Furniture, etc.)
- **Multi-Image Support**: Store multiple images per product (bill, product photos, manuals)
- **Service Notes**: Add and manage service history notes for each product

### Smart Features
- **OCR Scanning**: Automatically extract purchase dates and amounts from bill images
- **Warranty Notifications**: Get reminded 30 days before warranty expiry
- **Search & Filter**: Quick search across products and filter by category
- **Backup & Restore**: Export/import all data with images as ZIP archives
- **Offline-First**: Works completely offline with local SQLite database

### UI/UX
- **Pinterest-Style Grid**: Masonry grid layout for beautiful product cards
- **Image Carousel**: Swipeable image viewer with full-screen mode
- **Material Design 3**: Modern, clean UI with light/dark theme support
- **Professional Design**: Polished interface with smooth animations

## Architecture

### Clean Architecture with Layers
```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App-wide constants
│   ├── theme/              # Material Design 3 themes
│   └── utils/              # Helper utilities
├── data/                    # Data layer
│   ├── models/             # Data models with serialization
│   ├── database/           # SQLite database helper
│   └── repositories/       # Repository implementations
└── presentation/            # Presentation layer
    ├── bloc/               # BLoC state management
    ├── screens/            # UI screens
    └── widgets/            # Reusable widgets
```

### State Management
- **BLoC Pattern** with flutter_bloc for predictable state management
- **Product BLoC**: CRUD operations and search/filter
- **OCR BLoC**: Text recognition and data extraction
- **Notification BLoC**: Warranty reminder scheduling
- **Backup BLoC**: Export/import orchestration

### Database Schema
```sql
-- Products Table
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  purchase_date INTEGER NOT NULL,
  expiry_date INTEGER NOT NULL,
  category TEXT NOT NULL,
  price REAL,
  store_name TEXT,
  warranty_duration INTEGER NOT NULL,
  notification_id INTEGER
);

-- Attachments Table
CREATE TABLE attachments (
  id TEXT PRIMARY KEY,
  product_id TEXT NOT NULL,
  image_path TEXT NOT NULL,
  image_type TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Notes Table
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  product_id TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
```

## Tech Stack

### Core Dependencies
- **flutter_bloc** ^8.1.6 - State management with BLoC pattern
- **sqflite** ^2.3.3+1 - Local SQLite database
- **google_mlkit_text_recognition** ^0.13.1 - OCR for bill scanning
- **flutter_local_notifications** ^18.0.1 - Warranty expiry reminders
- **shared_preferences** ^2.3.2 - App settings storage

### UI Components
- **flutter_staggered_grid_view** ^0.7.0 - Pinterest-style masonry grid
- **image_picker** ^1.1.2 - Camera and gallery access

### Storage & Backup
- **path_provider** ^2.1.4 - File system access
- **archive** ^3.6.1 - ZIP compression for backups
- **share_plus** ^10.1.2 - Share backup files
- **file_picker** ^8.1.4 - Import backup files

### Utilities
- **intl** ^0.19.0 - Date formatting
- **timezone** ^0.9.4 - Timezone support for notifications
- **permission_handler** ^11.3.1 - Runtime permissions
- **equatable** ^2.0.5 - Value equality for BLoC states

## Setup Instructions

### Prerequisites
- Flutter SDK ^3.10.1
- Android Studio / Xcode for platform builds
- Android SDK 21+ / iOS 12.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bill
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Run on connected device
   flutter run

   # Run on specific device
   flutter devices
   flutter run -d <device-id>
   ```

### Platform Configuration

#### Android
Permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- Camera access for bill scanning
- Storage access for image management
- Notification permissions for warranty reminders
- Exact alarm scheduling for precise notifications

#### iOS
Permissions are configured in `ios/Runner/Info.plist`:
- NSCameraUsageDescription - Camera access for bill scanning
- NSPhotoLibraryUsageDescription - Photo library access
- NSPhotoLibraryAddUsageDescription - Save captured images

## Usage Guide

### Adding a Product

1. **Tap the + FAB** on the home screen
2. **Scan Bill** (optional):
   - Capture bill image with camera
   - OCR will extract purchase date and amounts
   - Review and confirm detected data
3. **Enter Product Details**:
   - Product name (required)
   - Category selection
   - Purchase date (auto-filled from OCR or manual)
   - Price and store name (optional)
   - Warranty duration slider (3-60 months)
4. **Add Images**:
   - Bill image (already captured if OCR used)
   - Additional product photos or manuals
5. **Save** - Product is created with automatic expiry calculation

### Managing Products

#### View Product Details
- Tap any product card to view full details
- Swipe through image carousel
- See warranty status badge (Active/Expiring Soon/Expired)

#### Add Service Notes
- Open product details
- Tap "Add Note" button
- Enter service description with timestamp

#### Add More Images
- Open product details
- Tap "Add Image" button
- Select image type (Bill/Product/Manual)
- Capture or pick from gallery

#### Delete Product
- Open product details
- Tap delete icon in app bar
- Confirm deletion (removes all images and notes)

### Search and Filter

#### Search Products
- Tap search icon on home screen
- Enter product name or store
- Results update in real-time

#### Filter by Category
- Tap filter icon on home screen
- Select category (Electronics, Appliances, etc.)
- Or select "All" to show everything

### Backup and Restore

#### Create Backup
1. Open **Settings** from home screen menu
2. Tap **"Export Backup"**
3. Wait for backup creation (includes all products, images, notes)
4. Share ZIP file via any app (Drive, Email, etc.)
5. Last backup date is tracked automatically

#### Restore from Backup
1. Open **Settings**
2. Tap **"Import Backup"**
3. Select ZIP file from storage
4. **Confirm restoration** (existing data will be replaced)
5. App automatically restores all products with images

### Notifications

#### Warranty Reminders
- Automatically scheduled 30 days before expiry
- Notification shows product name and expiry date
- Toggle notifications in Settings

#### Notification Settings
- Enable/disable warranty reminders
- Requires notification permission on first use
- Android: POST_NOTIFICATIONS permission (Android 13+)
- iOS: Requested on first notification schedule

## Key Design Decisions

### Offline-First Architecture
- All data stored locally in SQLite database
- No network dependencies or cloud services
- Images saved to app directory with optimized thumbnails
- Works perfectly in airplane mode

### Image Optimization
- Thumbnails cached at 400px width for grid view
- Detail view images at 1200px width
- Original images preserved for backup
- Reduces memory usage and improves performance

### OCR Integration
- Google ML Kit for on-device text recognition
- Extracts dates (DD/MM/YYYY, DD-MM-YYYY formats)
- Extracts amounts (currency symbols + numbers, "Total" keyword)
- Runs locally without cloud API calls

### Backup Format
- ZIP archive with JSON metadata + images
- products.json: All product data with references
- attachments/ folder: All images with preserved paths
- notes.json: Service history with timestamps
- Portable and human-readable format

### Notification Strategy
- Scheduled exactly 30 days before expiry
- Unique notification ID per product
- Reschedules on product update
- Cancels on product deletion

## Troubleshooting

### OCR Not Detecting Dates
- Ensure bill has clear printed date
- Supported formats: DD/MM/YYYY, DD-MM-YYYY
- Hold camera steady for clear capture
- Good lighting improves recognition

### Notifications Not Working
- **Android**: Enable POST_NOTIFICATIONS permission in app settings
- **iOS**: Allow notifications when prompted
- Check Settings > Notifications toggle is enabled
- Verify warranty duration creates future expiry date

### Backup File Not Opening
- Ensure file is complete ZIP archive
- Check file has .zip extension
- Verify backup was created successfully
- Try exporting new backup if corrupted

### Images Not Loading
- Check storage permission granted
- Verify images exist in app directory
- Re-add images if missing after restore
- Check available storage space

## Contributing
Contributions are welcome! Please follow the existing architecture patterns and ensure all features work offline.

## License
This project is licensed under the MIT License.

## Support
For issues or questions, please open an issue on the repository.

