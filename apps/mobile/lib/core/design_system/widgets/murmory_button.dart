import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:murmory/core/design_system/tokens.dart';

class MurmoryPrimaryButton extends StatelessWidget {
  const MurmoryPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading
          ? null
          : onPressed == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onPressed!();
                },
      style: FilledButton.styleFrom(
        backgroundColor: isDestructive ? MurmoryColors.error : MurmoryColors.accent,
        minimumSize: const Size(double.infinity, 52),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );
  }
}

class MurmorySecondaryButton extends StatelessWidget {
  const MurmorySecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed!();
            },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: MurmoryColors.accent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MurmoryRadius.full),
        ),
        minimumSize: const Size(double.infinity, 52),
        foregroundColor: MurmoryColors.accent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
  }
}
