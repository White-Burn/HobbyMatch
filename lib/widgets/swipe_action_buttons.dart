import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SwipeActionButtons extends StatelessWidget {
  const SwipeActionButtons({
    super.key,
    required this.onPass,
    required this.onLike,
    this.onInfo,
  });

  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.close,
          color: AppColors.pass,
          size: 56,
          iconSize: 28,
          onTap: onPass,
        ),
        if (onInfo != null) ...[
          const SizedBox(width: 16),
          _ActionButton(
            icon: Icons.info_outline,
            color: AppColors.superLike,
            size: 44,
            iconSize: 22,
            onTap: onInfo!,
          ),
        ],
        const SizedBox(width: 16),
        _ActionButton(
          icon: Icons.favorite,
          color: AppColors.like,
          size: 56,
          iconSize: 28,
          onTap: onLike,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Icon(icon, color: color, size: iconSize),
        ),
      ),
    );
  }
}
