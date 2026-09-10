import 'package:equatable/equatable.dart';

/// The three field types a user can assign to a field.
enum FieldType { text, date, password }

extension FieldTypeExtension on FieldType {
  String get value {
    switch (this) {
      case FieldType.text:
        return 'TEXT';
      case FieldType.date:
        return 'DATE';
      case FieldType.password:
        return 'PASSWORD';
    }
  }

  static FieldType fromString(String s) {
    switch (s.toUpperCase()) {
      case 'DATE':
        return FieldType.date;
      case 'PASSWORD':
        return FieldType.password;
      default:
        return FieldType.text;
    }
  }

  String get displayLabel {
    switch (this) {
      case FieldType.text:
        return 'Text';
      case FieldType.date:
        return 'Date';
      case FieldType.password:
        return 'Password';
    }
  }
}

/// Status of a DATE field relative to today, used for dashboard counts.
enum FieldStatus { active, expiringSoon, expired, noReminder }

class ItemField extends Equatable {
  final int? id;
  final int itemId;
  final String label;
  final FieldType fieldType;

  /// For TEXT and DATE: plaintext value.
  /// For PASSWORD: a secure-storage key reference (not the actual value).
  final String value;

  /// Optional name for a login group (e.g. "ICICI Bank credentials"),
  /// stored on the Username field row. Only meaningful with login pairs.
  final String? loginTitle;

  /// Only meaningful when [fieldType] == [FieldType.date].
  final bool reminderEnabled;

  /// Days before the date to fire the reminder; null means "use app default".
  final int? reminderLeadDays;

  /// Position within the item's field list.
  final int sortOrder;

  const ItemField({
    this.id,
    required this.itemId,
    required this.label,
    required this.fieldType,
    required this.value,
    this.loginTitle,
    this.reminderEnabled = false,
    this.reminderLeadDays,
    this.sortOrder = 0,
  });

  // ---------------------------------------------------------------------------
  // Status helpers (only relevant for DATE fields)
  // ---------------------------------------------------------------------------

  /// Parses [value] as a DateTime. Returns null if not a DATE field or parse fails.
  DateTime? get parsedDate {
    if (fieldType != FieldType.date) return null;
    if (value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Computes the field's dashboard status based on today's date and lead time.
  FieldStatus get status {
    if (fieldType != FieldType.date || !reminderEnabled) {
      return FieldStatus.noReminder;
    }
    final date = parsedDate;
    if (date == null) return FieldStatus.noReminder;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final dateNormalized = DateTime(date.year, date.month, date.day);
    final leadDays = reminderLeadDays ?? 30;

    if (dateNormalized.isBefore(todayNormalized)) return FieldStatus.expired;
    if (dateNormalized.isBefore(todayNormalized.add(Duration(days: leadDays)))) {
      return FieldStatus.expiringSoon;
    }
    return FieldStatus.active;
  }

  /// Days remaining until the date (negative = overdue).
  int? get daysRemaining {
    final date = parsedDate;
    if (date == null) return null;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final dateNormalized = DateTime(date.year, date.month, date.day);
    return dateNormalized.difference(todayNormalized).inDays;
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'label': label,
      'field_type': fieldType.value,
      'value': value,
      'login_title': loginTitle,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_lead_days': reminderLeadDays,
      'sort_order': sortOrder,
    };
  }

  factory ItemField.fromMap(Map<String, dynamic> map) {
    return ItemField(
      id: map['id'] as int?,
      itemId: map['item_id'] as int,
      label: map['label'] as String,
      fieldType: FieldTypeExtension.fromString(map['field_type'] as String),
      value: map['value'] as String? ?? '',
      loginTitle: map['login_title'] as String?,
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      reminderLeadDays: map['reminder_lead_days'] as int?,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  ItemField copyWith({
    int? id,
    int? itemId,
    String? label,
    FieldType? fieldType,
    String? value,
    String? loginTitle,
    bool? reminderEnabled,
    int? reminderLeadDays,
    int? sortOrder,
  }) {
    return ItemField(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      label: label ?? this.label,
      fieldType: fieldType ?? this.fieldType,
      value: value ?? this.value,
      loginTitle: loginTitle ?? this.loginTitle,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory ItemField.fromJson(Map<String, dynamic> json) =>
      ItemField.fromMap(json);

  @override
  List<Object?> get props => [
        id,
        itemId,
        label,
        fieldType,
        value,
        loginTitle,
        reminderEnabled,
        reminderLeadDays,
        sortOrder,
      ];
}
