import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_card.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../controllers/favorites_controller.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      appBar: AppBar(
        title: const Text(
          "MINHA BIBLIOTECA",
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.72),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: favoritesAsync.when(
        loading: () => const AppLoadingState(),
        error: (err, st) =>
            AppErrorState(message: "Erro ao carregar favoritos."),
        data: (favorites) {
          if (favorites.isEmpty) {
            return AppEmptyState(
              title: "Sua biblioteca está vazia",
              description:
                  "Salve cursos e aulas para acessá-los rapidamente aqui.",
              icon: Icons.favorite_border_rounded,
              actionLabel: "Explorar Cursos",
              onActionPressed: () => context.go('/dashboard/courses'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.8,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return _buildFavoriteCard(context, favorite);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, dynamic favorite) {
    final course = favorite.course;

    return LiquidGlassCard(
      onTap: () => context.go('/courses/${course.slug}'),
      child: Row(
        children: [
          Container(
            width: 80,
            height: double.infinity,
            decoration: BoxDecoration(
              color: LawrenceColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: LawrenceColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: LawrenceColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: LawrenceColors.textSecondary),
        ],
      ),
    );
  }
}
