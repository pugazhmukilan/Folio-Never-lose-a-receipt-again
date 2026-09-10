import 'package:flutter/material.dart';

/// A slightly tilted, borderless Kipt logo "stamp" shown in the top-right of
/// an item card when the item is marked as a favorite.
class FavoriteSeal extends StatelessWidget {
  final double size;

  const FavoriteSeal({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.12,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 5,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.star_rounded,
                size: size * 0.7,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}