import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/network/network_client.dart';
import '../../domain/entities/certificate.dart';

class CertificateRemoteDataSource {
  final NetworkClient _networkClient;

  CertificateRemoteDataSource(this._networkClient);

  Future<List<Certificate>> getCertificates() async {
    try {
      final response = await _networkClient.get<List<dynamic>>(
        '/api/v1/certificates',
      );
      return (response.data ?? const <dynamic>[])
          .whereType<Map>()
          .map((json) => Certificate.fromJson(json.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (e) {
      throw Exception('Failed to fetch certificates: $e');
    }
  }

  Future<List<Certificate>> reconcileCertificates() async {
    try {
      final response = await _networkClient.post<List<dynamic>>(
        '/api/v1/certificates/reconcile',
      );
      return (response.data ?? const <dynamic>[])
          .whereType<Map>()
          .map((json) => Certificate.fromJson(json.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (e) {
      throw Exception('Failed to reconcile certificates: $e');
    }
  }

  Future<Certificate> generateCertificate(String courseId) async {
    try {
      final response = await _networkClient.post<Map<String, dynamic>>(
        '/api/v1/certificates/generate',
        data: {'course_id': courseId},
      );
      return Certificate.fromJson(response.data ?? const {});
    } catch (e) {
      throw Exception('Failed to generate certificate: $e');
    }
  }

  Future<Map<String, dynamic>> verifyCertificate(String code) async {
    try {
      final response = await _networkClient.get<Map<String, dynamic>>(
        '/api/v1/certificates/$code/verify',
      );
      return response.data ?? const {};
    } catch (e) {
      throw Exception('Failed to verify certificate: $e');
    }
  }

  Future<Uint8List> downloadCertificatePdf(String certificateId) async {
    final response = await _networkClient.get<List<int>>(
      '/api/v1/certificates/$certificateId/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const <int>[]);
  }
}
