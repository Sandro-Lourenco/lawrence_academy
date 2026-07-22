import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../providers/lives_provider.dart';
import '../widgets/live_card.dart';

class LivesPage extends ConsumerWidget {
  const LivesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final livesAsync = ref.watch(livesProvider);

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
            title: Text(
              'Mentoria & Lives',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
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
              child: Text(
                'Acompanhe as mentorias exclusivas e tire suas dúvidas em tempo real.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: LawrenceTheme.textSecondary,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          livesAsync.when(
            data: (lives) {
              if (lives.isEmpty) {
                return SliverFillRemaining(
                  child: AppEmptyState(
                    title: 'Nenhuma live agendada',
                    description:
                        'Fique de olho! Em breve novas mentorias e workshops ao vivo serão anunciados.',
                    icon: Icons.event_available,
                    actionLabel: 'Atualizar',
                    onActionPressed: () => ref.refresh(livesProvider),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final live = lives[index];
                    return LiveCard(
                      live: live,
                      onTap: () {
                        if (live.status.toLowerCase() != 'ended') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                live.status.toLowerCase() == 'live'
                                    ? 'Conectando à sala de mentoria...'
                                    : 'Sala de mentoria abrirá 10 minutos antes da transmissão.',
                              ),
                              backgroundColor: LawrenceTheme.primary,
                            ),
                          );
                          // TODO: Navegar para Player ou Sala
                        }
                      },
                    );
                  }, childCount: lives.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: AppSkeletonState(
                  width: double.infinity,
                  height: 250,
                  borderRadius: 20,
                ),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: AppErrorState(
                title: 'Erro ao carregar',
                message: 'Não foi possível carregar a programação de lives.',
                onRetry: () => ref.refresh(livesProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
