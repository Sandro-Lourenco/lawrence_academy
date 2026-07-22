import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/certificate.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../shared/widgets/liquid_glass_card.dart';

class CertificateDetailPage extends StatelessWidget {
  final Certificate certificate;

  const CertificateDetailPage({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courseName =
        certificate.metadata['course_name'] ?? 'Curso ${certificate.courseId}';
    final issueDate = certificate.issuedAt.toLocal().toString().split('.')[0];

    return Scaffold(
      backgroundColor: LawrenceTheme.canvasParchment, // Fundo base
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: LawrenceTheme.surfaceTile1,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Detalhes do Certificado',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 18,
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
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 72,
                          color: LawrenceTheme.success,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Certificado de Conclusão',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: LawrenceTheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontFamily: 'Outfit',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          courseName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: LawrenceTheme.surfaceTile1,
                            fontFamily: 'Outfit',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        const Divider(color: LawrenceTheme.borderMist),
                        const SizedBox(height: 24),
                        _buildInfoRow(context, 'Emitido em', issueDate),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          'Código de Validação',
                          certificate.validationCode,
                          isCode: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Baixar PDF
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Baixar PDF'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: LawrenceTheme.primary,
                            side: const BorderSide(
                              color: LawrenceTheme.primary,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Compartilhar
                          },
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Compartilhar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LawrenceTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isCode = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: LawrenceTheme.textSecondary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isCode ? FontWeight.bold : FontWeight.w600,
            color: LawrenceTheme.surfaceTile1,
            letterSpacing: isCode ? 2.0 : 0,
            fontFamily: isCode ? 'Courier' : 'Outfit',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
