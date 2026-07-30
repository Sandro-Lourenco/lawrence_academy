import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../domain/entities/live_event.dart';
import 'live_status_badge.dart';

class LiveCard extends StatelessWidget {
  final LiveEvent live;
  final VoidCallback? onTap;

  const LiveCard({super.key, required this.live, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label:
          '${live.title}, ${_dateLabel(live.scheduledFor)}, com ${live.instructor}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LawrenceRadii.control),
          side: const BorderSide(color: LawrenceColors.borderMist),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (live.bannerUrl?.isNotEmpty == true)
                      CachedNetworkImage(
                        imageUrl: live.bannerUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 800,
                        placeholder: (_, _) => const _EventVisual(),
                        errorWidget: (_, _, _) => const _EventVisual(),
                      )
                    else
                      const _EventVisual(),
                    Positioned(
                      left: LawrenceSpacing.md,
                      top: LawrenceSpacing.md,
                      child: LiveStatusBadge(status: live.status),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(LawrenceSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      live.tag.toUpperCase(),
                      style: const TextStyle(
                        color: LawrenceColors.actionPrimary,
                        fontSize: 12,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.xs),
                    Text(
                      live.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: LawrenceSpacing.sm),
                    Text(
                      '${_dateLabel(live.scheduledFor)} · ${live.durationMinutes} min',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: LawrenceSpacing.xs),
                    Text(
                      live.instructor,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: LawrenceSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: Text(
                          live.status.toLowerCase() == 'ended'
                              ? 'Assistir gravação'
                              : 'Ver no YouTube',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _dateLabel(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month, $hour:$minute';
  }
}

class _EventVisual extends StatelessWidget {
  const _EventVisual();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: LawrenceColors.brandNavy,
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -44,
            child: Icon(
              Icons.play_circle_fill_rounded,
              size: 190,
              color: LawrenceColors.actionPrimary.withValues(alpha: .35),
            ),
          ),
          const Positioned(
            left: LawrenceSpacing.lg,
            bottom: LawrenceSpacing.lg,
            child: Text(
              'LAWRENCE\nEVENTOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                height: 1.05,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
