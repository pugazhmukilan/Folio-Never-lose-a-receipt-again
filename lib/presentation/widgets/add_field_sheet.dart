import 'package:flutter/material.dart';

/// Choices shown when tapping "Add Field".
enum AddFieldChoice { login, text, password, date }

/// Opens the "Add Field" picker as a modal bottom sheet.
///
/// Returns the chosen [AddFieldChoice], or null if dismissed.
Future<AddFieldChoice?> showAddFieldSheet(BuildContext context) {
  return showModalBottomSheet<AddFieldChoice>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => const _AddFieldSheet(),
  );
}

class _AddFieldSheet extends StatelessWidget {
  const _AddFieldSheet();

  void _pick(BuildContext context, AddFieldChoice choice) {
    Navigator.of(context).pop(choice);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Add a Field',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Choose what to add to this item',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
          _SheetTile(
            icon: Icons.lock_person_rounded,
            iconColor: cs.tertiary,
            title: 'Login',
            subtitle: 'Username and password as one',
            onTap: () => _pick(context, AddFieldChoice.login),
          ),
          _SheetTile(
            icon: Icons.text_fields_rounded,
            iconColor: cs.primary,
            title: 'Text',
            subtitle: 'IDs, serial numbers, notes',
            onTap: () => _pick(context, AddFieldChoice.text),
          ),
          _SheetTile(
            icon: Icons.key_rounded,
            iconColor: cs.secondary,
            title: 'Password',
            subtitle: 'Anything sensitive and secure',
            onTap: () => _pick(context, AddFieldChoice.password),
          ),
          _SheetTile(
            icon: Icons.event_rounded,
            iconColor: cs.primary,
            title: 'Date',
            subtitle: 'A date like purchase or renewal',
            onTap: () => _pick(context, AddFieldChoice.date),
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: Icon(Icons.chevron_right_rounded, color: cs.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}