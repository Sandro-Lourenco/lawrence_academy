import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/app/providers/service_repositories.dart';
import 'package:lawrence/features/profile/domain/entities/user_profile.dart';
import 'package:lawrence/features/profile/domain/repositories/profile_repository.dart';
import 'package:lawrence/features/profile/presentation/pages/student_edit_profile_page.dart';

class _ProfileRepository implements ProfileRepository {
  static const profile = UserProfile(
    id: 'student-1',
    email: 'aluna@example.com',
    role: 'student',
    fullName: 'Aluna Lawrence',
    certificateName: 'Aluna Lawrence',
    urlUsername: 'alunalawrence',
  );

  @override
  Future<UserProfile> getMyProfile() async => profile;

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async => profile;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async => 'https://example.com/avatar.png';
}

void main() {
  testWidgets('layout mobile não apresenta overflow com texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(245, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(_ProfileRepository()),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const StudentEditProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Formação acadêmica'), findsOneWidget);
    expect(find.text('Aberto(a) a novas oportunidades'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
