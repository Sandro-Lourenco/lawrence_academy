import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../design_system/tokens/lawrence_theme.dart';

class OfflineDownloadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress; // 0.0 a 1.0
  final String status; // 'Baixando...', 'Pausado', 'Concluído', 'Erro'
  final String sizeInfo;
  final VoidCallback? onPauseResume;
  final VoidCallback? onCancel;

  const OfflineDownloadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.status,
    required this.sizeInfo,
    this.onPauseResume,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = progress >= 1.0;
    final isError = status.toLowerCase().contains('erro');

    Color statusColor = LawrenceTheme.primary;
    if (isCompleted) statusColor = LawrenceTheme.success;
    if (isError) statusColor = LawrenceTheme.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : (isError ? Icons.error : Icons.cloud_download),
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: LawrenceTheme.surfaceTile1,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: LawrenceTheme.textSecondary,
                              fontFamily: 'Outfit',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!isCompleted)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: LawrenceTheme.textSecondary,
                        ),
                        onSelected: (val) {
                          if (val == 'pause_resume' && onPauseResume != null) {
                            onPauseResume!();
                          }
                          if (val == 'cancel' && onCancel != null) {
                            onCancel!();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'pause_resume',
                            child: Text('Pausar / Retomar'),
                          ),
                          const PopupMenuItem(
                            value: 'cancel',
                            child: Text(
                              'Cancelar Download',
                              style: TextStyle(color: LawrenceTheme.danger),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      sizeInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: LawrenceTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: LawrenceTheme.borderMist,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
