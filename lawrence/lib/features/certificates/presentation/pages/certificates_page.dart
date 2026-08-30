import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../providers/certificate_providers.dart';
import '../widgets/certificate_card.dart';

class CertificatesPage extends ConsumerWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificates = ref.watch(certificatesListProvider);
    Future<void> refresh() async => ref.invalidate(certificatesListProvider);

    return StudentPageScaffold(
      title: 'Certificados',
      subtitle: 'Documentos verificáveis das formações que você concluiu.',
      maxContentWidth: 980,
      onRefresh: refresh,
      body: certificates.when(
        loading: () => const Column(
          children: [
            AppSkeletonState(width: double.infinity, height: 132),
            SizedBox(height: LawrenceSpacing.md),
            AppSkeletonState(width: double.infinity, height: 132),
          ],
        ),
        error: (_, _) => AppErrorState(
          title: 'Não foi possível carregar',
          message: 'Tente novamente para consultar seus certificados.',
          onRetry: refresh,
        ),
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyState(
              title: 'Sua coleção começa com uma conclusão',
              description:
                  'Ao concluir uma formação, o certificado verificável aparece aqui.',
              icon: Icons.workspace_premium_outlined,
              actionLabel: 'Ver meus cursos',
              onActionPressed: () => context.go('/dashboard/courses'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  '${items.length} ${items.length == 1 ? 'curso concluído' : 'cursos concluídos'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: LawrenceColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: LawrenceSpacing.xs),
              const Text(
                'Cada formação abaixo possui um certificado nominal e um código público de validação.',
                style: TextStyle(color: LawrenceColors.textSecondary),
              ),
              const SizedBox(height: LawrenceSpacing.lg),
              for (final certificate in items) ...[
                CertificateCard(
                  certificate: certificate,
                  onView: () => context.push(
                    '/dashboard/certificates/${certificate.id}',
                    extra: certificate,
                  ),
                ),
                const SizedBox(height: LawrenceSpacing.md),
              ],
            ],
          );
        },
      ),
    );
  }
}
