import 'package:flutter/material.dart';

/// A styled card with multiple variants.
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  /// Elevated card with shadow.
  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  }) : variant = AppCardVariant.elevated;

  /// Outlined card with border.
  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderRadius,
  })  : variant = AppCardVariant.outlined,
        elevation = 0;

  /// Filled card with background color.
  const AppCard.filled({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderRadius,
  })  : variant = AppCardVariant.filled,
        elevation = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectivePadding = padding ?? const EdgeInsets.all(16);
    final effectiveMargin = margin ?? EdgeInsets.zero;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    final cardColor = backgroundColor ??
        switch (variant) {
          AppCardVariant.elevated => colorScheme.surface,
          AppCardVariant.outlined => colorScheme.surface,
          AppCardVariant.filled => colorScheme.surfaceContainerHighest,
        };

    final cardElevation = elevation ??
        switch (variant) {
          AppCardVariant.elevated => 2.0,
          AppCardVariant.outlined => 0.0,
          AppCardVariant.filled => 0.0,
        };

    final border = variant == AppCardVariant.outlined
        ? Border.all(color: colorScheme.outlineVariant)
        : null;

    Widget content = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: effectiveBorderRadius,
        border: border,
        boxShadow: cardElevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: cardElevation * 2,
                  offset: Offset(0, cardElevation),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: effectiveBorderRadius,
          child: content,
        ),
      );
    }

    return Padding(
      padding: effectiveMargin,
      child: content,
    );
  }
}

enum AppCardVariant {
  elevated,
  outlined,
  filled,
}

/// A list tile card for displaying items in a list.
class AppListCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final AppCardVariant variant;

  const AppListCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.margin,
    this.variant = AppCardVariant.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      variant: variant,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
