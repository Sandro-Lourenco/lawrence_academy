import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/widgets/semantic_progress_indicator.dart';
import 'package:lawrence/design_system/widgets/status_badge.dart';
import 'package:lawrence/design_system/widgets/student_page_header.dart';
import 'package:lawrence/design_system/widgets/student_page_scaffold.dart';

void main() {
  Widget app(Widget child) => MaterialApp(home: child);

  testWidgets('scaffold apresenta título, descrição e conteúdo', (tester) async {
    await tester.pumpWidget(
      app(
        const StudentPageScaffold(
          title: 'Projetos',
          subtitle: 'Pratique suas habilidades.',
          body: Text('Conteúdo da página'),
        ),
      ),
    );

    expect(find.text('Projetos'), findsOneWidget);
    expect(find.text('Pratique suas habilidades.'), findsOneWidget);
    expect(find.text('Conteúdo da página'), findsOneWidget);
  });

  testWidgets('header empilha ações em largura compacta', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      app(
        Scaffold(
          body: StudentPageHeader(
            title: 'Cursos',
            actions: [FilledButton(onPressed: () {}, child: const Text('Ação'))],
          ),
        ),
      ),
    );

    final flex = tester.widget<Flex>(find.byType(Flex));
    expect(flex.direction, Axis.vertical);
  });

  testWidgets('badge comunica status por texto e semântica', (tester) async {
    await tester.pumpWidget(
      app(
        const Scaffold(
          body: AppStatusBadge(
            label: 'Concluído',
            icon: Icons.check,
            tone: AppStatusTone.success,
          ),
        ),
      ),
    );

    expect(find.text('Concluído'), findsOneWidget);
    expect(find.bySemanticsLabel('Status: Concluído'), findsOneWidget);
  });

  testWidgets('progresso limita valor e expõe percentual', (tester) async {
    await tester.pumpWidget(
      app(
        const Scaffold(
          body: SemanticProgressIndicator(
            value: 1.4,
            label: 'Progresso do curso',
          ),
        ),
      ),
    );

    expect(find.text('100%'), findsOneWidget);
    expect(find.bySemanticsLabel('Progresso do curso'), findsOneWidget);
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, 1);
  });
}
