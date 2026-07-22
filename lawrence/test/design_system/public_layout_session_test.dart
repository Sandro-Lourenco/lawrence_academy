import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/layouts/public_layout.dart';

void main() {
  group('publicAccountDestination', () {
    test('sends students to their own dashboard', () {
      expect(publicAccountDestination('student'), '/dashboard/home');
      expect(publicAccountDestination(null), '/dashboard/home');
    });

    test('sends teachers to the teacher workspace', () {
      expect(publicAccountDestination('teacher'), '/teacher');
      expect(publicAccountDestination('super_admin'), '/teacher');
    });
  });
}
