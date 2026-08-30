import 'package:flutter/material.dart';

import '../../domain/entities/certificate.dart';
import '../../../../../design_system/tokens/lawrence_theme.dart';

class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onView;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completionDate = _formatDate(certificate.completionDate.toLocal());

    return Semantics(
      button: true,
      label:
          'Curso concluído: ${certificate.courseName}. Certificado de ${certificate.studentName}. Código ${certificate.validationCode}.',
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onView,
          child: Padding(
            padding: const EdgeInsets.all(LawrenceSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: LawrenceColors.goldHighlight,
                    border: Border.all(color: LawrenceColors.goldMid),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: LawrenceColors.achievement,
                    size: 32,
                  ),
                ),
                const SizedBox(width: LawrenceSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.courseName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: LawrenceColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: LawrenceSpacing.xxs),
                      Text(
                        'Concluído por ${certificate.studentName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: LawrenceColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: LawrenceSpacing.xxs),
                      Text(
                        'Conclusão: $completionDate · Código ${certificate.validationCode}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: LawrenceColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: LawrenceSpacing.sm),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: LawrenceColors.actionPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = <String>[
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return '${date.day.toString().padLeft(2, '0')} de ${months[date.month - 1]} de ${date.year}';
  }
}
