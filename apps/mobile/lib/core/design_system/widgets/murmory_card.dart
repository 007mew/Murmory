import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:murmory/core/design_system/tokens.dart';

class MurmoryCard extends StatelessWidget {
  const MurmoryCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.customBorderRadius,
    this.tintColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? customBorderRadius;
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = customBorderRadius ?? 20.0;
    final baseColor = tintColor ?? (isDark ? Colors.white : Colors.black);

    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: MurmorySpacing.md,
            vertical: MurmorySpacing.xs,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        baseColor.withValues(alpha: 0.09),
                        baseColor.withValues(alpha: 0.03),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.65),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.13)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(radius),
                splashColor: MurmoryColors.accent.withValues(alpha: 0.12),
                highlightColor: MurmoryColors.accent.withValues(alpha: 0.06),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(MurmorySpacing.md),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
