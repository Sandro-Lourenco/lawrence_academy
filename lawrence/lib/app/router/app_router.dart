import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/layouts/public_layout.dart';
import '../../design_system/layouts/student_layout.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';

import '../../features/certificates/presentation/pages/certificates_page.dart';

import '../../features/courses/presentation/pages/catalog_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';

import '../../features/dashboard/presentation/pages/student_dashboard_page.dart';

import '../../features/invoices/presentation/pages/invoices_page.dart';

import '../../features/lessons/presentation/pages/lessons_list_page.dart';

import '../../features/lives/presentation/pages/lives_page.dart';

import '../../features/player/presentation/pages/secure_player_page.dart';

import '../../features/profile/presentation/pages/student_profile_page.dart';
import '../../features/profile/presentation/pages/student_settings_page.dart';

import '../../features/subscriptions/presentation/pages/payment_pending_page.dart';
import '../../features/subscriptions/presentation/pages/subscriptions_page.dart';
import '../../features/subscriptions/presentation/pages/course_checkout_page.dart';

import '../../features/sync/presentation/pages/offline_downloads_page.dart';

import '../../features/achievements/presentation/pages/achievements_page.dart';
import '../../features/referral/presentation/pages/referral_page.dart';

import '../../features/activities/presentation/pages/activities_page.dart';
import '../../features/activities/presentation/pages/projects_page.dart';
import '../../features/activities/presentation/pages/project_detail_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';

import '../../features/search/presentation/pages/search_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/teacher_studio/presentation/pages/course_wizard_page.dart';
import '../../features/teacher_studio/presentation/pages/teacher_dashboard_page.dart';

String authenticatedHomeForRole(String? role) {
  return role == 'teacher' || role == 'super_admin'
      ? '/teacher'
      : '/dashboard/home';
}

bool shouldRedirectAuthenticatedFromPublicEntry(String path) =>
    path == '/login' || path == '/register' || path == '/forgot-password';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: kIsWeb ? '/' : '/login',

    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final userRole = authState.user?.appMetadata['role'] as String?;
      final authenticatedHome = authenticatedHomeForRole(userRole);
      final currentPath = state.uri.path;

      if (state.uri.scheme == 'lawrence' && state.uri.host == 'payment') {
        final sessionId = state.uri.queryParameters['session_id'];
        if (currentPath == '/pending' &&
            sessionId != null &&
            sessionId.isNotEmpty) {
          return '/payment/pending/$sessionId';
        }
        if (currentPath == '/cancel') return '/dashboard/home';
      }

      if (kDebugMode) {
        debugPrint(
          '[GoRouter Guard] '
          'isLoggedIn: $isLoggedIn, '
          'path: $currentPath, '
          'authState: $authState',
        );
      }

      // Usuários autenticados não permanecem nas páginas públicas
      // de entrada, login ou cadastro.
      if (isLoggedIn &&
          shouldRedirectAuthenticatedFromPublicEntry(currentPath)) {
        if (kDebugMode) {
          debugPrint(
            '[GoRouter Guard] '
            'Redirecting authenticated user to /dashboard/home',
          );
        }

        return authenticatedHome;
      }

      // Toda rota iniciada por /dashboard exige autenticação.
      if (!isLoggedIn &&
          (currentPath.startsWith('/dashboard') ||
              currentPath.startsWith('/teacher') ||
              currentPath.startsWith('/checkout') ||
              currentPath.startsWith('/payment'))) {
        if (kDebugMode) {
          debugPrint(
            '[GoRouter Guard] '
            'Redirecting unauthenticated user to /login',
          );
        }

        return '/login';
      }

      if (isLoggedIn &&
          currentPath.startsWith('/teacher') &&
          userRole != 'teacher' &&
          userRole != 'super_admin') {
        return '/dashboard/home';
      }

      // Em aplicativos instalados, o primeiro contato do usuário anônimo é
      // sempre a autenticação. O catálogo público continua sendo a raiz Web.
      if (!kIsWeb && !isLoggedIn && currentPath == '/') {
        return '/login';
      }

      return null;
    },

    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Página não encontrada')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Não encontramos esta página.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(state.uri.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    final destination = authState.user != null
                        ? authenticatedHomeForRole(
                            authState.user?.appMetadata['role'] as String?,
                          )
                        : '/';

                    context.go(destination);
                  },
                  child: const Text('Voltar ao início'),
                ),
              ],
            ),
          ),
        ),
      );
    },

    routes: [
      // ============================================================
      // ROTAS PÚBLICAS
      // ============================================================
      ShellRoute(
        builder: (context, state, child) {
          return PublicLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return const CatalogPage(embeddedInScrollView: true);
            },
          ),
          GoRoute(
            path: '/courses',
            builder: (context, state) {
              return const CatalogPage(embeddedInScrollView: true);
            },
          ),
          GoRoute(
            path: '/courses/:slug',
            builder: (context, state) {
              final slug = state.pathParameters['slug'] ?? '';

              return CourseDetailPage(slug: slug);
            },
          ),
          GoRoute(
            path: '/course/:slug',
            redirect: (context, state) {
              final slug = state.pathParameters['slug'] ?? '';
              return '/courses/$slug';
            },
          ),
        ],
      ),

      // ============================================================
      // AUTENTICAÇÃO
      // ============================================================
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          return const LoginPage(startInRegistrationMode: true);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) {
          return const LoginPage(startInPasswordRecoveryMode: true);
        },
      ),

      // ============================================================
      // PAGAMENTO
      // ============================================================
      GoRoute(
        path: '/checkout/:courseId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          return CourseCheckoutPage(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/payment/pending/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? '';

          return PaymentPendingPage(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/pending',
        redirect: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'];
          return sessionId == null || sessionId.isEmpty
              ? '/dashboard/home'
              : '/payment/pending/$sessionId';
        },
      ),
      GoRoute(path: '/cancel', redirect: (context, state) => '/dashboard/home'),

      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboardPage(),
      ),
      GoRoute(
        path: '/teacher/courses/new',
        builder: (context, state) => const CourseWizardPage(),
      ),
      GoRoute(
        path: '/teacher/courses/:courseId/edit',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'];
          return CourseWizardPage(courseId: courseId);
        },
      ),

      // ============================================================
      // ÁREA AUTENTICADA DO ALUNO
      // ============================================================
      ShellRoute(
        builder: (context, state, child) {
          return StudentLayout(body: child);
        },
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) {
              return const StudentDashboardPage();
            },
          ),

          // Catálogo autenticado
          GoRoute(
            path: '/dashboard/courses',
            builder: (context, state) {
              return const CatalogPage();
            },
          ),

          // Lista de aulas de um curso
          GoRoute(
            path: '/dashboard/courses/:courseId',
            builder: (context, state) {
              final courseId = state.pathParameters['courseId'] ?? '';

              return LessonsListPage(courseId: courseId);
            },
          ),

          // Player seguro
          GoRoute(
            path: '/dashboard/courses/:courseId/lessons/:lessonId',
            builder: (context, state) {
              final courseId = state.pathParameters['courseId'] ?? '';

              final lessonId = state.pathParameters['lessonId'] ?? '';

              return SecurePlayerPage(courseId: courseId, lessonId: lessonId);
            },
          ),

          // Lives
          GoRoute(
            path: '/dashboard/lives',
            builder: (context, state) {
              return const LivesPage();
            },
          ),

          // Assinaturas
          GoRoute(
            path: '/dashboard/subscriptions',
            builder: (context, state) {
              return const SubscriptionsPage();
            },
          ),

          // Faturas
          GoRoute(
            path: '/dashboard/invoices',
            builder: (context, state) {
              return const InvoicesPage();
            },
          ),

          // Perfil
          GoRoute(
            path: '/dashboard/profile',
            builder: (context, state) {
              return const StudentProfilePage();
            },
          ),

          // Configurações
          GoRoute(
            path: '/dashboard/settings',
            builder: (context, state) {
              return const StudentSettingsPage();
            },
          ),

          // Central de downloads offline
          GoRoute(
            path: '/dashboard/downloads',
            builder: (context, state) {
              return const OfflineDownloadsPage();
            },
          ),

          // Certificados
          GoRoute(
            path: '/dashboard/certificates',
            builder: (context, state) {
              return const CertificatesPage();
            },
          ),

          // Conquistas
          GoRoute(
            path: '/dashboard/achievements',
            builder: (context, state) {
              return const AchievementsPage();
            },
          ),

          // Indicações
          GoRoute(
            path: '/dashboard/referral',
            builder: (context, state) {
              return const ReferralPage();
            },
          ),

          // Atividades
          GoRoute(
            path: '/dashboard/activities',
            builder: (context, state) {
              return const ActivitiesPage();
            },
          ),

          GoRoute(
            path: '/dashboard/projects',
            builder: (context, state) {
              return const ProjectsPage();
            },
          ),
          GoRoute(
            path: '/dashboard/projects/:projectId',
            builder: (context, state) {
              final projectId = state.pathParameters['projectId'] ?? '';
              return ProjectDetailPage(projectId: projectId);
            },
          ),

          // Calendário
          GoRoute(
            path: '/dashboard/calendar',
            builder: (context, state) {
              return const CalendarPage();
            },
          ),

          // Busca Global
          GoRoute(
            path: '/dashboard/search',
            builder: (context, state) {
              return const SearchPage();
            },
          ),

          // Favoritos / Biblioteca
          GoRoute(
            path: '/dashboard/favorites',
            builder: (context, state) {
              return const FavoritesPage();
            },
          ),
        ],
      ),
    ],
  );
});
