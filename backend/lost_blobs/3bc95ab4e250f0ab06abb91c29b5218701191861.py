import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../controllers/catalog_controller.dart';
import '../../domain/entities/course.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../widgets/course_card.dart';
import '../widgets/filters_sidebar.dart';
import '../../../../core/error/app_error.dart';

// Provedores de Estado dos Filtros
final searchFilterProvider = StateProvider<String>((ref) => "");
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final levelFilterProvider = StateProvider<String?>((ref) => null);

// Seletor computado de cursos filtrados localmente
final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final coursesAsync = ref.watch(catalogNotifierProvider);
  final query = ref.watch(searchFilterProvider).toLowerCase();
  final selectedCat = ref.watch(categoryFilterProvider);
  final selectedLevel = ref.watch(levelFilterProvider);

  return coursesAsync.whenData((list) {
    return list.where((course) {
      final matchesSearch =
          course.title.toLowerCase().contains(query) ||
          course.summary.toLowerCase().contains(query);
      final matchesCat = selectedCat == null || course.category == selectedCat;
      final matchesLevel =
          selectedLevel == null || course.level == selectedLevel;
      return matchesSearch && matchesCat && matchesLevel;
    }).toList();
  });
});

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  bool _showFiltersSidebar = true;

  @override
  Widget build(BuildContext context) {
    final filteredCoursesAsync = ref.watch(filteredCoursesProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final isScrollableParent = Scrollable.maybeOf(context) != null;

    final filtersSidebarContent = FiltersSidebar(
      onClose: () {
        setState(() {
          _showFiltersSidebar = false;
        });
      },
    );

    final bodyContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop && _showFiltersSidebar) filtersSidebarContent,

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isDesktop && !_showFiltersSidebar)
                      IconButton(
                        icon: const Icon(
                          Icons.filter_list,
                          color: LawrenceColors.textPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _showFiltersSidebar = true;
                          });
                        },
                      ),
                    if (!isDesktop)
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: LawrenceColors.primary,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ),
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: TextField(
                              onChanged: (val) {
                                ref
                                        .read(searchFilterProvider.notifier)
                                        .state =
                                    val;
                              },
                              decoration: const InputDecoration(
                                hintText:
                                    "Pesquisar por técnicas, moldes ou aulas...",
                                hintStyle: TextStyle(
                                  color: LawrenceColors.textSecondary,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: LawrenceColors.textSecondary,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                              ),
                              style: const TextStyle(
                                color: LawrenceColors.textPrimary,
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  "Catálogo de Cursos",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: LawrenceColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                isScrollableParent
                    ? _buildGridContent(
                        filteredCoursesAsync,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      )
                    : Expanded(
                        child: _buildGridContent(
                          filteredCoursesAsync,
                          shrinkWrap: false,
                          physics: const BouncingScrollPhysics(),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isScrollableParent) {
      return Material(
        color: Colors.transparent,
        child: bodyContent,
      );
    }

    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: LawrenceColors.canvasParchment,
              child: SafeArea(child: filtersSidebarContent),
            )
          : null,
      body: bodyContent,
    );
  }

  Widget _buildGridContent(
    AsyncValue<List<Course>> filteredCoursesAsync, {
    required bool shrinkWrap,
    required ScrollPhysics physics,
  }) {
    return filteredCoursesAsync.when(
      loading: () => _buildGridSkeleton(shrinkWrap: shrinkWrap, physics: physics),
      error: (err, stack) {
        final appError = AppError.fromException(err);
        return AppErrorState(
          title: appError.title,
          message: appError.message,
          onRetry: () => ref.refresh(catalogNotifierProvider),
        );
      },
      data: (courses) {
        if (courses.isEmpty) {
          return AppEmptyState(
            title: "Nenhum curso encontrado",
            description:
                "Tente combinar termos diferentes ou limpar sua seleção.",
            actionLabel: "Ver Todos os Cursos",
            onActionPressed: () {
              ref.read(categoryFilterProvider.notifier).state = null;
              ref.read(levelFilterProvider.notifier).state = null;
              ref.read(searchFilterProvider.notifier).state = "";
            },
          );
        }
        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.82,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            return CourseCard(course: courses[index]);
          },
        );
      },
    );
  }

  Widget _buildGridSkeleton({
    bool shrinkWrap = false,
    ScrollPhysics physics = const NeverScrollableScrollPhysics(),
  }) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.82,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LawrenceColors.borderMist),
          ),
          child: Column(
            children: [
              const Expanded(
                flex: 4,
                child: AppSkeletonState(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 16,
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppSkeletonState(width: 140, height: 18),
                          SizedBox(height: 8),
                          AppSkeletonState(width: double.infinity, height: 12),
                          SizedBox(height: 4),
                          AppSkeletonState(width: 100, height: 12),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          AppSkeletonState(width: 60, height: 14),
                          AppSkeletonState(
                            width: 16,
                            height: 16,
                            borderRadius: 8,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
