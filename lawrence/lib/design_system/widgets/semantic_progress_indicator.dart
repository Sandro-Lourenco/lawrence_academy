import 'package:flutter/material.dart';

import '../tokens/lawrence_theme.dart';

class SemanticProgressIndicator extends StatelessWidget {
  final double value;
  final String label;
  final String? supportingText;
  final Color color;

  const SemanticProgressIndicator({
    super.key,
    required this.value,
    required this.label,
    this.supportingText,
    this.color = LawrenceColors.actionPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0.0, 1.0).toDouble();
    final percentage = (normalizedValue * 100).round();

    return Semantics(
      label: label,
      value: '$percentage% concluído',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: LawrenceColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: LawrenceColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: LawrenceSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(LawrenceRadii.pill),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: normalizedValue,
              color: color,
              backgroundColor: LawrenceColors.borderMist,
            ),
          ),
          if (supportingText != null) ...[
            const SizedBox(height: LawrenceSpacing.xs),
            Text(
              supportingText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: LawrenceColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
