import 'package:equatable/equatable.dart';
import '../../../data/models/item_with_details.dart';

abstract class ItemState extends Equatable {
  const ItemState();
  @override
  List<Object?> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemsLoaded extends ItemState {
  final List<ItemWithDetails> items;
  final DashboardStats stats;
  final int? activeCategoryId;

  const ItemsLoaded(
    this.items,
    this.stats, {
    this.activeCategoryId,
  });

  @override
  List<Object?> get props => [items, stats, activeCategoryId];
}

class ItemDetailsLoaded extends ItemState {
  final ItemWithDetails item;
  final List<ItemWithDetails>? allItems;
  final DashboardStats? stats;

  const ItemDetailsLoaded(
    this.item, {
    this.allItems,
    this.stats,
  });

  @override
  List<Object?> get props => [item, allItems, stats];
}

class ItemSearchResults extends ItemState {
  final List<ItemWithDetails> results;
  final String query;

  const ItemSearchResults(this.results, this.query);

  @override
  List<Object?> get props => [results, query];
}

class ItemsFiltered extends ItemState {
  final List<ItemWithDetails> items;
  final int categoryId;
  final DashboardStats stats;

  const ItemsFiltered(this.items, this.categoryId, this.stats);

  @override
  List<Object?> get props => [items, categoryId, stats];
}

class ItemOperationSuccess extends ItemState {
  final String message;
  const ItemOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ItemError extends ItemState {
  final String message;
  const ItemError(this.message);
  @override
  List<Object?> get props => [message];
}
