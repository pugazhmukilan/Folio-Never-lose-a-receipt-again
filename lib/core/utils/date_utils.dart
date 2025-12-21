import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Format DateTime to display format (e.g., "Jan 15, 2024")
  static String formatDisplayDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  /// Format DateTime to ISO8601 format for storage
  static String formatISO(DateTime date) {
    return date.toIso8601String();
  }
  
  /// Format DateTime for database storage
  static String formatForDatabase(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
  
  /// Parse ISO8601 string to DateTime
  static DateTime? parseISO(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse database format string to DateTime
  static DateTime? parseDatabase(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Calculate expiry date from purchase date and warranty duration (in months)
  static DateTime calculateExpiryDate(DateTime purchaseDate, int warrantyMonths) {
    return DateTime(
      purchaseDate.year,
      purchaseDate.month + warrantyMonths,
      purchaseDate.day,
    );
  }
  
  /// Get days until expiry
  static int getDaysUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }
  
  /// Check if warranty is expired
  static bool isExpired(DateTime expiryDate) {
    return DateTime.now().isAfter(expiryDate);
  }
  
  /// Check if warranty is expiring soon (within reminder days)
  static bool isExpiringSoon(DateTime expiryDate, int reminderDays) {
    final daysUntil = getDaysUntilExpiry(expiryDate);
    return daysUntil > 0 && daysUntil <= reminderDays;
  }
  
  /// Get expiry status text
  static String getExpiryStatusText(DateTime expiryDate) {
    if (isExpired(expiryDate)) {
      final days = DateTime.now().difference(expiryDate).inDays;
      return 'Expired $days day${days == 1 ? '' : 's'} ago';
    } else {
      final days = getDaysUntilExpiry(expiryDate);
      if (days == 0) {
        return 'Expires today';
      } else if (days == 1) {
        return 'Expires tomorrow';
      } else {
        return 'Expires in $days days';
      }
    }
  }
  
  /// Extract date patterns from OCR text (DD/MM/YYYY or DD-MM-YYYY)
  static List<DateTime> extractDatesFromText(String text) {
    final List<DateTime> dates = [];
    
    // Pattern: DD/MM/YYYY or DD-MM-YYYY
    final RegExp datePattern = RegExp(
      r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})',
    );
    
    final matches = datePattern.allMatches(text);
    
    for (final match in matches) {
      try {
        final day = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final year = int.parse(match.group(3)!);
        
        // Validate date
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          final date = DateTime(year, month, day);
          // Only add dates that are not too far in the past or future
          final now = DateTime.now();
          final difference = now.difference(date).inDays.abs();
          if (difference <= 3650) { // Within 10 years
            dates.add(date);
          }
        }
      } catch (e) {
        // Skip invalid dates
        continue;
      }
    }
    
    return dates;
  }
  
  /// Extract amount patterns from OCR text
  static List<double> extractAmountsFromText(String text) {
    final List<double> amounts = [];
    
    // Pattern: Currency symbols followed by numbers (e.g., ₹1,234.56, $99.99)
    final RegExp amountPattern = RegExp(
      r'[₹$€£¥]\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
    );
    
    final matches = amountPattern.allMatches(text);
    
    for (final match in matches) {
      try {
        final amountStr = match.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        if (amount > 0 && amount < 10000000) { // Reasonable range
          amounts.add(amount);
        }
      } catch (e) {
        continue;
      }
    }
    
    // Also look for "Total" or "Amount" keywords followed by numbers
    final RegExp totalPattern = RegExp(
      r'(?:total|amount|grand\s*total)[:\s]*[₹$€£¥]?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
      caseSensitive: false,
    );
    
    final totalMatches = totalPattern.allMatches(text);
    
    for (final match in totalMatches) {
      try {
        final amountStr = match.group(1)!.replaceAll(',', '');
        final amount = double.parse(amountStr);
        if (amount > 0 && amount < 10000000) {
          amounts.add(amount);
        }
      } catch (e) {
        continue;
      }
    }
    
    return amounts;
  }
}
