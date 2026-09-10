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
import 'package:warranty_vault/presentation/screens/items_list_screen.dart';

class _InMemoryRepo extends ItemRepository {
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
    stored = ItemWithDetails(
      item: item.copyWith(id: 1),
      fields: List.generate(fields.length, (i) => fields[i].copyWith(id: i + 1)),
      attachments: <Attachment>[],
    );
    return 1;
  }

  @override
  Future<ItemWithDetails?> getItemWithDetails(int itemId) async => stored;

  @override
  Future<List<ItemWithDetails>> getAllItemsWithDetails() async =>
      stored == null ? [] : [stored!];
}

void main() {
  testWidgets('Add -> save -> open details shows the item', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
    await tester.binding.setSurfaceSize(const Size(420, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = _InMemoryRepo();
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

    // Add an item with a login block.
    await tester.tap(find.text('Add Item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Netflix');
    await tester.ensureVisible(find.text('Add Field'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Field'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Login'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Add login').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on the list, item tile present.
    expect(tester.takeException(), isNull);
    expect(find.text('Netflix'), findsWidgets);

    // Open its details.
    await tester.tap(find.text('Netflix').first);
    await tester.pumpAndSettle();
    final err = tester.takeException();
    // ignore: avoid_print
    print('DETAIL EXCEPTION: $err');

    expect(err, isNull);
    // Title, Username, Password should be visible.
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}