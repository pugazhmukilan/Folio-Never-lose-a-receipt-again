<div align="center">
  <img src="assets/logo.png" alt="Kipt Logo" width="120" height="120">
  
  # Kipt
  
  ### Your Personal Warranty Management Solution
  
  <p align="center">
    Never lose a receipt. Never miss a warranty claim deadline.
  </p>
  
  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-3.24.5-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/Dart-3.5.4-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
    <img src="https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge" alt="Version">
    <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License">
  </p>
  
  <p align="center">
    <a href="#-features">Features</a> •
    <a href="#-screenshots">Screenshots</a> •
    <a href="#-architecture">Architecture</a> •
    <a href="#-installation">Installation</a> •
    <a href="#-tech-stack">Tech Stack</a> •
    <a href="#-usage">Usage</a>
  </p>
</div>

---

## 📱 About

**Kipt** is a powerful, offline-first mobile application designed to help you manage product warranties, bills, and receipts effortlessly. Built with Flutter and following clean architecture principles, Kipt ensures your important documents are organized, secure, and always accessible—no internet required.

### Why Kipt?

- 💯 **100% Offline** - Your data never leaves your device
- 🔒 **Secure** - Biometric authentication and encrypted backups
- 📸 **Smart Scanning** - OCR technology extracts data from receipts
- 🔔 **Never Miss Deadlines** - Timely warranty expiry notifications
- 🎨 **Beautiful UI** - Modern Material Design 3 interface
- 🚀 **Fast & Reliable** - Optimized SQLite database

---

## ✨ Features

### 🎯 Core Features

#### 📋 **Warranty Management**
- Track warranties for all your products in one place
- Automatic expiry date calculations
- Visual warranty status indicators (Active, Expiring Soon, Expired)
- Multi-tier reminder notifications (30, 7, and 1 day before expiry)

#### 📸 **Smart Receipt Scanning**
- Capture bills and receipts with your camera
- OCR technology automatically extracts:
  - Purchase dates
  - Product names
  - Amounts and prices
  - Retailer information
- Support for multiple document formats

#### 🗂️ **Product Organization**
- **9 Smart Categories:**
  - 📱 Electronics (phones, laptops, cameras)
  - 🏠 Home Appliances (kitchen, cleaning)
  - ⚡ Appliances (washing machines, refrigerators)
  - 🛋️ Furniture (beds, sofas, tables)
  - 🚗 Vehicles (cars, bikes, scooters)
  - 🔧 Tools (power tools, equipment)
  - 🏘️ Rentals (properties with tenant management)
  - 📦 Others (miscellaneous items)
- Advanced search and filtering
- Quick category switching with chips

#### 🖼️ **Multi-Image Support**
- Store unlimited images per product
- Receipt photos
- Warranty cards
- Product images
- Serial number photos
- Image carousel with zoom and swipe
- Full-screen image viewer

#### 💾 **Backup & Restore**
- Export all data as encrypted ZIP archives
- Share backups via any app (email, cloud storage, messaging)
- Import and restore complete data with one tap
- Includes all images and documents
- Version-controlled backups

#### 🏠 **Rental Property Management**
- Special mode for rental properties
- Tenant information management:
  - Name, phone, email
  - Emergency contacts
- Lease tracking:
  - Start and end dates
  - Monthly rent amount
  - Security deposit
  - Payment due dates
- Utility tracking:
  - Electricity and water meter readings
  - Gas connection numbers
- Extra charges and fees tracking
- Agreement number storage

### 🎨 User Experience

#### 🌓 **Theme Support**
- Light theme with clean aesthetics
- Dark theme (AMOLED-friendly)
- System theme following device settings
- Smooth theme transitions

#### 🔐 **Security**
- Biometric authentication (fingerprint/face)
- PIN/Pattern/Password support
- App lock on startup
- Secure local storage
- No data collection or tracking

#### 🔔 **Smart Notifications**
- Configurable reminder periods
- Background notification service
- Warranty expiry alerts
- Customizable notification settings

#### ⚡ **Performance**
- Optimized SQLite database
- Lazy loading and pagination
- Image caching
- Smooth 60 FPS animations
- Minimal memory footprint

---

## 📸 Screenshots

<div align="center">
  <p><i>Screenshots coming soon...</i></p>
  
  <!-- Placeholder for screenshots -->
  <table>
    <tr>
      <td><b>Home Screen</b></td>
      <td><b>Product Details</b></td>
      <td><b>Add Product</b></td>
    </tr>
    <tr>
      <td><i>Light theme with product grid</i></td>
      <td><i>Detailed warranty information</i></td>
      <td><i>Smart form with OCR scanning</i></td>
    </tr>
  </table>
  
  <table>
    <tr>
      <td><b>Categories</b></td>
      <td><b>Settings</b></td>
      <td><b>Dark Theme</b></td>
    </tr>
    <tr>
      <td><i>Filter by category</i></td>
      <td><i>Customization options</i></td>
      <td><i>Beautiful dark mode</i></td>
    </tr>
  </table>
</div>

---

## 🏗️ Architecture

Kipt follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                           # Core utilities and constants
│   ├── constants/                  # App-wide constants
│   │   └── app_constants.dart     # Configuration and constants
│   ├── theme/                      # Material Design 3 themes
│   │   └── app_theme.dart         # Light and dark themes
│   └── utils/                      # Helper utilities
│       ├── date_utils.dart        # Date manipulation helpers
│       └── preferences_helper.dart # Shared preferences wrapper
│
├── data/                           # Data layer
│   ├── models/                     # Domain models
│   │   ├── product.dart           # Product entity
│   │   ├── product_with_details.dart # Aggregated product data
│   │   └── rental_data.dart       # Rental property data
│   ├── database/                   # Persistence layer
│   │   └── database_helper.dart   # SQLite database operations
│   └── repositories/               # Repository implementations
│       ├── product_repository.dart # Product CRUD operations
│       ├── image_storage_service.dart # Image file management
│       ├── notification_service.dart # Local notifications
│       ├── backup_service.dart    # Backup/restore operations
│       └── auth_service.dart      # Biometric authentication
│
└── presentation/                   # Presentation layer
    ├── bloc/                       # BLoC state management
    │   ├── product/               # Product state management
    │   ├── notification/          # Notification state management
    │   ├── backup/                # Backup state management
    │   └── theme/                 # Theme state management
    ├── screens/                    # UI screens
    │   ├── splash_screen.dart     # App entry point
    │   ├── welcome_screen.dart    # Onboarding
    │   ├── home_screen.dart       # Main container
    │   ├── products_list_screen.dart # Product grid view
    │   ├── product_detail_screen.dart # Product details
    │   ├── add_product_screen.dart # Add/edit products
    │   ├── settings_screen.dart   # App settings
    │   ├── auth_screen.dart       # Authentication
    │   └── about_screen.dart      # About the app
    └── widgets/                    # Reusable UI components
        ├── product_card.dart      # Product grid card
        ├── image_carousel.dart    # Image viewer
        ├── rental_fields_widget.dart # Rental form fields
        └── common_widgets.dart    # Shared widgets
```

### 🔄 State Management

**BLoC Pattern** (Business Logic Component) for predictable state management:

- ✅ **ProductBloc** - Product CRUD, search, and filtering
- ✅ **NotificationBloc** - Warranty reminder scheduling
- ✅ **BackupBloc** - Data export and import operations
- ✅ **ThemeCubit** - Theme switching (light/dark/system)

### 🗄️ Database Schema

**SQLite** with 4 normalized tables:

1. **products** - Core product information
2. **images** - Product image paths (one-to-many)
3. **notes** - Service notes (one-to-many)
4. **rental_data** - Rental property details (one-to-one)

---

## 🚀 Installation

### Prerequisites

- Flutter SDK (3.24.5 or higher)
- Dart SDK (3.5.4 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/kipt.git
   cd kipt
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Check Flutter setup**
   ```bash
   flutter doctor
   ```

4. **Run the app**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

5. **Build APK (Android)**
   ```bash
   # Release APK
   flutter build apk --release
   
   # Split APK by ABI (smaller size)
   flutter build apk --split-per-abi
   ```

6. **Build IPA (iOS)**
   ```bash
   flutter build ios --release
   ```

---

## 🛠️ Tech Stack

### Framework & Language
- **Flutter** 3.24.5 - Cross-platform UI framework
- **Dart** 3.5.4 - Programming language

### State Management
- **flutter_bloc** ^8.1.6 - BLoC pattern implementation
- **equatable** ^2.0.5 - Value equality

### Database & Storage
- **sqflite** ^2.4.1 - SQLite database
- **shared_preferences** ^2.3.3 - Key-value storage
- **path_provider** ^2.1.5 - File system paths

### Image Processing
- **image_picker** ^1.1.2 - Camera and gallery access
- **image_gallery_saver_plus** ^3.0.5 - Save to gallery
- **google_mlkit_text_recognition** ^0.13.1 - OCR scanning

### UI Components
- **flutter_staggered_grid_view** ^0.7.0 - Masonry grid layout
- **smooth_page_indicator** ^1.2.0+3 - Page indicators

### Notifications
- **flutter_local_notifications** ^18.0.1 - Local notifications
- **timezone** ^0.9.4 - Timezone support

### Security
- **local_auth** ^2.3.0 - Biometric authentication

### Utilities
- **intl** ^0.19.0 - Internationalization
- **file_picker** ^8.1.4 - File selection
- **share_plus** ^10.1.2 - Share functionality
- **archive** ^3.6.1 - ZIP file operations
- **printing** ^5.13.4 - PDF generation (future)

---

## 📖 Usage Guide

### Adding Your First Product

1. **Open Kipt** and complete the welcome tutorial
2. **Tap the + button** at the bottom of the screen
3. **Choose a method:**
   - 📸 **Scan Receipt** - Use camera to capture and auto-extract data
   - ✍️ **Manual Entry** - Type in product details
4. **Fill in details:**
   - Product name
   - Category
   - Purchase date
   - Expiry date (auto-calculated from warranty duration)
   - Purchase amount
5. **Add images** (receipt, product photos, warranty card)
6. **Save** - Your product is now tracked!

### Scanning Receipts with OCR

1. Tap the **camera icon** in the add product form
2. Take a clear photo of your receipt in good lighting
3. Wait for OCR processing (2-3 seconds)
4. Review extracted data:
   - ✅ Purchase date
   - ✅ Amount
   - ✅ Product name (if detected)
5. Edit if needed and save

### Managing Rental Properties

1. Select **"Rentals"** category when adding a product
2. Fill in standard details (property address as product name)
3. Expand **"Rental Details"** section
4. Enter tenant information:
   - Personal details (name, phone, email)
   - Emergency contact
5. Add lease information:
   - Start and end dates
   - Monthly rent and security deposit
   - Payment due date
6. Track utilities:
   - Meter readings
   - Connection numbers
7. Add extra charges if applicable
8. Save rental property

### Backup & Restore

#### Creating a Backup
1. Go to **Settings** → **Backup & Restore**
2. Tap **"Create Backup"**
3. Wait for ZIP file generation
4. Share via:
   - Email
   - Google Drive
   - WhatsApp
   - Any file sharing app

#### Restoring from Backup
1. Go to **Settings** → **Backup & Restore**
2. Tap **"Import Backup"**
3. Select your `.zip` backup file
4. Confirm restore (⚠️ replaces all current data)
5. Wait for import to complete
6. All products restored with images!

### Setting Up Notifications

1. Go to **Settings** → **Notifications**
2. Enable **"Warranty Reminders"**
3. Set reminder period (default: 30 days)
4. Grant notification permissions when prompted
5. Receive alerts before warranty expiry!

### Enabling App Lock

1. Ensure device has PIN/Pattern/Biometric set up
2. Go to **Settings** → **Security**
3. Toggle **"App Lock"**
4. Authenticate to confirm
5. App now requires authentication on startup

---

## 🎯 Key Highlights

### Why Clean Architecture?

- ✅ **Testable** - Easy unit and integration testing
- ✅ **Maintainable** - Clear separation of concerns
- ✅ **Scalable** - Add features without breaking existing code
- ✅ **Independent** - UI, business logic, and data are decoupled

### Why BLoC?

- ✅ **Predictable** - Single source of truth for state
- ✅ **Reusable** - Business logic independent of UI
- ✅ **Testable** - Easy to write unit tests
- ✅ **Performance** - Optimized rebuilds

### Why SQLite?

- ✅ **Fast** - Local queries with zero latency
- ✅ **Offline** - No internet dependency
- ✅ **Reliable** - ACID transactions
- ✅ **Lightweight** - Minimal storage footprint

---

## 🔒 Privacy & Security

### Data Privacy
- ✅ **100% Offline** - No cloud storage or sync
- ✅ **Local Storage** - All data stored on device
- ✅ **No Tracking** - Zero analytics or telemetry
- ✅ **No Permissions Abuse** - Only essential permissions requested

### Security Features
- 🔐 Biometric authentication (fingerprint/face)
- 🔐 PIN/Pattern/Password support
- 🔐 Encrypted backup archives
- 🔐 Secure file storage
- 🔐 No network communication

### Permissions Required
- 📷 **Camera** - For receipt scanning
- 🖼️ **Storage** - For saving images
- 🔔 **Notifications** - For warranty reminders
- 🔓 **Biometric** - For app lock (optional)

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guide
- Maintain clean architecture principles
- Write unit tests for business logic
- Update documentation for new features
- Keep commits atomic and descriptive

---

## 🐛 Known Issues

- OCR accuracy depends on image quality
- Some receipt formats may not be recognized
- Rental category limited to one property per entry

---

## 🗺️ Roadmap

### Version 1.1.0
- [ ] Cloud backup sync (optional)
- [ ] PDF receipt export
- [ ] Warranty claim tracking
- [ ] Multi-language support
- [ ] Widget for home screen

### Version 1.2.0
- [ ] Product price tracking
- [ ] Brand warranty database
- [ ] Service center locator
- [ ] Extended warranty recommendations
- [ ] Spending analytics

### Version 2.0.0
- [ ] Web dashboard
- [ ] Family sharing
- [ ] QR code scanning for products
- [ ] AI-powered product recognition
- [ ] Integration with e-commerce platforms

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Google ML Kit for OCR capabilities
- Open source community for excellent packages

---

## 📞 Support

Having issues? Here's how to get help:

1. **Check the [About Screen](#)** in the app for detailed usage instructions
2. **Read the [Usage Guide](#-usage-guide)** above
3. **Open an issue** on GitHub with:
   - Device model and OS version
   - Flutter version
   - Steps to reproduce
   - Error logs (if applicable)

---

<div align="center">
  <p>Made with ❤️ and Flutter</p>
  <p>
    <sub>Star ⭐ this repository if you found it helpful!</sub>
  </p>
  
  <img src="assets/logo.png" alt="Kipt Logo" width="60" height="60">
  
  <p><b>Kipt - Your Warranty Management Solution</b></p>
</div>
