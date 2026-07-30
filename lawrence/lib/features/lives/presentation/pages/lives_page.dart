import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../domain/entities/live_event.dart';
import '../providers/lives_provider.dart';
import '../widgets/live_card.dart';

class LivesPage extends ConsumerWidget {
  const LivesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(livesProvider);
    return StudentPageScaffold(
      title: 'Eventos',
      subtitle:
          'Descubra lives, workshops e encontros da Lawrence no YouTube.',
      maxContentWidth: 1440,
      onRefresh: () async {
        ref.invalidate(livesProvider);
        await ref.read(livesProvider.future);
      },
      body: events.when(
        loading: () => const _EventsSkeleton(),
        error: (_, _) => SizedBox(
          height: 420,
          child: AppErrorState(
            title: 'Agenda indisponível',
            message:
                'Não foi possível atualizar os eventos. Tente novamente em instantes.',
            onRetry: () => ref.invalidate(livesProvider),
          ),
        ),
        data: (items) => items.isEmpty
            ? _EmptyEvents(onRetry: () => ref.invalidate(livesProvider))
            : _EventsGrid(
                events: items,
                onOpen: (event) => _openEvent(context, event),
              ),
      ),
    );
  }

  Future<void> _openEvent(BuildContext context, LiveEvent event) async {
    final uri = event.safeYoutubeUri;
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O link seguro deste evento ainda não está disponível.',
          ),
        ),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o YouTube neste dispositivo.'),
        ),
      );
    }
  }
}

class _EventsGrid extends StatelessWidget {
  final List<LiveEvent> events;
  final ValueChanged<LiveEvent> onOpen;

  const _EventsGrid({required this.events, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1120
            ? 3
            : constraints.maxWidth >= 700
                ? 2
                : 1;
        final width =
            (constraints.maxWidth - (columns - 1) * LawrenceSpacing.md) /
                columns;
        return Wrap(
          spacing: LawrenceSpacing.md,
          runSpacing: LawrenceSpacing.md,
          children: [
            for (final event in events)
              SizedBox(
                width: width,
                child: LiveCard(
                  live: event,
                  onTap: () => onOpen(event),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyEvents({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(LawrenceSpacing.xl),
          decoration: BoxDecoration(
            color: LawrenceColors.brandNavy,
            borderRadius: BorderRadius.circular(LawrenceRadii.control),
          ),
          child: const Wrap(
            spacing: LawrenceSpacing.lg,
            runSpacing: LawrenceSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.live_tv_outlined, color: Colors.white, size: 58),
              Text(
                'A agenda conecta você às transmissões oficiais da Lawrence.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: LawrenceSpacing.lg),
        AppEmptyState(
          title: 'Nenhum evento agendado',
          description:
              'Quando uma nova transmissão for publicada, ela aparecerá aqui com data, horário e link oficial do YouTube.',
          icon: Icons.event_available_outlined,
          actionLabel: 'Explorar cursos enquanto isso',
          onActionPressed: () => context.go('/dashboard/courses'),
        ),
        const SizedBox(height: LawrenceSpacing.sm),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Atualizar agenda'),
        ),
      ],
    );
  }
}

class _EventsSkeleton extends StatelessWidget {
  const _EventsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: LawrenceSpacing.md,
      runSpacing: LawrenceSpacing.md,
      children: [
        AppSkeletonState(width: 340, height: 360, borderRadius: 8),
        AppSkeletonState(width: 340, height: 360, borderRadius: 8),
        AppSkeletonState(width: 340, height: 360, borderRadius: 8),
      ],
    );
  }
}
