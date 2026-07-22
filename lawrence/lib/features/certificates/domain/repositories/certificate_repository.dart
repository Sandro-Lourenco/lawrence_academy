import '../entities/certificate.dart';

abstract interface class CertificateRepository {
  Future<List<Certificate>> getCertificates();

  Future<Certificate> generateCertificate(String courseId);

  Future<Map<String, dynamic>> verifyCertificate(String code);
}
