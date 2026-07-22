import 'package:dio/dio.dart';
import '../../domain/entities/certificate.dart';

class CertificateRemoteDataSource {
  final Dio _dio;

  CertificateRemoteDataSource(this._dio);

  Future<List<Certificate>> getCertificates() async {
    try {
      final response = await _dio.get('/api/v1/certificates');
      final data = response.data as List;
      return data.map((json) => Certificate.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch certificates: $e');
    }
  }

  Future<Certificate> generateCertificate(String courseId) async {
    try {
      final response = await _dio.post(
        '/api/v1/certificates/generate',
        data: {'course_id': courseId},
      );
      return Certificate.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to generate certificate: $e');
    }
  }

  Future<Map<String, dynamic>> verifyCertificate(String code) async {
    try {
      final response = await _dio.get('/api/v1/certificates/$code/verify');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to verify certificate: $e');
    }
  }
}
