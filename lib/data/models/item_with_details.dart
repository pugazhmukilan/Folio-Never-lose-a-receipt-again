import 'item.dart';
import 'item_field.dart';
import 'attachment.dart';

/// Dashboard-level statistics computed at field level (spec §5).
class DashboardStats {
  final int active;
  final int expiringSoon;
  final int expired;

  const DashboardStats({
    this.active = 0,
    this.expiringSoon = 0,
    this.expired = 0,
  });

  int get total => active + expiringSoon + expired;
}

/// An Item combined with all its fields and attachments, plus resolved category name.
class ItemWithDetails {
  final Item item;
  final List<ItemField> fields;
  final List<Attachment> attachments;
  final String? categoryName;

  const ItemWithDetails({
    required this.item,
    required this.fields,
    required this.attachments,
    this.categoryName,
  });

  // ---------------------------------------------------------------------------
  // Convenience accessors
  // ---------------------------------------------------------------------------

  /// All DATE fields with reminder_enabled = true.
  List<ItemField> get reminderFields => fields.where((f) =>
      f.fieldType == FieldType.date && f.reminderEnabled).toList();

  /// The nearest upcoming (or most overdue) reminder date field.
  ItemField? get nearestDateField {
    final rf = reminderFields;
    if (rf.isEmpty) return null;
    rf.sort((a, b) {
      final da = a.parsedDate;
      final db = b.parsedDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return rf.first;
  }

  /// The most urgent status this item has across all its date fields.
  /// Priority: Expired > Expiring > Active > noReminder (null).
  FieldStatus? get mostUrgentStatus {
    final statuses = reminderFields.map((f) => f.status).toList();
    if (statuses.isEmpty) return null;
    if (statuses.contains(FieldStatus.expired)) return FieldStatus.expired;
    if (statuses.contains(FieldStatus.expiringSoon)) return FieldStatus.expiringSoon;
    if (statuses.contains(FieldStatus.active)) return FieldStatus.active;
    return null;
  }

  /// First photo attachment (for thumbnails in list).
  Attachment? get firstPhoto =>
      attachments.where((a) => a.isPhoto).cast<Attachment?>().firstOrNull;

  ItemWithDetails copyWith({
    Item? item,
    List<ItemField>? fields,
    List<Attachment>? attachments,
    String? categoryName,
  }) {
    return ItemWithDetails(
      item: item ?? this.item,
      fields: fields ?? this.fields,
      attachments: attachments ?? this.attachments,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
