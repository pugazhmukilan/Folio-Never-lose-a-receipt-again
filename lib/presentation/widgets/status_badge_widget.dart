import 'package:flutter/material.dart';
import '../../data/models/item_field.dart';

/// Compact badge showing a field's status (Expired / Expiring / Active).
class StatusBadge extends StatelessWidget {
  final FieldStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (status == FieldStatus.noReminder) return const SizedBox.shrink();

    final (label, bgColor, textColor, icon) = _resolve(context);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color, IconData) _resolve(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case FieldStatus.expired:
        return (
          'Expired',
          cs.errorContainer,
          cs.onErrorContainer,
          Icons.warning_rounded,
        );
      case FieldStatus.expiringSoon:
        return (
          'Expiring',
          cs.tertiaryContainer,
          cs.onTertiaryContainer,
          Icons.schedule_rounded,
        );
      case FieldStatus.active:
        return (
          'Active',
          cs.primaryContainer,
          cs.onPrimaryContainer,
          Icons.check_circle_rounded,
        );
      case FieldStatus.noReminder:
        return ('', Colors.transparent, Colors.transparent, Icons.circle);
    }
  }
}
