import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category.dart';
import '../../data/models/item_field.dart';
import '../../data/models/item_with_details.dart';
import '../../data/repositories/item_repository.dart';
import '../bloc/item/item_bloc.dart';
import '../bloc/item/item_event.dart';
import '../bloc/item/item_state.dart';
import '../widgets/dashboard_stats_widget.dart';
import '../widgets/favorite_seal_widget.dart';
import '../widgets/status_badge_widget.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class ItemsListScreen extends StatefulWidget {
  final VoidCallback? onSettingsNavigationStart;
  final VoidCallback? onSettingsNavigationEnd;

  const ItemsListScreen({
    super.key,
    this.onSettingsNavigationStart,
    this.onSettingsNavigationEnd,
  });

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  List<Category> _categories = [];
  int? _activeCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<ItemBloc>().add(const LoadItems());
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await context.read<ItemRepository>().getAllCategories();
    if (mounted) setState(() => _categories = cats);
  }

  void _reload() {
    context.read<ItemBloc>().add(const LoadItems());
  }

  /// Re-requests the full item list whenever the shared bloc is in a state
  /// that does not represent the loaded list (ItemInitial, a transient
  /// ItemOperationSuccess, etc.). Without this, those states would make the
  /// list render blank or wrongly show "Nothing here yet".
  ///
  /// ItemDetailsLoaded is deliberately NOT re-dispatched here: when a detail
  /// screen is pushed on top of this list, it is the detail screen's job to
  /// drive that state. Dispatching LoadItems would ping-pong with the detail
  /// screen's own re-request and loop forever.
  void _ensureItemsLoaded(ItemState state) {
    if (state is ItemLoading) return;
    if (state is ItemsLoaded ||
        state is ItemsFiltered ||
        state is ItemSearchResults ||
        state is ItemError ||
        state is ItemDetailsLoaded) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ItemBloc>().add(const LoadItems());
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocConsumer<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: cs.error),
            );
          }
        },
        builder: (context, state) {
          List<ItemWithDetails> items = [];
          DashboardStats stats = const DashboardStats();
          bool hasListData = false;

          if (state is ItemsLoaded) {
            items = state.items;
            stats = state.stats;
            hasListData = true;
          } else if (state is ItemsFiltered) {
            items = state.items;
            stats = state.stats;
            hasListData = true;
          } else if (state is ItemSearchResults) {
            items = state.results;
            hasListData = true;
          }

          Widget content;
          if (state is ItemLoading) {
            content = const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (state is ItemError) {
            content = SliverFillRemaining(
              child: _ErrorState(message: state.message, onRetry: _reload),
            );
          } else if (hasListData && items.isNotEmpty) {
            content = SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ItemCard(
                    item: items[index],
                    onTap: () => _openDetail(items[index]),
                  ),
                  childCount: items.length,
                ),
              ),
            );
          } else if (hasListData) {
            content = SliverFillRemaining(child: _EmptyState());
          } else {
            // ItemInitial, ItemOperationSuccess, stale ItemDetailsLoaded, etc.
            // Never show a blank/misleading empty state — re-fetch instead.
            _ensureItemsLoaded(state);
            content = const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, cs),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: DashboardStatsWidget(stats: stats),
                ),
              ),
              SliverToBoxAdapter(
                child: _CategoryFilterRow(
                  categories: _categories,
                  activeCategoryId: _activeCategoryId,
                  onCategorySelected: _onCategorySelected,
                ),
              ),
              content,
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddItem,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, ColorScheme cs) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 20,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/logo.png',
              width: 26,
              height: 26,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.inventory_2_rounded,
                size: 26,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Kipt', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: _openSearch,
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: _openSettings,
          tooltip: 'Settings',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _onCategorySelected(int? catId) {
    setState(() => _activeCategoryId = catId);
    context.read<ItemBloc>().add(FilterItemsByCategory(catId));
  }

  void _openDetail(ItemWithDetails item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(itemId: item.item.id!),
      ),
    );
  }

  void _openAddItem() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddItemScreen()));
  }

  void _openSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  void _openSettings() {
    widget.onSettingsNavigationStart?.call();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) {
      if (!mounted) return;
      widget.onSettingsNavigationEnd?.call();
      _loadCategories();
    });
  }
}

// ---------------------------------------------------------------------------
// Category filter row
// ---------------------------------------------------------------------------

class _CategoryFilterRow extends StatelessWidget {
  final List<Category> categories;
  final int? activeCategoryId;
  final ValueChanged<int?> onCategorySelected;

  const _CategoryFilterRow({
    required this.categories,
    required this.activeCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _FilterChip(
                label: 'All',
                selected: activeCategoryId == null,
                onTap: () => onCategorySelected(null),
                cs: cs,
              );
            }
            final cat = categories[index - 1];
            return _FilterChip(
              label: cat.name,
              selected: activeCategoryId == cat.id,
              onTap: () => onCategorySelected(cat.id),
              cs: cs,
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Item card
// ---------------------------------------------------------------------------

class _ItemCard extends StatelessWidget {
  final ItemWithDetails item;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nearest = item.nearestDateField;
    final urgentStatus = item.mostUrgentStatus;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _Thumbnail(attachment: item.firstPhoto, cs: cs),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (item.categoryName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.categoryName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (nearest != null) ...[
                        const SizedBox(height: 6),
                        _NearestDateHint(field: nearest),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Status badge
                if (urgentStatus != null && urgentStatus != FieldStatus.noReminder)
                  StatusBadge(status: urgentStatus, compact: true),
              ],
            ),
          ),
          // Wax-stamp logo for favorites, on top of the card's top-right corner.
          if (item.item.favorite)
            Positioned(
              top: -12,
              right: -10,
              child: FavoriteSeal(),
            ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final dynamic attachment; // Attachment?
  final ColorScheme cs;

  const _Thumbnail({required this.attachment, required this.cs});

  @override
  Widget build(BuildContext context) {
    if (attachment == null) {
      return Container(
        width: 56,
        height: 56,
        color: cs.surfaceContainerHigh,
        child: Icon(
          Icons.inventory_2_rounded,
          color: cs.onSurfaceVariant,
          size: 26,
        ),
      );
    }
    final file = File(attachment!.path as String);
    if (!file.existsSync()) {
      return Container(
        width: 56,
        height: 56,
        color: cs.surfaceContainerHigh,
        child: Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
      );
    }
    return SizedBox(
      width: 56,
      height: 56,
      child: Image.file(file, fit: BoxFit.cover),
    );
  }
}

class _NearestDateHint extends StatelessWidget {
  final ItemField field;
  const _NearestDateHint({required this.field});

  @override
  Widget build(BuildContext context) {
    final days = field.daysRemaining;
    if (days == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    String text;
    if (days < 0) {
      text = '${field.label} expired ${days.abs()}d ago';
    } else if (days == 0) {
      text = '${field.label} expires today';
    } else {
      text = '${field.label} in ${days}d';
    }
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Nothing here yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first item',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: cs.error),
            const SizedBox(height: 16),
            Text(
              'Could not load items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
