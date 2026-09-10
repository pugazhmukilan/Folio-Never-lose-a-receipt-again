import '../../data/models/item_field.dart';

/// A Username (text) + Password (password) pair created via the Login template.
class LoginFieldPair {
  String title;
  ItemField username;
  ItemField password;

  LoginFieldPair({
    this.title = '',
    required this.username,
    required this.password,
  });
}

/// A single editable entry in the Add/Edit Item fields list.
/// Either one independent field or a grouped login pair.
class FieldSlot {
  final Object key;
  ItemField? single;
  LoginFieldPair? login;

  FieldSlot.single(this.key, ItemField field)
      : single = field,
        login = null;

  FieldSlot.login(this.key, LoginFieldPair pair)
      : login = pair,
        single = null;

  bool get isLogin => login != null;

  /// All ItemFields this slot represents, in display order.
  List<ItemField> get fields => isLogin
      ? [
          login!.username.copyWith(loginTitle: login!.title),
          login!.password,
        ]
      : [single!];

  /// IDs of fields that already exist in the DB (used for deletes).
  List<int> get existingFieldIds => fields
      .where((f) => f.id != null && f.id! > 0)
      .map((f) => f.id!)
      .toList();

  /// Groups persisted fields into slots, keeping consecutive Username +
  /// Password pairs together as a single login entity (in display order).
  static List<FieldSlot> buildFromFields(
    List<ItemField> fields, {
    required Object Function() nextKey,
  }) {
    final slots = <FieldSlot>[];
    for (var i = 0; i < fields.length; i++) {
      final f = fields[i];
      final isUsername = f.fieldType == FieldType.text &&
          f.label.trim().toLowerCase() == 'username';
      final next = i + 1 < fields.length ? fields[i + 1] : null;
      final isPasswordAfter = next != null &&
          next.fieldType == FieldType.password &&
          next.label.trim().toLowerCase() == 'password';
      if (isUsername && isPasswordAfter) {
        slots.add(FieldSlot.login(
          nextKey(),
          LoginFieldPair(
            title: f.loginTitle ?? '',
            username: f,
            password: next,
          ),
        ));
        i++;
      } else {
        slots.add(FieldSlot.single(nextKey(), f));
      }
    }
    return slots;
  }
}