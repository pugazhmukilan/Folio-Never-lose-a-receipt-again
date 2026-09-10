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
import 'package:warranty_vault/presentation/screens/items_list_screen.dart';

class _FakeRepo extends ItemRepository {
  final List<ItemWithDetails> items;

  _FakeRepo(this.items);

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
    items.insert(0, _item(99, item.title, categoryId: item.categoryId));
    return 99;
  }

  @override
  Future<List<ItemWithDetails>> getAllItemsWithDetails() async => items;

  @override
  Future<List<ItemWithDetails>> getItemsByCategory(int categoryId) async {
    return items.where((d) => d.item.categoryId == categoryId).toList();
  }
}

ItemWithDetails _item(int id, String title, {int? categoryId}) {
  return ItemWithDetails(
    item: Item(
      id: id,
      title: title,
      categoryId: categoryId,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    fields: const [],
    attachments: const <Attachment>[],
  );
}

ItemField _field(String label, String value) => ItemField(
      itemId: 0,
      label: label,
      fieldType: FieldType.text,
      value: value,
    );

void main() {
  testWidgets('list never blanks: shows all items, recovers after CreateItem, All filter works', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
    await tester.binding.setSurfaceSize(const Size(420, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = _FakeRepo([_item(1, 'Netflix'), _item(2, 'Mixer')]);
    final bloc = ItemBloc(itemRepository: repo);

    await tester.pumpWidget(
      RepositoryProvider<ItemRepository>.value(
        value: repo,
        child: BlocProvider.value(
          value: bloc,
          child: const MaterialApp(home: ItemsListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial load shows all records.
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Mixer'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Nothing here yet'), findsNothing);

    // 2. A CreateItem (which ends in ItemOperationSuccess) must NOT blank the
    //    list or show a spurious empty state — the list recovers to show items.
    bloc.add(CreateItem(
      item: Item(
        title: 'New Item',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      fields: [_field('Serial', 'abc')],
      attachmentPaths: const [],
    ));
    await tester.pumpAndSettle();

    // ignore: avoid_print
    print('AFTER CREATE -> state=${bloc.state.runtimeType} '
        'netflix=${find.text('Netflix').evaluate().isNotEmpty} '
        'newItem=${find.text('New Item').evaluate().isNotEmpty} '
        'empty=${find.text('Nothing here yet').evaluate().isNotEmpty}');

    expect(find.text('Nothing here yet'), findsNothing);
    expect(find.text('New Item'), findsOneWidget);

    // 3. Press the All filter — list must still render all records.
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // ignore: avoid_print
    print('AFTER ALL -> state=${bloc.state.runtimeType} '
        'netflix=${find.text('Netflix').evaluate().isNotEmpty} '
        'newItem=${find.text('New Item').evaluate().isNotEmpty} '
        'spinner=${find.byType(CircularProgressIndicator).evaluate().isNotEmpty}');

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Nothing here yet'), findsNothing);
    expect(find.text('New Item'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
  });

  testWidgets('item load failure shows a retry state instead of blank/empty', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
    await tester.binding.setSurfaceSize(const Size(420, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final bloc = ItemBloc(itemRepository: _FailingRepo());

    await tester.pumpWidget(
      RepositoryProvider<ItemRepository>.value(
        value: _FailingRepo(),
        child: BlocProvider.value(
          value: bloc,
          child: const MaterialApp(home: ItemsListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load items'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsNothing);
  });
}

class _FailingRepo extends ItemRepository {
  @override
  Future<List<Category>> getAllCategories() async => [];

  @override
  Future<DashboardStats> getDashboardStats() async => const DashboardStats();

  @override
  Future<List<ItemWithDetails>> getAllItemsWithDetails() async {
    throw Exception('database is corrupt');
  }
}