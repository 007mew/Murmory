import 'dart:ui';
import 'package:flutter/material.dart';

/// Authentic iOS-style Liquid Glass container with hardware-accelerated blur,
/// specular rim lighting, and subtle translucent gradients.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tintColor;
  final double opacity;
  final double borderOpacity;
  final VoidCallback? onTap;
  final Gradient? customGradient;

  const LiquidGlass({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.borderRadius = 22.0,
    this.padding,
    this.margin,
    this.tintColor,
    this.opacity = 0.08,
    this.borderOpacity = 0.16,
    this.onTap,
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = tintColor ?? (isDark ? Colors.white : Colors.black);

    final gradient = customGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withValues(alpha: opacity * 1.5),
            baseColor.withValues(alpha: opacity * 0.4),
          ],
        );

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient,
        border: Border.all(
          color: baseColor.withValues(alpha: borderOpacity),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (blur > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
