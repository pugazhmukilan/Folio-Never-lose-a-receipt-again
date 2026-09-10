import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../../data/models/item.dart';
import '../../../data/models/item_field.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();
  @override
  List<Object?> get props => [];
}

class LoadItems extends ItemEvent {
  const LoadItems();
}

class LoadItemDetails extends ItemEvent {
  final int itemId;
  const LoadItemDetails(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class CreateItem extends ItemEvent {
  final Item item;
  final List<ItemField> fields;
  final List<String> attachmentPaths;
  final Completer<void>? completion;

  const CreateItem({
    required this.item,
    required this.fields,
    this.attachmentPaths = const [],
    this.completion,
  });

  @override
  List<Object?> get props => [item, fields, attachmentPaths];
}

class UpdateItem extends ItemEvent {
  final Item item;
  final List<ItemField> fields;
  final List<int> deletedFieldIds;
  final List<String> newAttachmentPaths;
  final List<int> deletedAttachmentIds;
  final Completer<void>? completion;

  const UpdateItem({
    required this.item,
    required this.fields,
    this.deletedFieldIds = const [],
    this.newAttachmentPaths = const [],
    this.deletedAttachmentIds = const [],
    this.completion,
  });

  @override
  List<Object?> get props => [
    item,
    fields,
    deletedFieldIds,
    newAttachmentPaths,
    deletedAttachmentIds,
  ];
}

class DeleteItem extends ItemEvent {
  final int itemId;
  final Completer<void>? completion;

  const DeleteItem(this.itemId, {this.completion});
  @override
  List<Object?> get props => [itemId];
}

class ToggleFavorite extends ItemEvent {
  final int itemId;
  final bool value;
  const ToggleFavorite(this.itemId, this.value);
  @override
  List<Object?> get props => [itemId, value];
}

class SearchItems extends ItemEvent {
  final String query;
  const SearchItems(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterItemsByCategory extends ItemEvent {
  final int? categoryId; // null = show all
  const FilterItemsByCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class LoadDashboardStats extends ItemEvent {
  const LoadDashboardStats();
}

class DeleteAttachment extends ItemEvent {
  final int attachmentId;
  final String path;
  final int itemId;

  const DeleteAttachment({
    required this.attachmentId,
    required this.path,
    required this.itemId,
  });

  @override
  List<Object?> get props => [attachmentId, path, itemId];
}
