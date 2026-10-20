import 'package:flutter/material.dart';
import 'package:murmory/core/design_system/tokens.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: MurmoryColors.accent,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: MurmorySpacing.md),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// A shimmer loading card placeholder
class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key, this.height = 80});
  final double height;

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          height: widget.height,
          margin: const EdgeInsets.symmetric(
            horizontal: MurmorySpacing.md,
            vertical: MurmorySpacing.xs,
          ),
          decoration: BoxDecoration(
            color: (isDark ? MurmoryColors.surfaceDark : MurmoryColors.surface)
                .withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(MurmoryRadius.lg),
          ),
        );
      },
    );
  }
}
