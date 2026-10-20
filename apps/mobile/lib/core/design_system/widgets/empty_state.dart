import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:murmory/core/design_system/tokens.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.actionLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MurmorySpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: MurmoryColors.accent.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: MurmoryColors.accent,
              ),
            )
                .animate()
                .fadeIn(duration: MurmoryDuration.slow)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: MurmorySpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms, duration: MurmoryDuration.slow),
            const SizedBox(height: MurmorySpacing.sm),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? MurmoryColors.textSecondaryDark
                        : MurmoryColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: MurmoryDuration.slow),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: MurmorySpacing.lg),
              FilledButton(
                onPressed: action,
                style: FilledButton.styleFrom(
                  backgroundColor: MurmoryColors.accent,
                ),
                child: Text(actionLabel!),
              ).animate().fadeIn(delay: 300.ms, duration: MurmoryDuration.slow),
            ],
          ],
        ),
      ),
    );
  }
}
