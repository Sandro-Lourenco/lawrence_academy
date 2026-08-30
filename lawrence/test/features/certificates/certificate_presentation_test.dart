import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/features/certificates/domain/entities/certificate.dart';
import 'package:lawrence/features/certificates/presentation/widgets/certificate_card.dart';
import 'package:lawrence/features/certificates/presentation/widgets/lawrence_certificate_preview.dart';

void main() {
  final certificate = Certificate.fromJson({
    'id': 'certificate-1',
    'student_id': 'student-1',
    'course_id': 'course-1',
    'validation_code': 'LWA-ABC12345',
    'signature': 'signature',
    'signature_algorithm': 'HMAC-SHA256',
    'signature_version': 1,
    'metadata': <String, dynamic>{
      'student_name': 'Ana Silva',
      'course_name': 'Modelagem Profissional',
      'course_workload_hours': 12.5,
      'completed_lesson_count': 8,
      'completion_date': '2026-08-20',
    },
    'issued_at': '2026-08-20T15:00:00Z',
  });

  test('certificate exposes the persisted completion evidence', () {
    expect(certificate.studentName, 'Ana Silva');
    expect(certificate.courseName, 'Modelagem Profissional');
    expect(certificate.workloadHours, 12.5);
    expect(certificate.completedLessonCount, 8);
    expect(certificate.completionDate, DateTime(2026, 8, 20));
  });

  testWidgets('card identifies the completed course and certificate owner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CertificateCard(certificate: certificate, onView: () {}),
        ),
      ),
    );

    expect(find.text('Modelagem Profissional'), findsOneWidget);
    expect(find.text('Concluído por Ana Silva'), findsOneWidget);
    expect(find.textContaining('LWA-ABC12345'), findsOneWidget);
  });

  testWidgets('preview contains only persisted certificate facts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            child: LawrenceCertificatePreview(
              certificate: certificate,
              userName: certificate.studentName,
            ),
          ),
        ),
      ),
    );

    expect(find.text('ANA SILVA'), findsOneWidget);
    expect(find.text('MODELAGEM PROFISSIONAL'), findsOneWidget);
    expect(find.textContaining('12,5 horas'), findsOneWidget);
    expect(find.textContaining('8 aulas concluídas'), findsOneWidget);
    expect(find.textContaining('LWA-ABC12345'), findsOneWidget);
    expect(find.textContaining('30 horas'), findsNothing);
  });
}
