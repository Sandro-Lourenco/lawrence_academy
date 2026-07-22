import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/entities/live_event.dart';
import 'live_status_badge.dart';
import 'live_countdown.dart';
import '../../../../../design_system/tokens/lawrence_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LiveCard extends StatelessWidget {
  final LiveEvent live;
  final VoidCallback onTap;

  const LiveCard({super.key, required this.live, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isScheduled = live.status.toLowerCase() == 'scheduled';
    final isLive = live.status.toLowerCase() == 'live';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: LawrenceTheme.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Area
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: LawrenceTheme.primary.withValues(alpha: 0.05),
                  ),
                  child: Stack(
                    children: [
                      if (live.bannerUrl != null && live.bannerUrl!.isNotEmpty)
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: live.bannerUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: LawrenceTheme.primary.withValues(
                                alpha: 0.05,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: LawrenceTheme.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              return _buildFallbackBanner();
                            },
                          ),
                        )
                      else
                        Positioned.fill(child: _buildFallbackBanner()),
                      // Top badges
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LiveStatusBadge(status: live.status),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${live.durationMinutes} min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Countdown overlay for scheduled
                      if (isScheduled)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: LiveCountdown(scheduledFor: live.scheduledFor),
                        ),
                    ],
                  ),
                ),
                // Info Area
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        live.tag.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: LawrenceTheme.accent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        live.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: LawrenceTheme.surfaceTile1,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: LawrenceTheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 16,
                              color: LawrenceTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              live.instructor,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: LawrenceTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Outfit',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLive || isScheduled)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isLive
                                  ? LawrenceTheme.primary
                                  : LawrenceTheme.textSecondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      color: LawrenceTheme.primary.withValues(alpha: 0.05),
      child: Center(
        child: Icon(
          Icons.sensors,
          size: 48,
          color: LawrenceTheme.primary.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
