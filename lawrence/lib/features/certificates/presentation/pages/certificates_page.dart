import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/certificate_providers.dart';
import '../widgets/certificate_card.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';

class CertificatesPage extends ConsumerWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesAsyncValue = ref.watch(certificatesListProvider);

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
              'Meus Certificados',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: LawrenceTheme.surfaceTile1,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          certificatesAsyncValue.when(
            data: (certificates) {
              if (certificates.isEmpty) {
                return SliverFillRemaining(
                  child: AppEmptyState(
                    title: 'Nenhum certificado ainda',
                    description:
                        'Conclua seus cursos para conquistar e exibir seus certificados aqui.',
                    icon: Icons.workspace_premium_outlined,
                    actionLabel: 'Explorar Cursos',
                    onActionPressed: () {
                      context.go('/courses');
                    },
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final cert = certificates[index];
                    return CertificateCard(
                      certificate: cert,
                      onView: () {
                        context.push(
                          '/dashboard/certificates/${cert.id}',
                          extra: cert,
                        );
                      },
                    );
                  }, childCount: certificates.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: AppSkeletonState(
                  width: double.infinity,
                  height: 100,
                  borderRadius: 16,
                ),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: AppErrorState(
                title: 'Erro ao carregar',
                message: 'Não foi possível carregar seus certificados.',
                onRetry: () => ref.refresh(certificatesListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
