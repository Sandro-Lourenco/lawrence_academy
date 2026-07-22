import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/profile/application/use_cases/get_my_profile_use_case.dart';
import 'package:lawrence/features/profile/domain/entities/user_profile.dart';
import 'package:lawrence/features/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> getMyProfile() async {
    return const UserProfile(
      id: 'student-1',
      email: 'student@example.com',
      role: 'student',
      fullName: 'Student Name',
    );
  }
}

void main() {
  test('get my profile delegates to the domain repository', () async {
    final useCase = GetMyProfileUseCase(FakeProfileRepository());

    final profile = await useCase.execute();

    expect(profile.id, 'student-1');
    expect(profile.fullName, 'Student Name');
  });
}
