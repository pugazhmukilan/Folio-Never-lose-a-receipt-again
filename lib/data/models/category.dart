import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final bool isPreset;

  const Category({
    this.id,
    required this.name,
    this.isPreset = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_preset': isPreset ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      isPreset: (map['is_preset'] as int? ?? 0) == 1,
    );
  }

  Category copyWith({int? id, String? name, bool? isPreset}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      isPreset: isPreset ?? this.isPreset,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Category.fromJson(Map<String, dynamic> json) =>
      Category.fromMap(json);

  @override
  List<Object?> get props => [id, name, isPreset];

  @override
  String toString() => 'Category{id: $id, name: $name, isPreset: $isPreset}';
}
