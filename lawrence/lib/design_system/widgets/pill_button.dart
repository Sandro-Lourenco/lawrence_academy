import 'package:flutter/material.dart';
import '../tokens/lawrence_theme.dart';

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;

  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
    this.height = 50.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? LawrenceColors.primary : Colors.transparent,
      foregroundColor: isPrimary ? Colors.white : LawrenceColors.textPrimary,
      elevation: 0,
      side: isPrimary
          ? BorderSide.none
          : const BorderSide(color: LawrenceColors.borderMist, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          LawrenceTheme.radiusXl,
        ), // Formato pílula (32px)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPrimary ? Colors.white : LawrenceColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: theme.textTheme.titleLarge?.copyWith(
            color: isPrimary ? Colors.white : LawrenceColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: width,
      child: isPrimary
          ? ElevatedButton(
              style: buttonStyle,
              onPressed: isLoading ? null : onPressed,
              child: content,
              // Ao clicar podemos adicionar efeitos adicionais se desejado
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: LawrenceColors.textPrimary,
                side: const BorderSide(
                  color: LawrenceColors.borderMist,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LawrenceTheme.radiusXl),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: isLoading ? null : onPressed,
              child: content,
            ),
    );
  }
}
