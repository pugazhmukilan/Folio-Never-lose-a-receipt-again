import 'dart:convert';

/// Model for storing House Rental specific information
class RentalData {
  // Tenant Information
  final String? tenantName;
  final String? tenantPhone;
  final String? tenantEmail;
  final String? emergencyContact;
  final int? familyMembers;
  
  // Property Details
  final String? propertyAddress;
  final String? propertyType; // Apartment, Villa, Independent House, etc.
  
  // Financial Details
  final String? monthlyRent;
  final String? securityDeposit;
  final String? paymentDueDate; // e.g., "1st", "5th"
  final String? paymentMethod; // Cash, Bank Transfer, Online
  final Map<String, String>? extraCharges; // Water, Maintenance, etc.
  
  // Lease Information
  final String? leaseStartDate;
  final String? leaseEndDate;
  final String? agreementNumber;
  final int? lockInPeriodMonths;
  
  // Utilities
  final String? electricityMeterReading;
  final String? waterMeterReading;
  final String? gasConnectionNumber;
  
  const RentalData({
    this.tenantName,
    this.tenantPhone,
    this.tenantEmail,
    this.emergencyContact,
    this.familyMembers,
    this.propertyAddress,
    this.propertyType,
    this.monthlyRent,
    this.securityDeposit,
    this.paymentDueDate,
    this.paymentMethod,
    this.extraCharges,
    this.leaseStartDate,
    this.leaseEndDate,
    this.agreementNumber,
    this.lockInPeriodMonths,
    this.electricityMeterReading,
    this.waterMeterReading,
    this.gasConnectionNumber,
  });
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
      'tenantEmail': tenantEmail,
      'emergencyContact': emergencyContact,
      'familyMembers': familyMembers,
      'propertyAddress': propertyAddress,
      'propertyType': propertyType,
      'monthlyRent': monthlyRent,
      'securityDeposit': securityDeposit,
      'paymentDueDate': paymentDueDate,
      'paymentMethod': paymentMethod,
      'extraCharges': extraCharges,
      'leaseStartDate': leaseStartDate,
      'leaseEndDate': leaseEndDate,
      'agreementNumber': agreementNumber,
      'lockInPeriodMonths': lockInPeriodMonths,
      'electricityMeterReading': electricityMeterReading,
      'waterMeterReading': waterMeterReading,
      'gasConnectionNumber': gasConnectionNumber,
    };
  }
  
  /// Create from JSON
  factory RentalData.fromJson(Map<String, dynamic> json) {
    Map<String, String>? charges;
    if (json['extraCharges'] != null) {
      charges = Map<String, String>.from(json['extraCharges'] as Map);
    }
    
    return RentalData(
      tenantName: json['tenantName'] as String?,
      tenantPhone: json['tenantPhone'] as String?,
      tenantEmail: json['tenantEmail'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      familyMembers: json['familyMembers'] as int?,
      propertyAddress: json['propertyAddress'] as String?,
      propertyType: json['propertyType'] as String?,
      monthlyRent: json['monthlyRent'] as String?,
      securityDeposit: json['securityDeposit'] as String?,
      paymentDueDate: json['paymentDueDate'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      extraCharges: charges,
      leaseStartDate: json['leaseStartDate'] as String?,
      leaseEndDate: json['leaseEndDate'] as String?,
      agreementNumber: json['agreementNumber'] as String?,
      lockInPeriodMonths: json['lockInPeriodMonths'] as int?,
      electricityMeterReading: json['electricityMeterReading'] as String?,
      waterMeterReading: json['waterMeterReading'] as String?,
      gasConnectionNumber: json['gasConnectionNumber'] as String?,
    );
  }
  
  /// Convert to JSON string for database storage
  String toJsonString() {
    return jsonEncode(toJson());
  }
  
  /// Create from JSON string
  factory RentalData.fromJsonString(String jsonString) {
    return RentalData.fromJson(jsonDecode(jsonString));
  }
  
  /// Create a copy with updated fields
  RentalData copyWith({
    String? tenantName,
    String? tenantPhone,
    String? tenantEmail,
    String? emergencyContact,
    int? familyMembers,
    String? propertyAddress,
    String? propertyType,
    String? monthlyRent,
    String? securityDeposit,
    String? paymentDueDate,
    String? paymentMethod,
    Map<String, String>? extraCharges,
    String? leaseStartDate,
    String? leaseEndDate,
    String? agreementNumber,
    int? lockInPeriodMonths,
    String? electricityMeterReading,
    String? waterMeterReading,
    String? gasConnectionNumber,
  }) {
    return RentalData(
      tenantName: tenantName ?? this.tenantName,
      tenantPhone: tenantPhone ?? this.tenantPhone,
      tenantEmail: tenantEmail ?? this.tenantEmail,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      familyMembers: familyMembers ?? this.familyMembers,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      propertyType: propertyType ?? this.propertyType,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      extraCharges: extraCharges ?? this.extraCharges,
      leaseStartDate: leaseStartDate ?? this.leaseStartDate,
      leaseEndDate: leaseEndDate ?? this.leaseEndDate,
      agreementNumber: agreementNumber ?? this.agreementNumber,
      lockInPeriodMonths: lockInPeriodMonths ?? this.lockInPeriodMonths,
      electricityMeterReading: electricityMeterReading ?? this.electricityMeterReading,
      waterMeterReading: waterMeterReading ?? this.waterMeterReading,
      gasConnectionNumber: gasConnectionNumber ?? this.gasConnectionNumber,
    );
  }
  
  /// Calculate total monthly charges (rent + extra charges)
  double getTotalMonthlyCharges() {
    double total = double.tryParse(monthlyRent ?? '0') ?? 0;
    if (extraCharges != null) {
      for (var value in extraCharges!.values) {
        total += double.tryParse(value) ?? 0;
      }
    }
    return total;
  }
}
