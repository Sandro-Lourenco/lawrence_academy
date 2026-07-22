import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/service_repositories.dart';
import '../../domain/entities/user_profile.dart';

final studentProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  return ref.watch(getMyProfileUseCaseProvider).execute();
});

String profileInitials(String? fullName, String email) {
  final normalized = fullName?.trim() ?? '';
  if (normalized.isEmpty) {
    return email.trim().isEmpty ? '?' : email.trim()[0].toUpperCase();
  }
  final parts = normalized
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String profileRoleLabel(String role) {
  return switch (role.toLowerCase()) {
    'student' => 'Aluno',
    'teacher' => 'Professor',
    'admin' => 'Administrador',
    'super_admin' => 'Superadministrador',
    _ => 'Usuário',
  };
}
