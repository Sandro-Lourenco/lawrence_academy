import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/features/courses/domain/entities/course.dart';
import 'package:lawrence/features/courses/presentation/widgets/course_card.dart';

void main() {
  testWidgets('card informa periodicidade, nível e quantidade de aulas', (
    tester,
  ) async {
    const course = Course(
      id: '1',
      instructorId: 'teacher',
      title: 'Costura para iniciantes',
      slug: 'costura-iniciantes',
      category: 'costura',
      level: 'iniciante',
      summary: 'Aprenda costura',
      status: 'published',
      monthlyPrice: 49.9,
      modules: [],
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: CourseCard(course: course)),
        ),
        GoRoute(
          path: '/courses/:slug',
          builder: (_, _) => const Scaffold(body: Text('Detalhe')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Assinatura mensal'), findsOneWidget);
    expect(find.text('R\$ 49,90 por mês'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Nível iniciante.*49,90 por mês')),
      findsOneWidget,
    );
  });
}
