import 'package:flutter/material.dart';

import '../tokens/lawrence_theme.dart';

class CoutureProgressBar extends StatelessWidget {
  const CoutureProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.semanticLabel = 'Progresso do curso',
  });

  final double value;
  final double height;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    return Semantics(
      label: semanticLabel,
      value: '${(normalized * 100).round()}% concluído',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LawrenceRadii.pill),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: .16)
                    : LawrenceColors.brandNavy.withValues(alpha: .12),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: normalized,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
