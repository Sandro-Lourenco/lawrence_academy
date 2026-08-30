import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/providers/service_repositories.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../domain/entities/certificate.dart';
import '../widgets/lawrence_certificate_preview.dart';

class CertificateDetailPage extends ConsumerStatefulWidget {
  const CertificateDetailPage({super.key, required this.certificate});

  final Certificate certificate;

  @override
  ConsumerState<CertificateDetailPage> createState() =>
      _CertificateDetailPageState();
}

class _CertificateDetailPageState extends ConsumerState<CertificateDetailPage> {
  bool _downloading = false;

  Certificate get certificate => widget.certificate;

  Uri get _verificationUri => ref
      .read(certificateRepositoryProvider)
      .verificationUri(certificate.validationCode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawrenceColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 980;
            final preview = _CertificatePanel(
              certificate: certificate,
              verificationUri: _verificationUri,
              onBack: () => context.pop(),
            );
            final actions = _CertificateActions(
              certificate: certificate,
              downloading: _downloading,
              onDownload: _downloadPdf,
              onShare: _shareAchievement,
              onCopy: _copyVerificationLink,
              onCourse: () =>
                  context.go('/dashboard/courses/${certificate.courseId}'),
            );
            if (desktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 7, child: preview),
                  Expanded(flex: 3, child: actions),
                ],
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: preview),
                SliverToBoxAdapter(child: actions),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _downloadPdf() async {
    if (_downloading || certificate.isRevoked) return;
    setState(() => _downloading = true);
    try {
      final bytes = await ref
          .read(certificateRepositoryProvider)
          .downloadCertificatePdf(certificate.id);
      if (bytes.isEmpty) throw StateError('O arquivo retornado está vazio.');
      await FileSaver.instance.saveFile(
        name: 'certificado-${certificate.validationCode.toLowerCase()}',
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
      if (mounted) _showMessage('Certificado salvo com sucesso.');
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Não foi possível baixar o certificado. Tente novamente.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _shareAchievement(BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        title: 'Certificado Lawrence Academy',
        subject: 'Minha conclusão na Lawrence Academy',
        text:
            'Concluí o curso ${certificate.courseName} na Lawrence Academy. '
            'Valide o certificado: $_verificationUri',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<void> _copyVerificationLink() async {
    await Clipboard.setData(ClipboardData(text: _verificationUri.toString()));
    if (mounted) _showMessage('Link de validação copiado.');
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? LawrenceColors.danger : LawrenceColors.primary,
      ),
    );
  }
}

class _CertificatePanel extends StatelessWidget {
  const _CertificatePanel({
    required this.certificate,
    required this.verificationUri,
    required this.onBack,
  });

  final Certificate certificate;
  final Uri verificationUri;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 980;
    return ColoredBox(
      color: const Color(0xFFE9E4DC),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          desktop ? 42 : 18,
          20,
          desktop ? 42 : 18,
          desktop ? 36 : 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Voltar aos certificados'),
            ),
            SizedBox(height: desktop ? 34 : 24),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: LawrenceCertificatePreview(
                  certificate: certificate,
                  userName: certificate.studentName,
                  verificationUri: verificationUri,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateActions extends StatelessWidget {
  const _CertificateActions({
    required this.certificate,
    required this.downloading,
    required this.onDownload,
    required this.onShare,
    required this.onCopy,
    required this.onCourse,
  });

  final Certificate certificate;
  final bool downloading;
  final VoidCallback onDownload;
  final Future<void> Function(BuildContext context) onShare;
  final VoidCallback onCopy;
  final VoidCallback onCourse;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: LawrenceColors.surfaceBlack,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'CONQUISTA VERIFICÁVEL',
              style: TextStyle(
                color: LawrenceColors.goldHighlight,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              certificate.courseName,
              style: const TextStyle(
                color: LawrenceColors.canvas,
                fontFamily: 'Georgia',
                fontSize: 32,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              certificate.isRevoked
                  ? 'Este certificado foi revogado e não pode ser compartilhado ou baixado.'
                  : 'O PDF contém os dados oficiais da conclusão, código único e QR Code para validação pública.',
              style: const TextStyle(
                color: LawrenceColors.canvasParchment,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: certificate.isRevoked || downloading
                  ? null
                  : onDownload,
              icon: downloading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(
                downloading ? 'GERANDO PDF...' : 'BAIXAR CERTIFICADO EM PDF',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: LawrenceColors.goldMid,
                foregroundColor: LawrenceColors.onGold,
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (buttonContext) => OutlinedButton.icon(
                onPressed: certificate.isRevoked
                    ? null
                    : () => onShare(buttonContext),
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('COMPARTILHAR CONQUISTA'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: LawrenceColors.canvas,
                  side: const BorderSide(color: LawrenceColors.canvasParchment),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: certificate.isRevoked ? null : onCopy,
              icon: const Icon(Icons.link_rounded),
              label: const Text('COPIAR LINK DE VALIDAÇÃO'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: LawrenceColors.canvas,
                side: const BorderSide(color: LawrenceColors.canvasParchment),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Código ${certificate.validationCode}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: LawrenceColors.canvasParchment,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onCourse,
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Revisitar o curso'),
              style: TextButton.styleFrom(
                foregroundColor: LawrenceColors.goldHighlight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
