import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../providers/feedback_providers.dart';

class FeedbacksPage extends ConsumerWidget {
  const FeedbacksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbacks = ref.watch(feedbacksProvider);
    return StudentPageScaffold(
      title: 'Feedbacks',
      subtitle: 'Experiências e avaliações publicadas pelos alunos Lawrence.',
      onRefresh: () async => ref.invalidate(feedbacksProvider),
      body: feedbacks.when(
        loading: () => const AppLoadingState(message: 'Carregando avaliações…'),
        error: (_, _) => AppErrorState(
          message: 'Não foi possível carregar os feedbacks.',
          onRetry: () => ref.invalidate(feedbacksProvider),
        ),
        data: (items) => items.isEmpty
            ? const AppEmptyState(
                title: 'Nenhum feedback publicado',
                description:
                    'As avaliações aparecerão após a conclusão dos cursos.',
                icon: Icons.reviews_outlined,
              )
            : Column(
                children: [
                  for (final item in items)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: LawrenceSpacing.md),
                      padding: const EdgeInsets.all(LawrenceSpacing.lg),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: LawrenceColors.brandNavy.withValues(
                            alpha: .14,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: item.studentAvatarUrl == null
                                    ? null
                                    : NetworkImage(item.studentAvatarUrl!),
                                child: item.studentAvatarUrl == null
                                    ? Text(item.studentName.characters.first)
                                    : null,
                              ),
                              const SizedBox(width: LawrenceSpacing.md),
                              Expanded(child: Text(item.studentName)),
                              Text(
                                List.filled(item.rating, '★').join(),
                                style: const TextStyle(
                                  color: LawrenceColors.darkAction,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: LawrenceSpacing.md),
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: LawrenceSpacing.xs),
                          Text(item.comment),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
