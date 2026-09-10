import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warranty_vault/core/utils/preferences_helper.dart';
import 'package:warranty_vault/data/models/category.dart';
import 'package:warranty_vault/data/models/item.dart';
import 'package:warranty_vault/data/models/item_field.dart';
import 'package:warranty_vault/data/models/item_with_details.dart';
import 'package:warranty_vault/data/repositories/item_repository.dart';
import 'package:warranty_vault/presentation/screens/add_item_screen.dart';
import 'package:warranty_vault/presentation/screens/edit_item_screen.dart';

class _FakeRepo extends ItemRepository {
  _FakeRepo({this.fieldCount = 16});

  final int fieldCount;

  @override
  Future<List<Category>> getAllCategories() async => [];

  @override
  Future<ItemWithDetails?> getItemWithDetails(int itemId) async {
    final item = Item(
      id: itemId,
      title: 'Test Item',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final fields = List.generate(
      fieldCount,
      (i) => ItemField(
        id: i + 1,
        itemId: itemId,
        label: 'Field ${i + 1}',
        fieldType: FieldType.text,
        value: 'value $i',
      ),
    );
    return ItemWithDetails(item: item, fields: fields, attachments: const []);
  }
}

Future<void> _tapLogin(WidgetTester tester) async {
  final addField = find.text('Add Field');
  expect(addField, findsOneWidget);
  await tester.ensureVisible(addField);
  await tester.pumpAndSettle();
  await tester.tap(addField);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'Login'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add login').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Edit screen: pressing Login does not crash', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      RepositoryProvider<ItemRepository>(
        create: (_) => _FakeRepo(),
        child: const MaterialApp(home: EditItemScreen(itemId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    await _tapLogin(tester);
    final err = tester.takeException();
    // ignore: avoid_print
    print('EDIT EXCEPTION: $err');
    expect(err, isNull);
  });

  testWidgets('Add screen: pressing Login 9x does not crash', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      RepositoryProvider<ItemRepository>(
        create: (_) => _FakeRepo(fieldCount: 0),
        child: const MaterialApp(home: AddItemScreen()),
      ),
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 9; i++) {
      await _tapLogin(tester);
      final err = tester.takeException();
      // ignore: avoid_print
      print('ADD ($i) EXCEPTION: $err');
      expect(err, isNull);
    }
  });

  testWidgets('Add screen: login + quick expiry + drag does not crash',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesHelper.init();
    await tester.binding.setSurfaceSize(const Size(420, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      RepositoryProvider<ItemRepository>(
        create: (_) => _FakeRepo(fieldCount: 0),
        child: const MaterialApp(home: AddItemScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final expirySwitch = find.byType(Switch);
    await tester.ensureVisible(expirySwitch.first);
    await tester.pumpAndSettle();
    await tester.tap(expirySwitch.first);
    await tester.pumpAndSettle();

    await _tapLogin(tester);

    final errBefore = tester.takeException();
    await tester.drag(find.text('Password').first, const Offset(0, 60));
    await tester.pumpAndSettle();
    final err = tester.takeException();
    expect(errBefore, isNull);
    expect(err, isNull);
  });
}