import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/service_repositories.dart';
import '../../domain/entities/certificate.dart';

final certificatesListProvider = FutureProvider<List<Certificate>>((ref) async {
  final repository = ref.watch(certificateRepositoryProvider);
  // Recupera também conclusões sincronizadas antes da correção do fluxo.
  // A operação no servidor é idempotente por estudante + curso.
  return repository.reconcileCertificates();
});

final generateCertificateProvider = FutureProvider.family<Certificate, String>((
  ref,
  courseId,
) async {
  final repository = ref.watch(certificateRepositoryProvider);
  return repository.generateCertificate(courseId);
});
