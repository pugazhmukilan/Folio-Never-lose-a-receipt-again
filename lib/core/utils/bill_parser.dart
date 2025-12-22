import 'dart:math';

class BillParser {
  /// Parses OCR-extracted bill text into structured fields.
  ///
  /// This is heuristic and designed to work across many retail bill formats.
  /// Returned keys are stable strings so they can be stored as JSON.
  static Map<String, dynamic> parse(String extractedText) {
    final lines = _normalizeLines(extractedText);

    final sellerName = _guessSellerName(lines);
    final buyerName = _extractLabeledValue(lines, [
      'bill to',
      'billed to',
      'customer',
      'customer name',
      'name',
      'ship to',
      'deliver to',
    ]);

    final invoiceNumber = _extractInvoiceNumber(lines);
    final billDateText = _extractBillDateText(lines);

    final currency = _detectCurrency(extractedText);

    final subtotal = _extractAmountForLabels(lines, const [
      'sub total',
      'subtotal',
      'taxable amount',
      'taxable value',
      'net amount',
    ]);

    final tax = _extractAmountForLabels(lines, const [
      'tax',
      'gst',
      'cgst',
      'sgst',
      'igst',
      'vat',
    ]);

    final total = _extractAmountForLabels(lines, const [
          'grand total',
          'total amount',
          'amount payable',
          'net payable',
          'total',
        ]) ??
        _fallbackTotalFromAnyAmounts(lines);

    final paymentMethod = _detectPaymentMethod(extractedText);

    final gstin = _extractFirstMatch(extractedText, RegExp(
      r'\b[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]\b',
    ));

    final phone = _extractFirstMatch(extractedText, RegExp(
      r'(?:(?:\+?\d{1,3}[\s-]?)?(?:\(?\d{2,4}\)?[\s-]?)?\d{6,10})',
    ));

    final result = <String, dynamic>{};

    void putIfNonEmpty(String key, String? value) {
      final v = value?.trim();
      if (v != null && v.isNotEmpty) {
        result[key] = v;
      }
    }

    void putIfNum(String key, num? value) {
      if (value != null) {
        result[key] = value;
      }
    }

    putIfNonEmpty('seller_name', sellerName);
    putIfNonEmpty('buyer_name', buyerName);
    putIfNonEmpty('invoice_number', invoiceNumber);
    putIfNonEmpty('bill_date_text', billDateText);
    putIfNonEmpty('currency', currency);
    putIfNonEmpty('payment_method', paymentMethod);
    putIfNonEmpty('gstin', gstin);

    // Phone regex is permissive; filter common false positives.
    final cleanedPhone = _cleanPhone(phone);
    putIfNonEmpty('seller_phone', cleanedPhone);

    putIfNum('subtotal', subtotal);
    putIfNum('tax', tax);
    putIfNum('total', total);

    return result;
  }

  static List<String> _normalizeLines(String text) {
    return text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList(growable: false);
  }

  static String? _guessSellerName(List<String> lines) {
    if (lines.isEmpty) return null;

    // Take early lines; seller/merchant name is typically near top.
    final candidates = lines.take(min(lines.length, 8)).toList();

    bool isNoise(String s) {
      final lower = s.toLowerCase();
      const noiseTokens = [
        'tax invoice',
        'invoice',
        'receipt',
        'cash memo',
        'gstin',
        'tin',
        'phone',
        'mobile',
        'customer',
        'bill to',
        'billed to',
        'date',
        'time',
        'table',
        'token',
      ];
      if (noiseTokens.any(lower.contains)) return true;
      // Too numeric / symbol heavy.
      final letters = RegExp(r'[A-Za-z]').allMatches(s).length;
      return letters < 3;
    }

    final filtered = candidates.where((c) => !isNoise(c)).toList();
    if (filtered.isEmpty) return null;

    // Prefer the line with most letters (tends to be the merchant name).
    filtered.sort((a, b) {
      final la = RegExp(r'[A-Za-z]').allMatches(a).length;
      final lb = RegExp(r'[A-Za-z]').allMatches(b).length;
      final byLetters = lb.compareTo(la);
      if (byLetters != 0) return byLetters;
      return b.length.compareTo(a.length);
    });

    final best = filtered.first.trim();
    // Avoid absurdly long lines (addresses). Keep the first segment if needed.
    if (best.length > 60 && best.contains(',')) {
      return best.split(',').first.trim();
    }
    return best;
  }

  static String? _extractLabeledValue(List<String> lines, List<String> labels) {
    for (final line in lines.take(min(lines.length, 80))) {
      final lower = line.toLowerCase();
      for (final label in labels) {
        final idx = lower.indexOf(label);
        if (idx == -1) continue;

        // Prefer value after ':' or '-' if present.
        final after = line.substring(min(line.length, idx + label.length));
        final value = after
            .replaceFirst(RegExp(r'^[\s:;\-#]+'), '')
            .trim();
        if (value.isNotEmpty && value.length >= 2) {
          return _stripTrailingJunk(value);
        }

        // If label is standalone, try next line.
        final lineIndex = lines.indexOf(line);
        if (lineIndex >= 0 && lineIndex + 1 < lines.length) {
          final next = lines[lineIndex + 1].trim();
          if (next.isNotEmpty && next.length >= 2) {
            return _stripTrailingJunk(next);
          }
        }
      }
    }
    return null;
  }

  static String? _extractInvoiceNumber(List<String> lines) {
    final invoiceRegex = RegExp(
      r'\b(?:invoice|inv|bill|receipt)\s*(?:no\.?|number|#)?\s*[:#\-]?\s*([A-Z0-9][A-Z0-9\-/]{2,})\b',
      caseSensitive: false,
    );

    for (final line in lines.take(min(lines.length, 120))) {
      final m = invoiceRegex.firstMatch(line);
      if (m != null) {
        final value = m.group(1);
        if (value != null && value.trim().length >= 3) {
          return value.trim();
        }
      }
    }
    return null;
  }

  static String? _extractBillDateText(List<String> lines) {
    // Common patterns: 12/08/2025, 12-08-25, 2025-08-12, 12 Aug 2025.
    final dateRegex = RegExp(
      r'\b(\d{1,2}[\-/]\d{1,2}[\-/]\d{2,4}|\d{4}[\-/]\d{1,2}[\-/]\d{1,2}|\d{1,2}\s+[A-Za-z]{3,9}\s+\d{2,4})\b',
      caseSensitive: false,
    );

    for (final line in lines.take(min(lines.length, 120))) {
      final lower = line.toLowerCase();
      if (!lower.contains('date')) continue;
      final m = dateRegex.firstMatch(line);
      if (m != null) {
        return m.group(1)?.trim();
      }
    }

    // Fallback: first date-like token anywhere.
    for (final line in lines.take(min(lines.length, 200))) {
      final m = dateRegex.firstMatch(line);
      if (m != null) {
        return m.group(1)?.trim();
      }
    }

    return null;
  }

  static String? _detectCurrency(String text) {
    if (text.contains('₹') || RegExp(r'\bINR\b', caseSensitive: false).hasMatch(text)) {
      return 'INR';
    }
    if (text.contains(r'$') || RegExp(r'\bUSD\b', caseSensitive: false).hasMatch(text)) {
      return 'USD';
    }
    if (text.contains('€') || RegExp(r'\bEUR\b', caseSensitive: false).hasMatch(text)) {
      return 'EUR';
    }
    if (text.contains('£') || RegExp(r'\bGBP\b', caseSensitive: false).hasMatch(text)) {
      return 'GBP';
    }
    return null;
  }

  static String? _detectPaymentMethod(String text) {
    final lower = text.toLowerCase();
    const methods = <String, List<String>>{
      'UPI': ['upi', 'gpay', 'google pay', 'phonepe', 'paytm', 'bhim'],
      'Card': ['card', 'visa', 'mastercard', 'rupay', 'amex', 'debit', 'credit'],
      'Cash': ['cash'],
      'NetBanking': ['net banking', 'netbanking'],
      'Wallet': ['wallet', 'paytm wallet'],
    };

    for (final entry in methods.entries) {
      if (entry.value.any(lower.contains)) return entry.key;
    }

    return null;
  }

  static num? _extractAmountForLabels(List<String> lines, List<String> labels) {
    for (final line in lines.take(min(lines.length, 200))) {
      final lower = line.toLowerCase();
      if (!labels.any(lower.contains)) continue;

      final amounts = _extractAmountsFromLine(line);
      if (amounts.isEmpty) continue;

      // For labeled lines, typically the last number is the value.
      return amounts.last;
    }
    return null;
  }

  static num? _fallbackTotalFromAnyAmounts(List<String> lines) {
    // Heuristic: pick the maximum amount in the document.
    final all = <num>[];
    for (final line in lines.take(min(lines.length, 300))) {
      all.addAll(_extractAmountsFromLine(line));
    }
    if (all.isEmpty) return null;
    all.sort();
    return all.last;
  }

  static List<num> _extractAmountsFromLine(String line) {
    // Extract amounts like 1,234.56 or 1234 or 1234.00.
    final re = RegExp(r'(?<!\w)(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)(?!\w)');
    final matches = re.allMatches(line);
    final values = <num>[];
    for (final m in matches) {
      final raw = m.group(1);
      if (raw == null) continue;
      final normalized = raw.replaceAll(',', '');
      final parsed = num.tryParse(normalized);
      if (parsed == null) continue;

      // Filter out obvious non-money tokens (dates like 2025, times, etc.)
      if (parsed >= 1900 && parsed <= 2100) continue;
      values.add(parsed);
    }
    return values;
  }

  static String? _extractFirstMatch(String text, RegExp re) {
    final m = re.firstMatch(text);
    return m?.group(0);
  }

  static String _stripTrailingJunk(String value) {
    return value
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .replaceAll(RegExp(r'[,;\-]+$'), '')
        .trim();
  }

  static String? _cleanPhone(String? phone) {
    if (phone == null) return null;
    final digits = phone.replaceAll(RegExp(r'\D+'), '');
    if (digits.length < 8) return null;
    if (digits.length > 15) return null;
    return digits;
  }
}
