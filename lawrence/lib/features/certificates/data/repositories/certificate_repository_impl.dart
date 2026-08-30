import 'dart:typed_data';

import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../datasources/certificate_remote_datasource.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  CertificateRepositoryImpl(this._remoteDataSource, this._publicWebUrl);

  final CertificateRemoteDataSource _remoteDataSource;
  final String _publicWebUrl;

  @override
  Future<List<Certificate>> getCertificates() {
    return _remoteDataSource.getCertificates();
  }

  @override
  Future<List<Certificate>> reconcileCertificates() {
    return _remoteDataSource.reconcileCertificates();
  }

  @override
  Future<Certificate> generateCertificate(String courseId) {
    return _remoteDataSource.generateCertificate(courseId);
  }

  @override
  Future<Map<String, dynamic>> verifyCertificate(String code) {
    return _remoteDataSource.verifyCertificate(code);
  }

  @override
  Future<Uint8List> downloadCertificatePdf(String certificateId) {
    return _remoteDataSource.downloadCertificatePdf(certificateId);
  }

  @override
  Uri verificationUri(String code) => Uri.parse(
    _publicWebUrl,
  ).replace(path: '/verify-certificate', queryParameters: {'code': code});
}
