import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/profile/presentation/controllers/student_profile_controller.dart';

void main() {
  test('profileInitials uses first and last names', () {
    expect(profileInitials('Larissa da Silva', 'larissa@example.com'), 'LS');
  });

  test('profileInitials falls back to the email', () {
    expect(profileInitials(null, 'aluna@example.com'), 'A');
  });

  test('profileInitials handles missing identity safely', () {
    expect(profileInitials('  ', '  '), '?');
  });

  test('profileRoleLabel does not expose an unknown backend role', () {
    expect(profileRoleLabel('unexpected'), 'Usuário');
  });
}
