import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/item_field.dart';
import '../../data/models/item_with_details.dart';
import '../../data/repositories/auth_service.dart';
import '../../data/repositories/item_repository.dart';
import '../bloc/item/item_bloc.dart';
import '../bloc/item/item_event.dart';
import '../bloc/item/item_state.dart';
import '../widgets/attachment_grid_widget.dart';
import '../widgets/field_row_widget.dart';
import '../widgets/login_detail_block_widget.dart';
import 'edit_item_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final int itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _fieldsCollapsed = true;

  @override
  void initState() {
    super.initState();
    context.read<ItemBloc>().add(LoadItemDetails(widget.itemId));
  }

  /// Only re-requests this item's details after a mutation (e.g. edit from
  /// this screen emitted ItemOperationSuccess).  List-level states
  /// (ItemsLoaded, ItemLoading) arriving during a pop animation must NOT
  /// trigger a re-fetch – that would overwrite the list screen's state and
  /// cause an infinite loading spinner or "item not found" error on the
  /// home page.
  void _ensureItemDetails(ItemState state) {
    if (state is ItemLoading) return;
    if (state is ItemError) return;
    if (state is ItemDetailsLoaded && state.item.item.id == widget.itemId) {
      return;
    }
    if (state is ItemOperationSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ItemBloc>().add(LoadItemDetails(widget.itemId));
        }
      });
    }
  }

  Future<void> _deleteItem(ItemWithDetails item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to delete "${item.item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final completion = Completer<void>();
      context.read<ItemBloc>().add(
        DeleteItem(item.item.id!, completion: completion),
      );
      try {
        await completion.future;
        if (mounted) Navigator.pop(context);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete item')),
          );
        }
      }
    }
  }

  Future<void> _openEdit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditItemScreen(itemId: widget.itemId)),
    );
    if (!mounted) return;
    context.read<ItemBloc>().add(LoadItemDetails(widget.itemId));
  }

  Future<void> _shareWholeItem(ItemWithDetails item) async {
    final buffer = StringBuffer();
    buffer.writeln(item.item.title);
    if (item.categoryName != null)
      buffer.writeln('Category: ${item.categoryName}');
    if (item.item.tags.isNotEmpty)
      buffer.writeln('Tags: ${item.item.tags.join(', ')}');
    buffer.writeln();

    for (final f in item.fields) {
      if (f.fieldType == FieldType.password)
        continue; // Spec §6: never share passwords
      if (f.fieldType == FieldType.text && f.value.isNotEmpty) {
        buffer.writeln('${f.label}: ${f.value}');
      } else if (f.fieldType == FieldType.date && f.parsedDate != null) {
        // Just the raw string or formatted date
        buffer.writeln('${f.label}: ${f.value}');
      }
    }

    if (item.item.notes != null && item.item.notes!.isNotEmpty) {
      buffer.writeln('\nNotes:\n${item.item.notes}');
    }

    final files = item.attachments.map((a) => XFile(a.path)).toList();

    if (files.isNotEmpty) {
      await Share.shareXFiles(files, text: buffer.toString());
    } else {
      await Share.share(buffer.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          BlocBuilder<ItemBloc, ItemState>(
            builder: (context, state) {
              if (state is ItemDetailsLoaded &&
                  state.item.item.id == widget.itemId) {
                final item = state.item;
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        item.item.favorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: item.item.favorite ? cs.tertiary : null,
                      ),
                      tooltip: item.item.favorite ? 'Unfavorite' : 'Favorite',
                      onPressed: () {
                        context.read<ItemBloc>().add(
                          ToggleFavorite(item.item.id!, !item.item.favorite),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded),
                      tooltip: 'Share',
                      onPressed: () => _shareWholeItem(item),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') {
                          _openEdit();
                        } else if (val == 'delete') {
                          _deleteItem(item);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ItemBloc, ItemState>(
        builder: (context, state) {
          if (state is ItemError) {
            return Center(child: Text(state.message));
          }
          if (state is ItemDetailsLoaded &&
              state.item.item.id == widget.itemId) {
            final item = state.item;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header
                  Text(
                    item.item.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (item.categoryName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.categoryName!,
                      style: TextStyle(
                        fontSize: 15,
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (item.item.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: item.item.tags
                          .map(
                            (t) => Chip(
                              label: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              backgroundColor: cs.surfaceContainerHigh,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 2. Nearest-expiry highlight
                  if (item.nearestDateField != null) ...[
                    _NearestExpiryHighlight(field: item.nearestDateField!),
                    const SizedBox(height: 24),
                  ],

                  // 3. Fields list
                  if (item.fields.isNotEmpty) ...[
                    _SectionLabel('Fields'),
                    const SizedBox(height: 12),
                    _buildFieldsList(item.fields),
                    const SizedBox(height: 24),
                  ],

                  // 4. Attachments
                  if (item.attachments.isNotEmpty) ...[
                    _SectionLabel('Attachments'),
                    const SizedBox(height: 12),
                    AttachmentGrid(
                      attachments: item.attachments,
                      showDelete: false, // Delete happens via edit mode
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 5. Notes
                  if (item.item.notes != null &&
                      item.item.notes!.isNotEmpty) ...[
                    _SectionLabel('Notes'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        item.item.notes!,
                        style: TextStyle(
                          fontSize: 15,
                          color: cs.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          // ItemLoading, or any state that does not belong to this item's
          // details (ItemInitial, ItemsLoaded, ItemOperationSuccess, stale
          // ItemDetailsLoaded for another item). Re-request the item and
          // show a progress indicator — never a blank page.
          _ensureItemDetails(state);
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFieldsList(List<ItemField> fields) {
    if (fields.length <= AppConstants.fieldsCollapseThreshold ||
        !_fieldsCollapsed) {
      return Column(children: _buildFieldWidgets(fields));
    }

    // Collapsed state
    var visibleCount = AppConstants.fieldsCollapseThreshold;
    if (visibleCount < fields.length &&
        _isLoginPair(fields[visibleCount - 1], fields[visibleCount])) {
      visibleCount++;
    }
    final visible = fields.take(visibleCount).toList();
    final hiddenCount = fields.length - visibleCount;

    return Column(
      children: [
        ..._buildFieldWidgets(visible),
        TextButton(
          onPressed: () => setState(() => _fieldsCollapsed = false),
          child: Text('Show all $hiddenCount more fields'),
        ),
      ],
    );
  }

  List<Widget> _buildFieldWidgets(List<ItemField> fields) {
    final widgets = <Widget>[];
    for (var index = 0; index < fields.length; index++) {
      final field = fields[index];
      final next = index + 1 < fields.length ? fields[index + 1] : null;
      final isLogin =
          field.fieldType == FieldType.text &&
          field.label.trim().toLowerCase() == 'username' &&
          next?.fieldType == FieldType.password &&
          next?.label.trim().toLowerCase() == 'password';

      if (isLogin) {
        widgets.add(
          LoginDetailBlock(
            title: field.loginTitle ?? '',
            username: field,
            password: next!,
            onRevealPassword: () => _revealPassword(next),
          ),
        );
        index++;
      } else {
        widgets.add(_buildFieldRow(field));
      }
    }
    return widgets;
  }

  bool _isLoginPair(ItemField username, ItemField password) {
    return username.fieldType == FieldType.text &&
        username.label.trim().toLowerCase() == 'username' &&
        password.fieldType == FieldType.password &&
        password.label.trim().toLowerCase() == 'password';
  }

  Future<String?> _revealPassword(ItemField field) async {
    final repo = context.read<ItemRepository>();
    final authenticated = await AuthService().authenticate();
    if (!authenticated) return null;
    return repo.readPasswordField(field.id!);
  }

  Widget _buildFieldRow(ItemField field) {
    return FieldRowWidget(
      field: field,
      onRevealRequested: field.fieldType == FieldType.password
          ? () async {
              // Spec §7: every reveal of a PASSWORD value requires a fresh
              // biometric/PIN check, not just a session-level unlock.
              return _revealPassword(field);
            }
          : null,
    );
  }
}

class _NearestExpiryHighlight extends StatelessWidget {
  final ItemField field;
  const _NearestExpiryHighlight({required this.field});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final days = field.daysRemaining;
    if (days == null) return const SizedBox.shrink();

    Color bgColor, iconColor;
    String text;
    IconData icon;

    if (days < 0) {
      bgColor = cs.errorContainer;
      iconColor = cs.error;
      text = '${field.label} expired ${days.abs()} days ago.';
      icon = Icons.warning_rounded;
    } else if (days <= 30) {
      bgColor = cs.tertiaryContainer;
      iconColor = cs.tertiary;
      text = '${field.label} expires in $days days.';
      icon = Icons.schedule_rounded;
    } else {
      bgColor = cs.primaryContainer;
      iconColor = cs.primary;
      text = '${field.label} expires in $days days.';
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
