import 'package:flutter/material.dart';
import 'package:murmory/core/design_system/tokens.dart';
import 'package:murmory/core/design_system/widgets/murmory_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
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
                color: MurmoryColors.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: MurmoryColors.error,
              ),
            ),
            const SizedBox(height: MurmorySpacing.lg),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: MurmorySpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: MurmorySpacing.lg),
              MurmoryPrimaryButton(label: 'Try Again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
