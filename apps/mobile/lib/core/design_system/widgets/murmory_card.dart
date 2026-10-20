import 'package:flutter/material.dart';
import 'package:murmory/core/design_system/tokens.dart';

class MurmoryCard extends StatelessWidget {
  const MurmoryCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: MurmorySpacing.md,
            vertical: MurmorySpacing.xs,
          ),
      decoration: BoxDecoration(
        color: isDark ? MurmoryColors.surfaceDark : MurmoryColors.surface,
        borderRadius: BorderRadius.circular(MurmoryRadius.lg),
        border: Border.all(
          color: isDark ? MurmoryColors.dividerDark : MurmoryColors.dividerLight,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(MurmoryRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MurmoryRadius.lg),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(MurmorySpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
