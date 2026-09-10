import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warranty_vault/core/utils/preferences_helper.dart';
import 'package:warranty_vault/data/models/attachment.dart';
import 'package:warranty_vault/data/models/category.dart';
import 'package:warranty_vault/data/models/item.dart';
import 'package:warranty_vault/data/models/item_field.dart';
import 'package:warranty_vault/data/models/item_with_details.dart';
import 'package:warranty_vault/data/repositories/item_repository.dart';
import 'package:warranty_vault/presentation/bloc/item/item_bloc.dart';
import 'package:warranty_vault/presentation/bloc/item/item_event.dart';
import 'package:warranty_vault/presentation/screens/item_detail_screen.dart';

class _SlowRepo extends ItemRepository {
  ItemWithDetails? stored;

  @override
  Future<List<Category>> getAllCategories() async => [];

  @override
  Future<DashboardStats> getDashboardStats() async => const DashboardStats();

  @override
  Future<int> createItem({
    required Item item,
    required List<ItemField> fields,
    required List<String> attachmentPaths,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    stored = ItemWithDetails(
      item: item.copyWith(id: 1),
      fields: List.generate(fields.length, (i) => fields[i].copyWith(id: i + 1)),
      attachments: <Attachment>[],
    );
    return 1;
  }

  @override
  Future<ItemWithDetails?> getItemWithDetails(int itemId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return stored;
  }

  @override
  Future<List<ItemWithDetails>> getAllItemsWithDetails() async =>
      stored == null ? [] : [stored!];
}

void main() {
  testWidgets('details page is not blank when CreateItem is in flight', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
    await tester.binding.setSurfaceSize(const Size(420, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = _SlowRepo();
    final bloc = ItemBloc(itemRepository: repo);

    // Simulate the AddItemScreen saving behavior: dispatch CreateItem
    // (fire-and-forget) and immediately move on to the details screen while
    // the create operation is still being processed.
    bloc.add(CreateItem(
      item: Item(
        title: 'Netflix',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      fields: const [],
      attachmentPaths: const [],
    ));

    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(
      RepositoryProvider<ItemRepository>.value(
        value: repo,
        child: BlocProvider.value(
          value: bloc,
          child: const MaterialApp(home: ItemDetailScreen(itemId: 1)),
        ),
      ),
    );
    // Advance through the async createItem (300ms) and getItemWithDetails
    // (200ms) delays so the bloc reaches a stable state.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The details page must show the item instead of rendering blank.
    expect(find.text('Netflix'), findsOneWidget);
  });
}