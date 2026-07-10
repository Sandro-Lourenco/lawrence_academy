import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/layouts/public_layout.dart';
import '../../design_system/layouts/student_layout.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/courses/presentation/pages/catalog_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';

// Placeholder Pages para rotas que ainda não foram migradas nesta fase
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "$title (Módulo pendente de migração na Fase 5A)",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoggingIn =
          state.uri.toString() == '/login' ||
          state.uri.toString() == '/register';

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
          GoRoute(path: '/', builder: (context, state) => const CatalogPage()),
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
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const LoginPage(),
      ),

      // 3. Rotas do Painel do Aluno encapsuladas no StudentLayout
      ShellRoute(
        builder: (context, state, child) => StudentLayout(body: child),
        routes: [
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) =>
                const PlaceholderPage(title: 'Dashboard do Aluno'),
          ),
          GoRoute(
            path: '/dashboard/lives',
            builder: (context, state) =>
                const PlaceholderPage(title: 'Lives do Aluno'),
          ),
          GoRoute(
            path: '/dashboard/profile',
            builder: (context, state) =>
                const PlaceholderPage(title: 'Perfil do Aluno'),
          ),
        ],
      ),
    ],
  );
});
