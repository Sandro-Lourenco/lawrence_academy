import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/design_system/widgets/state_widgets.dart';

void main() {
  group('AppEmptyState Widget Tests', () {
    testWidgets('should render title and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'No Data',
              description: 'Try searching for something else.',
            ),
          ),
        ),
      );

      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Try searching for something else.'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    testWidgets('should show action button when actionLabel is provided', (
      WidgetTester tester,
    ) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Title',
              description: 'Desc',
              actionLabel: 'Action',
              onActionPressed: () => pressed = true,
            ),
          ),
        ),
      );

      final buttonFinder = find.text('Action');
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder);
      expect(pressed, true);
    });
  });

  group('AppErrorState Widget Tests', () {
    testWidgets('should render error message and title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorState(message: 'Server connection failed'),
          ),
        ),
      );

      expect(find.text('Ops! Algo deu errado'), findsOneWidget);
      expect(find.text('Server connection failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('should call onRetry when button is pressed', (
      WidgetTester tester,
    ) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorState(
              message: 'Error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tentar Novamente'));
      expect(retried, true);
    });
  });

  group('AppLoadingState Widget Tests', () {
    testWidgets('should render progress indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoadingState())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render message when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppLoadingState(message: 'Carregando aulas...')),
        ),
      );

      expect(find.text('Carregando aulas...'), findsOneWidget);
    });
  });
}
