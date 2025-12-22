import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Model for storing OCR extracted data from bills
class OcrData extends Equatable {
  final int? id;
  final int productId;
  final String? extractedText;
  final List<DateTime> extractedDates;
  final List<double> extractedAmounts;
  final String createdAt;
  
  const OcrData({
    this.id,
    required this.productId,
    this.extractedText,
    required this.extractedDates,
    required this.extractedAmounts,
    required this.createdAt,
  });
  
  /// Convert OcrData to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'extracted_text': extractedText,
      'extracted_dates': jsonEncode(extractedDates.map((d) => d.toIso8601String()).toList()),
      'extracted_amounts': jsonEncode(extractedAmounts),
      'created_at': createdAt,
    };
  }
  
  /// Create OcrData from Map (database query result)
  factory OcrData.fromMap(Map<String, dynamic> map) {
    final datesJson = map['extracted_dates'] as String?;
    final amountsJson = map['extracted_amounts'] as String?;
    
    List<DateTime> dates = [];
    if (datesJson != null && datesJson.isNotEmpty) {
      final dateStrings = List<String>.from(jsonDecode(datesJson));
      dates = dateStrings.map((s) => DateTime.parse(s)).toList();
    }
    
    List<double> amounts = [];
    if (amountsJson != null && amountsJson.isNotEmpty) {
      amounts = List<double>.from(jsonDecode(amountsJson));
    }
    
    return OcrData(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      extractedText: map['extracted_text'] as String?,
      extractedDates: dates,
      extractedAmounts: amounts,
      createdAt: map['created_at'] as String,
    );
  }
  
  /// Convert to JSON for backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'extracted_text': extractedText,
      'extracted_dates': extractedDates.map((d) => d.toIso8601String()).toList(),
      'extracted_amounts': extractedAmounts,
      'created_at': createdAt,
    };
  }
  
  /// Create from JSON for restore
  factory OcrData.fromJson(Map<String, dynamic> json) {
    final datesJson = json['extracted_dates'] as List?;
    final amountsJson = json['extracted_amounts'] as List?;
    
    List<DateTime> dates = [];
    if (datesJson != null) {
      dates = datesJson.map((s) => DateTime.parse(s.toString())).toList();
    }
    
    List<double> amounts = [];
    if (amountsJson != null) {
      amounts = amountsJson.map((a) => (a as num).toDouble()).toList();
    }
    
    return OcrData(
      id: json['id'] as int?,
      productId: json['product_id'] as int,
      extractedText: json['extracted_text'] as String?,
      extractedDates: dates,
      extractedAmounts: amounts,
      createdAt: json['created_at'] as String,
    );
  }
  
  @override
  List<Object?> get props => [id, productId, extractedText, extractedDates, extractedAmounts, createdAt];
  
  @override
  String toString() {
    return 'OcrData{id: $id, productId: $productId, datesCount: ${extractedDates.length}, amountsCount: ${extractedAmounts.length}}';
  }
}
