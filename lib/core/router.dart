import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lawrence/presentation/dashboard/views/shell_layout.dart';
import '../ui/shell/public_layout.dart';
import '../ui/public/home_page.dart';
import '../ui/public/course_detail_page.dart';
import '../ui/catalog/catalog_page.dart';
import 'package:lawrence/presentation/dashboard/views/dashboard_page.dart';
import '../ui/player/course_player_page.dart';
import '../ui/tasks/task_execution_page.dart';
import '../ui/teacher/course_creation_wizard.dart';
import '../ui/admin/admin_analytics_page.dart';
import '../ui/theme.dart';
import 'package:lawrence/presentation/auth/views/login_page.dart';
import 'package:lawrence/presentation/auth/controllers/auth_controller.dart';
import 'package:lawrence/data/models/course_dto.dart';
import 'package:lawrence/data/repositories/course_repository.dart';
import 'auth_provider.dart';

// Wrapper para carregar o curso/aula assincronamente a partir da rota
class CoursePlayerRouteWrapper extends ConsumerWidget {
  final String courseId;
  final String lessonId;

  const CoursePlayerRouteWrapper({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(courseRepositoryProvider);

    return FutureBuilder<Course?>(
      future: repo.fetchCourseDetails(courseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: LiquidTheme.primary)),
          );
        }
        
        final course = snapshot.data;
        if (course == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: Text("Curso não encontrado.", style: TextStyle(color: Colors.white70))),
          );
        }

        // Encontrar a lição correspondente ao ID
        Lesson? lesson;
        for (var mod in course.modules) {
          for (var les in mod.lessons) {
            if (les.id == lessonId) {
              lesson = les;
              break;
            }
          }
        }

        // Se não encontrar por ID, pega a primeira lição disponível como fallback
        if (lesson == null && course.modules.isNotEmpty && course.modules.first.lessons.isNotEmpty) {
          lesson = course.modules.first.lessons.first;
        }

        if (lesson == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: Text("Nenhuma aula encontrada para este curso.", style: TextStyle(color: Colors.white70))),
          );
        }

        return CoursePlayerPage(course: course, initialLesson: lesson);
      },
    );
  }
}

// Configuração central do GoRouter para Lawrence Academy
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/register';

      // Redireciona usuários autenticados da Home/Login para o Dashboard
      if (isLoggedIn && (isLoggingIn || state.uri.toString() == '/')) {
        return '/dashboard/home';
      }

      // Proteger rotas do dashboard
      if (!isLoggedIn && state.uri.toString().startsWith('/dashboard')) {
        return '/login';
      }

      return null;
    },
    routes: [
      // 1. Rotas Públicas encapsuladas no PublicLayout
      ShellRoute(
        builder: (context, state, child) => PublicLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/courses',
            builder: (context, state) => const CatalogPage(),
          ),
          GoRoute(
            path: '/course/:slug',
            builder: (context, state) {
              final slug = state.pathParameters['slug'] ?? '';
              return CourseDetailPage(slug: slug);
            },
          ),
        ],
      ),

      // 2. Rotas de Autenticação (Sem Layout compartilhado)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const LoginPage(), // O construtor interno alterna baseado no modo
      ),

      // 3. Rotas do Painel do Aluno encapsuladas no DashboardLayout
      ShellRoute(
        builder: (context, state, child) => ShellLayout(body: child),
        routes: [
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) => const StudentDashboardPage(),
          ),
        ],
      ),

      // 4. Rota do Player de Vídeo Seguro (Modo Escuro Absoluto, sem shell padrão)
      GoRoute(
        path: '/dashboard/courses/:courseId/lesson/:lessonId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final lessonId = state.pathParameters['lessonId'] ?? '';
          return CoursePlayerRouteWrapper(courseId: courseId, lessonId: lessonId);
        },
      ),

      // 5. Rota de Execução de Tarefas
      GoRoute(
        path: '/dashboard/courses/:courseId/tasks/:taskId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final taskId = state.pathParameters['taskId'] ?? '';
          return TaskExecutionPage(courseId: courseId, taskId: taskId);
        },
      ),

      // 6. Rotas Administrativas e de Professores
      GoRoute(
        path: '/teacher/courses/new',
        builder: (context, state) => const CourseCreationWizard(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalyticsPage(),
      ),
    ],
  );
});
