import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/service_repositories.dart';
import '../../application/use_cases/update_my_profile_use_case.dart';
import '../../domain/entities/user_profile.dart';

final studentProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  return ref.watch(getMyProfileUseCaseProvider).execute();
});

class StudentProfileController extends StateNotifier<AsyncValue<UserProfile?>> {
  StudentProfileController(this._ref, this._updateMyProfileUseCase)
    : super(const AsyncValue.data(null));

  final Ref _ref;
  final UpdateMyProfileUseCase _updateMyProfileUseCase;

  Future<bool> updateProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _updateMyProfileUseCase.execute(profile);
      state = AsyncValue.data(updated);
      _ref.invalidate(studentProfileProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final editProfileControllerProvider =
    StateNotifierProvider.autoDispose<
      StudentProfileController,
      AsyncValue<UserProfile?>
    >((ref) {
      return StudentProfileController(
        ref,
        ref.watch(updateMyProfileUseCaseProvider),
      );
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
