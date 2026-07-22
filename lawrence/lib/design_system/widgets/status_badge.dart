import 'package:flutter/material.dart';

import '../tokens/lawrence_theme.dart';

enum AppStatusTone { neutral, info, practice, success, warning, danger }

class AppStatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppStatusTone tone;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.icon,
    this.tone = AppStatusTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(tone);
    return Semantics(
      label: 'Status: $label',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(
          horizontal: LawrenceSpacing.sm,
          vertical: LawrenceSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(LawrenceRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colors.foreground),
            const SizedBox(width: LawrenceSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusColors _colorsFor(AppStatusTone tone) => switch (tone) {
    AppStatusTone.neutral => const _StatusColors(
      LawrenceColors.surfaceSubtle,
      LawrenceColors.textSecondary,
    ),
    AppStatusTone.info => const _StatusColors(
      LawrenceColors.infoSurface,
      LawrenceColors.info,
    ),
    AppStatusTone.practice => const _StatusColors(
      LawrenceColors.practiceSurface,
      LawrenceColors.practice,
    ),
    AppStatusTone.success => const _StatusColors(
      LawrenceColors.successSurface,
      LawrenceColors.success,
    ),
    AppStatusTone.warning => const _StatusColors(
      LawrenceColors.warningSurface,
      LawrenceColors.warning,
    ),
    AppStatusTone.danger => const _StatusColors(
      LawrenceColors.dangerSurface,
      LawrenceColors.danger,
    ),
  };
}

class _StatusColors {
  final Color background;
  final Color foreground;

  const _StatusColors(this.background, this.foreground);
}
