import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/service_repositories.dart';
import '../../../../design_system/public/public_editorial_colors.dart';
import '../../../../design_system/public/public_editorial_footer.dart';
import '../../../../design_system/public/public_editorial_typography.dart';

class PublicCertificateVerificationPage extends ConsumerStatefulWidget {
  const PublicCertificateVerificationPage({
    super.key,
    required this.initialCode,
  });

  final String initialCode;

  @override
  ConsumerState<PublicCertificateVerificationPage> createState() =>
      _PublicCertificateVerificationPageState();
}

class _PublicCertificateVerificationPageState
    extends ConsumerState<PublicCertificateVerificationPage> {
  late final TextEditingController _controller;
  Map<String, dynamic>? _result;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    if (widget.initialCode.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await ref
          .read(certificateRepositoryProvider)
          .verifyCertificate(code);
      if (mounted) setState(() => _result = result);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível consultar o certificado agora.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: PublicEditorialColors.ivory,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 150, 24, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'VALIDAÇÃO PÚBLICA',
                        textAlign: TextAlign.center,
                        style: PublicEditorialTypography.eyebrow(
                          color: PublicEditorialColors.wine,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Confirme uma conquista Lawrence.',
                        textAlign: TextAlign.center,
                        style: PublicEditorialTypography.sectionDisplay(
                          color: PublicEditorialColors.ink,
                          size: MediaQuery.sizeOf(context).width < 600
                              ? 50
                              : 72,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Digite o código impresso no certificado ou use o QR Code do documento.',
                        textAlign: TextAlign.center,
                        style: PublicEditorialTypography.body(
                          color: PublicEditorialColors.mutedInk,
                        ),
                      ),
                      const SizedBox(height: 38),
                      TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _verify(),
                        decoration: const InputDecoration(
                          labelText: 'Código de validação',
                          hintText: 'LWA-XXXXXXXX',
                          prefixIcon: Icon(Icons.workspace_premium_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _loading ? null : _verify,
                        icon: _loading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.verified_outlined),
                        label: Text(
                          _loading ? 'CONSULTANDO...' : 'VALIDAR CERTIFICADO',
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_error != null)
                        _VerificationResult(valid: false, message: _error!),
                      if (_result != null) _resultCard(_result!),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const PublicEditorialFooter(),
        ],
      ),
    );
  }

  Widget _resultCard(Map<String, dynamic> result) {
    final valid = result['is_valid'] == true;
    final certificate = result['certificate'];
    final metadata = certificate is Map ? certificate['metadata'] : null;
    final values = metadata is Map ? metadata : const <String, dynamic>{};
    if (!valid) {
      return const _VerificationResult(
        valid: false,
        message: 'Certificado inválido, revogado ou não encontrado.',
      );
    }
    return _VerificationResult(
      valid: true,
      message: 'Certificado autêntico e válido.',
      details: [
        if (values['student_name'] != null) 'Aluno: ${values['student_name']}',
        if (values['course_name'] != null) 'Curso: ${values['course_name']}',
        if (values['completion_date'] != null)
          'Conclusão: ${values['completion_date']}',
        'Código: ${_controller.text.trim().toUpperCase()}',
      ],
    );
  }
}

class _VerificationResult extends StatelessWidget {
  const _VerificationResult({
    required this.valid,
    required this.message,
    this.details = const [],
  });

  final bool valid;
  final String message;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final color = valid ? const Color(0xFF17633B) : const Color(0xFF9D2338);
    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          border: Border.all(color: color),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              valid ? Icons.verified_rounded : Icons.gpp_bad_outlined,
              color: color,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                  for (final detail in details) ...[
                    const SizedBox(height: 7),
                    Text(detail),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
