import 'package:flutter/material.dart';
import '../../data/models/item_with_details.dart';

/// The three-stat summary row shown at the top of the dashboard.
class DashboardStatsWidget extends StatelessWidget {
  final DashboardStats stats;

  const DashboardStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _StatCard(
          label: 'Active',
          count: stats.active,
          color: cs.primaryContainer,
          onColor: cs.onPrimaryContainer,
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Expiring',
          count: stats.expiringSoon,
          color: cs.tertiaryContainer,
          onColor: cs.onTertiaryContainer,
          icon: Icons.schedule_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Expired',
          count: stats.expired,
          color: cs.errorContainer,
          onColor: cs.onErrorContainer,
          icon: Icons.warning_amber_rounded,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color onColor;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.onColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 92),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: onColor,
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: onColor.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: onColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}