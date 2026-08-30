import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../controllers/invoices_controller.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../../../core/error/global_error_handler.dart';

class InvoicesPage extends ConsumerWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesState = ref.watch(invoicesControllerProvider);

    return StudentPageScaffold(
      title: 'Faturas e recibos',
      subtitle: 'Seu histórico financeiro, organizado e transparente.',
      actions: [
        IconButton(
          tooltip: 'Atualizar faturas',
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              ref.read(invoicesControllerProvider.notifier).refresh(),
        ),
      ],
      onRefresh: () => ref.read(invoicesControllerProvider.notifier).refresh(),
      body: invoicesState.when(
        data: (invoices) {
          if (invoices.isEmpty) {
            return _buildEmptyState();
          }
          return Column(
            children: [
              for (final invoice in invoices)
                _buildInvoiceCard(invoice, context),
            ],
          );
        },
        loading: () => const AppLoadingState(message: 'Carregando faturas...'),
        error: (error, stack) => GlobalErrorHandler.buildErrorWidget(
          error,
          () => ref.read(invoicesControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      title: 'Nenhuma fatura encontrada',
      description: 'Seu histórico de pagamentos aparecerá aqui.',
      icon: Icons.receipt_long_outlined,
    );
  }

  Widget _buildInvoiceCard(dynamic invoice, BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(invoice.createdAt);
    final isPaid = invoice.status.toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
        border: Border.all(color: LawrenceColors.borderMist),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPaid
                ? LawrenceColors.success.withValues(alpha: 0.1)
                : LawrenceColors.warning.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: isPaid ? LawrenceColors.success : LawrenceColors.warning,
          ),
        ),
        title: Text(
          'Fatura de $dateStr',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${invoice.currency} ${invoice.amountPaid.toStringAsFixed(2)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.download_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () async {
            final url = invoice.invoicePdf ?? invoice.hostedInvoiceUrl;
            if (url != null && url.isNotEmpty) {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível abrir o recibo.'),
                    ),
                  );
                }
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recibo não disponível.')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
