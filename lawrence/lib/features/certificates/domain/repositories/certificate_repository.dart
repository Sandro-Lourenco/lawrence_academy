import 'dart:typed_data';

import '../entities/certificate.dart';

abstract interface class CertificateRepository {
  Future<List<Certificate>> getCertificates();

  Future<List<Certificate>> reconcileCertificates();

  Future<Certificate> generateCertificate(String courseId);

  Future<Map<String, dynamic>> verifyCertificate(String code);

  Future<Uint8List> downloadCertificatePdf(String certificateId);

  Uri verificationUri(String code);
}
