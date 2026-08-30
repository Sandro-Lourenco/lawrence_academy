import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../controllers/subscriptions_controller.dart';
import '../../domain/entities/subscription_status.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../../../core/error/global_error_handler.dart';

class SubscriptionsPage extends ConsumerWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(subscriptionsControllerProvider);

    return StudentPageScaffold(
      title: 'Minhas assinaturas',
      subtitle: 'Planos ativos, cobranças e acesso aos seus cursos.',
      onRefresh: () async => ref.invalidate(subscriptionsControllerProvider),
      body: stateAsync.when(
        loading: () =>
            const AppLoadingState(message: 'Carregando assinaturas...'),
        error: (err, stack) => GlobalErrorHandler.buildErrorWidget(
          err,
          () => ref.refresh(subscriptionsControllerProvider),
        ),
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return _buildEmptyState(context);
          }
          return Column(
            children: [
              for (final subscription in subscriptions)
                _buildSubscriptionCard(context, ref, subscription),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const AppEmptyState(
      title: 'Nenhuma assinatura ativa',
      description: 'Explore nossos cursos e inicie sua jornada.',
      icon: Icons.workspace_premium,
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    WidgetRef ref,
    SubscriptionStatus subscription,
  ) {
    final hasAccess = subscription.hasAccess;
    final isCanceled = subscription.isCanceled;
    final isPastDue = subscription.isPastDue;
    final isExpired = subscription.isExpired;

    String statusText = 'Ativa';
    Color statusColor = LawrenceColors.success;

    if (isExpired) {
      statusText = 'Expirada';
      statusColor = LawrenceColors.textSecondary;
    } else if (isCanceled) {
      statusText = 'Cancelada';
      statusColor = LawrenceColors.warning;
    } else if (isPastDue) {
      statusText = 'Pagamento Pendente';
      statusColor = LawrenceColors.danger;
    } else if (subscription.isTrialing) {
      statusText = 'Em Período de Teste';
      statusColor = LawrenceColors.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(LawrenceTheme.AppRadiusMedium),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Curso Assinado', // Na prática, trazer o título do curso
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(LawrenceTheme.radiusXl),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Valor Mensal: ${subscription.currency} ${subscription.monthlyPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (isCanceled || isExpired)
                ? (subscription.currentPeriodEnd != null
                      ? 'Acesso até: ${subscription.currentPeriodEnd!.day}/${subscription.currentPeriodEnd!.month}/${subscription.currentPeriodEnd!.year}'
                      : 'Sem data definida')
                : (subscription.currentPeriodEnd != null
                      ? 'Próxima cobrança: ${subscription.currentPeriodEnd!.day}/${subscription.currentPeriodEnd!.month}/${subscription.currentPeriodEnd!.year}'
                      : 'Sem data definida'),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          if (hasAccess && !subscription.cancelAtPeriodEnd)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    _showCancelConfirmation(context, ref, subscription),
                style: OutlinedButton.styleFrom(
                  foregroundColor: LawrenceColors.danger,
                  side: const BorderSide(color: LawrenceColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LawrenceTheme.radiusXl),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancelar Assinatura'),
              ),
            ),
          if (subscription.cancelAtPeriodEnd && hasAccess)
            const Text(
              'Esta assinatura foi cancelada e não será renovada.',
              style: TextStyle(color: LawrenceColors.danger, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Future<void> _showCancelConfirmation(
    BuildContext context,
    WidgetRef ref,
    SubscriptionStatus subscription,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar Assinatura?'),
          content: const Text(
            'Tem certeza que deseja cancelar esta assinatura? Você continuará tendo acesso até o final do período cobrado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Confirmar Cancelamento',
                style: TextStyle(color: LawrenceColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ref
            .read(subscriptionsControllerProvider.notifier)
            .cancelSubscription(subscription.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assinatura cancelada com sucesso.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao cancelar: $e')));
        }
      }
    }
  }
}
