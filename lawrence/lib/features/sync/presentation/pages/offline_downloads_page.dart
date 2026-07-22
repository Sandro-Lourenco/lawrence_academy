import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../widgets/sync_status_banner.dart';
import '../widgets/offline_download_card.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../core/download_provider.dart';

class OfflineDownloadsPage extends ConsumerWidget {
  const OfflineDownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadProvider);
    final syncState =
        SyncState.synced; // TODO: Implementar real syncState from provider
    final hasDownloads = downloads.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: LawrenceTheme.surfaceTile1,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Downloads & Offline',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: LawrenceTheme.surfaceTile1,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SyncStatusBanner(state: syncState),
            ),
          ),
          if (!hasDownloads)
            SliverFillRemaining(
              child: AppEmptyState(
                title: 'Nenhum download',
                description:
                    'Baixe aulas para assistir quando estiver sem internet.',
                icon: Icons.cloud_download_outlined,
                actionLabel: 'Explorar Cursos',
                onActionPressed: () {
                  context.go('/courses');
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final lessonId = downloads.keys.elementAt(index);
                  final task = downloads[lessonId]!;
                  final progress = task.totalSegments > 0
                      ? task.downloadedSegments / task.totalSegments
                      : 0.0;

                  String statusText = '';
                  switch (task.status) {
                    case DownloadStatus.pending:
                      statusText = 'Pendente';
                      break;
                    case DownloadStatus.downloading:
                      statusText = 'Baixando...';
                      break;
                    case DownloadStatus.paused:
                      statusText = 'Pausado';
                      break;
                    case DownloadStatus.completed:
                      statusText = 'Concluído';
                      break;
                    case DownloadStatus.failed:
                      statusText = 'Erro: ${task.errorMessage ?? "Falha"}';
                      break;
                  }

                  return OfflineDownloadCard(
                    title: 'Aula: $lessonId',
                    subtitle: 'Curso Associado', // TODO: Fetch from metadata
                    progress: progress,
                    status: statusText,
                    sizeInfo:
                        '${task.downloadedSegments}/${task.totalSegments} Seg.',
                    onPauseResume: () {
                      if (task.status == DownloadStatus.downloading) {
                        ref
                            .read(downloadProvider.notifier)
                            .pauseDownload(lessonId);
                      } else if (task.status == DownloadStatus.paused) {
                        ref
                            .read(downloadProvider.notifier)
                            .startDownload(lessonId, task.url);
                      }
                    },
                    onCancel: () {
                      // TODO: cancel download method doesn't exist yet maybe?
                    },
                  );
                }, childCount: downloads.length),
              ),
            ),
        ],
      ),
    );
  }
}
