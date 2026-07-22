import 'dart:ui';
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
    final courseName =
        certificate.metadata['course_name'] ?? 'Curso ${certificate.courseId}';
    final issueDate = certificate.issuedAt.toLocal().toString().split(
      ' ',
    )[0]; // yyyy-mm-dd

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: LawrenceTheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: InkWell(
            onTap: onView,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: LawrenceTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: LawrenceTheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: LawrenceTheme.surfaceTile1,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Emitido em: $issueDate',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: LawrenceTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: LawrenceTheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
