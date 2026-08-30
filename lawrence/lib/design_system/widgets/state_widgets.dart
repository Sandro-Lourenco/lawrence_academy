import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../tokens/lawrence_theme.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.search_off_rounded,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) => _StatePanel(
    semanticsLabel: '$title. $description',
    icon: icon,
    iconColor: Theme.of(context).colorScheme.primary,
    title: title,
    description: description,
    action: actionLabel != null && onActionPressed != null
        ? FilledButton.icon(
            onPressed: onActionPressed,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(actionLabel!),
          )
        : null,
  );
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Não foi possível continuar',
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _StatePanel(
    semanticsLabel: '$title. $message',
    liveRegion: true,
    icon: Icons.error_outline_rounded,
    iconColor: LawrenceColors.danger,
    title: title,
    description: message,
    action: onRetry == null
        ? null
        : FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
  );
}

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: message ?? 'Carregando conteúdo',
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message != null) ...[
                Text(message!, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: LawrenceSpacing.md),
              ],
              const AppSkeletonState(width: 220, height: 32),
              const SizedBox(height: LawrenceSpacing.lg),
              const AppSkeletonState(width: double.infinity, height: 112),
              const SizedBox(height: LawrenceSpacing.md),
              const AppSkeletonState(width: double.infinity, height: 112),
            ],
          ),
        ),
      ),
    ),
  );
}

class AppOfflineState extends StatelessWidget {
  const AppOfflineState({
    super.key,
    this.title = 'Sem conexão',
    this.message = 'Verifique sua internet e tente novamente.',
    this.onRetry,
    this.onGoToDownloads,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoToDownloads;

  @override
  Widget build(BuildContext context) => _StatePanel(
    semanticsLabel: '$title. $message',
    liveRegion: true,
    icon: Icons.wifi_off_rounded,
    iconColor: LawrenceColors.warning,
    title: title,
    description: message,
    action: Wrap(
      alignment: WrapAlignment.center,
      spacing: LawrenceSpacing.sm,
      runSpacing: LawrenceSpacing.sm,
      children: [
        if (onRetry != null)
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        if (onGoToDownloads != null)
          OutlinedButton.icon(
            onPressed: onGoToDownloads,
            icon: const Icon(Icons.download_done_rounded),
            label: const Text('Acessar downloads'),
          ),
      ],
    ),
  );
}

class AppSkeletonState extends StatelessWidget {
  const AppSkeletonState({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = LawrenceTheme.radiusSm,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final block = ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
    if (MediaQuery.disableAnimationsOf(context)) return block;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainer,
      highlightColor: scheme.surfaceContainerLowest,
      child: block,
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.semanticsLabel,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.liveRegion = false,
    this.action,
  });

  final String semanticsLabel;
  final bool liveRegion;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      liveRegion: liveRegion,
      label: semanticsLabel,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(LawrenceSpacing.lg),
            padding: const EdgeInsets.all(LawrenceSpacing.xl),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: iconColor),
                const SizedBox(height: LawrenceSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: LawrenceSpacing.sm),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: LawrenceSpacing.lg),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
