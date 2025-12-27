import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final String iconName;
  final bool isSystem;
  final bool isRentalType;

  const Category({
    this.id,
    required this.name,
    required this.iconName,
    this.isSystem = false,
    this.isRentalType = false,
  });

  // Create Category from database map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconName: map['icon_name'] as String,
      isSystem: (map['is_system'] as int) == 1,
      isRentalType: (map['is_rental_type'] as int) == 1,
    );
  }

  // Convert Category to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'is_system': isSystem ? 1 : 0,
      'is_rental_type': isRentalType ? 1 : 0,
    };
  }

  // Create a copy with modified fields
  Category copyWith({
    int? id,
    String? name,
    String? iconName,
    bool? isSystem,
    bool? isRentalType,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      isSystem: isSystem ?? this.isSystem,
      isRentalType: isRentalType ?? this.isRentalType,
    );
  }

  @override
  List<Object?> get props => [id, name, iconName, isSystem, isRentalType];

  @override
  String toString() {
    return 'Category{id: $id, name: $name, iconName: $iconName, isSystem: $isSystem, isRentalType: $isRentalType}';
  }
}
