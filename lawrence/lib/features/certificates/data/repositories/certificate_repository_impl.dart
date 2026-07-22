import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../datasources/certificate_remote_datasource.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  CertificateRepositoryImpl(this._remoteDataSource);

  final CertificateRemoteDataSource _remoteDataSource;

  @override
  Future<List<Certificate>> getCertificates() {
    return _remoteDataSource.getCertificates();
  }

  @override
  Future<Certificate> generateCertificate(String courseId) {
    return _remoteDataSource.generateCertificate(courseId);
  }

  @override
  Future<Map<String, dynamic>> verifyCertificate(String code) {
    return _remoteDataSource.verifyCertificate(code);
  }
}
