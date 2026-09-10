import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:warranty_vault/data/database/database_helper.dart';
import 'package:warranty_vault/data/models/item.dart';
import 'package:warranty_vault/data/models/item_field.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('kipt_db_test');
    databaseFactory.setDatabasesPath(dir.path);
    addTearDown(() {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    });
  });

  test('real DB loads all stored records', () async {
    final db = DatabaseHelper();

    // Insert an item + fields so there is real data to fetch.
    await db.insertItem(Item(
      title: 'Netflix',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ));
    final items = await db.getAllItems();
    expect(items, hasLength(1));

    final firstId = items.single.id!;
    await db.insertField(ItemField(
      itemId: firstId,
      label: 'Username',
      fieldType: FieldType.text,
      value: 'me@example.com',
    ));

    final fields = await db.getFieldsByItemId(firstId);
    expect(fields, hasLength(1));

    final withDetails = await db.getAllItems();
    // ignore: avoid_print
    print('LOADED ITEMS: ${withDetails.first.title}');
    expect(withDetails.first.title, 'Netflix');
  });
}