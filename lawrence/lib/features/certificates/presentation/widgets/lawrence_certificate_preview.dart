import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/entities/certificate.dart';

class LawrenceCertificatePreview extends StatelessWidget {
  final Certificate certificate;
  final String userName;
  final Uri? verificationUri;

  const LawrenceCertificatePreview({
    super.key,
    required this.certificate,
    required this.userName,
    this.verificationUri,
  });

  @override
  Widget build(BuildContext context) {
    final courseName = certificate.courseName;
    final issueDate = certificate.completionDate.toLocal();
    final formattedDate =
        '${issueDate.day} DE ${_getMonth(issueDate.month)} DE ${issueDate.year}';

    return AspectRatio(
      aspectRatio: 1.414, // A4 Landscape ratio
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6), // Off-white parchment
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Dark Sidebar
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A), // Dark blue
                  border: Border(
                    right: BorderSide(color: Color(0xFFA63B5E), width: 3),
                  ),
                ),
                child: Stack(
                  children: [
                    // Bottom Leaf Pattern (placeholder using icon)
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.eco_rounded,
                          size: 150,
                          color: const Color(0xFFA63B5E),
                        ),
                      ),
                    ),
                    // Logo
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'L',
                            style: TextStyle(
                              fontSize: 80,
                              fontFamily: 'Playfair Display', // or serif
                              color: const Color(0xFFA63B5E),
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'LAWRENCE',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Playfair Display',
                              color: const Color(0xFFA63B5E),
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'ACADEMY',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Outfit',
                              color: const Color(0xFFA63B5E),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Content Area
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 32.0,
                ),
                child: Column(
                  children: [
                    // Title
                    Text(
                      'CERTIFICADO',
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Playfair Display',
                        color: const Color(0xFF0F172A),
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'DE CONCLUSÃO',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Outfit',
                        color: const Color(0xFF0F172A),
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    Text(
                      'CERTIFICAMOS QUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Outfit',
                        color: const Color(0xFF0F172A),
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Playfair Display',
                        color: const Color(0xFF0F172A),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 16),
                    Text(
                      'concluiu com excelência o módulo de',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Outfit',
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      courseName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Playfair Display',
                        color: const Color(0xFF0F172A),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _completionSummary(certificate),
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: 'Outfit',
                        color: const Color(0xFF0F172A),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    Text(
                      'CÓDIGO DE VALIDAÇÃO: ${certificate.validationCode}',
                      style: const TextStyle(
                        fontSize: 8,
                        letterSpacing: 1.2,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottom Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Date
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'Outfit',
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              height: 1,
                              width: 100,
                              color: const Color(0xFFA63B5E),
                            ),
                            const Text(
                              'DATA DE CONCLUSÃO',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'Outfit',
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        // Signature
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'A. Virginia',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Playfair Display',
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              height: 1,
                              width: 120,
                              color: const Color(0xFFA63B5E),
                            ),
                            const Text(
                              'DIRETORA\nLAWRENCE ACADEMY',
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'Outfit',
                                color: Color(0xFF0F172A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        // Selo verificável. O mesmo destino é impresso no PDF.
                        Semantics(
                          image: true,
                          label: 'QR Code para validar o certificado',
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE8E2D9),
                                width: 1,
                              ),
                            ),
                            child: verificationUri == null
                                ? const Center(
                                    child: Text(
                                      'L',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontFamily: 'Playfair Display',
                                        color: Color(0xFFA63B5E),
                                      ),
                                    ),
                                  )
                                : QrImageView(
                                    data: verificationUri.toString(),
                                    padding: const EdgeInsets.all(4),
                                    backgroundColor: const Color(0xFFFAF9F6),
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: Color(0xFF0F172A),
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: Color(0xFF0F172A),
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
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(height: 1, width: 60, color: const Color(0xFFA63B5E)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFFA63B5E),
            shape: BoxShape.rectangle,
          ),
        ),
        Container(height: 1, width: 60, color: const Color(0xFFA63B5E)),
      ],
    );
  }

  String _getMonth(int month) {
    const months = [
      'JANEIRO',
      'FEVEREIRO',
      'MARÇO',
      'ABRIL',
      'MAIO',
      'JUNHO',
      'JULHO',
      'AGOSTO',
      'SETEMBRO',
      'OUTUBRO',
      'NOVEMBRO',
      'DEZEMBRO',
    ];
    return months[month - 1];
  }

  String _completionSummary(Certificate certificate) {
    final parts = <String>[];
    final hours = certificate.workloadHours;
    if (hours != null && hours > 0) {
      final formatted = hours == hours.roundToDouble()
          ? hours.toInt().toString()
          : hours.toStringAsFixed(1).replaceAll('.', ',');
      parts.add('carga horária de $formatted horas');
    }
    final lessons = certificate.completedLessonCount;
    if (lessons != null && lessons > 0) {
      parts.add(
        '$lessons ${lessons == 1 ? 'aula concluída' : 'aulas concluídas'}',
      );
    }
    if (parts.isEmpty) {
      return 'cumprindo integralmente os requisitos acadêmicos da formação.';
    }
    return 'com ${parts.join(' e ')}, cumprindo integralmente os requisitos acadêmicos da formação.';
  }
}
