import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/service_repositories.dart';
import '../../domain/entities/certificate.dart';

final certificatesListProvider = FutureProvider<List<Certificate>>((ref) async {
  final repository = ref.watch(certificateRepositoryProvider);
  return repository.getCertificates();
});

final generateCertificateProvider = FutureProvider.family<Certificate, String>((
  ref,
  courseId,
) async {
  final repository = ref.watch(certificateRepositoryProvider);
  return repository.generateCertificate(courseId);
});
