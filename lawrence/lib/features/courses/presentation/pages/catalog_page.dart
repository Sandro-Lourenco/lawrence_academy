import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_card.dart';
import '../../application/catalog_notifier.dart';
import '../../domain/entities/course.dart';

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
    final selectedCat = ref.watch(categoryFilterProvider);
    final selectedLevel = ref.watch(levelFilterProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    final filtersSidebarContent = Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Color(0xB8FFFFFF),
        border: Border(
          right: BorderSide(color: LawrenceColors.borderMist, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filtros",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: LawrenceColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (isDesktop)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 14,
                        color: LawrenceColors.textPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showFiltersSidebar = false;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Seção Categorias
              const Text(
                "CATEGORIA",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: LawrenceColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              _buildFilterChip(
                "Modelagem",
                "modelagem",
                categoryFilterProvider,
              ),
              _buildFilterChip(
                "Alfaiataria",
                "alfaiataria",
                categoryFilterProvider,
              ),
              _buildFilterChip("Costura", "costura", categoryFilterProvider),

              const SizedBox(height: 32),

              // Seção Níveis
              const Text(
                "NÍVEL",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: LawrenceColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 10),
              _buildFilterChip("Iniciante", "iniciante", levelFilterProvider),
              _buildFilterChip(
                "Intermediário",
                "intermediario",
                levelFilterProvider,
              ),
              _buildFilterChip("Avançado", "avancado", levelFilterProvider),

              const Spacer(),
              // Limpar Filtros
              if (selectedCat != null || selectedLevel != null)
                TextButton(
                  onPressed: () {
                    ref.read(categoryFilterProvider.notifier).state = null;
                    ref.read(levelFilterProvider.notifier).state = null;
                    ref.read(searchFilterProvider.notifier).state = "";
                  },
                  child: const Text(
                    "Limpar Filtros",
                    style: TextStyle(
                      color: LawrenceColors.primary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment, // Fundo claro #F8F9FB
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: LawrenceColors.canvasParchment,
              child: SafeArea(child: filtersSidebarContent),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sidebar de Filtros no Desktop
          if (isDesktop && _showFiltersSidebar) filtersSidebarContent,

          // 2. Área Principal do Catálogo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de Ferramentas: Pesquisa e Toggle Sidebar
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
                            color: Colors.white.withOpacity(0.72),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
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

                  // Título da página
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

                  // Lista de Cursos Grid
                  Expanded(
                    child: filteredCoursesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: LawrenceColors.primary,
                        ),
                      ),
                      error: (err, stack) => Center(
                        child: Text("Erro ao carregar catálogo: $err"),
                      ),
                      data: (courses) {
                        if (courses.isEmpty) {
                          return const EmptyStateWidget();
                        }
                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    StateProvider<String?> provider,
  ) {
    final currentVal = ref.watch(provider);
    final isSelected = currentVal == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          ref.read(provider.notifier).state = isSelected ? null : value;
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? LawrenceColors.primary.withOpacity(0.08)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? LawrenceColors.primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? LawrenceColors.primary
                      : LawrenceColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  size: 14,
                  color: LawrenceColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyStateWidget extends ConsumerWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.design_services_outlined,
            size: 64,
            color: LawrenceColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 20),
          const Text(
            "Nenhum curso corresponde aos filtros selecionados",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: LawrenceColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tente combinar termos diferentes ou limpar sua seleção.",
            style: TextStyle(
              fontSize: 12,
              color: LawrenceColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LawrenceColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              ref.read(categoryFilterProvider.notifier).state = null;
              ref.read(levelFilterProvider.notifier).state = null;
              ref.read(searchFilterProvider.notifier).state = "";
            },
            child: const Text(
              "Ver Todos os Cursos",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatefulWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        context.go('/course/${widget.course.slug}');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_scale, _scale, 1.0),
        transformAlignment: Alignment.center,
        child: LiquidGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner do Card
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C1B3D), Color(0xFF1F1235)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.course.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: LawrenceColors.primary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Informações do Curso
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
                        children: [
                          Text(
                            widget.course.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: LawrenceColors.textPrimary,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.course.summary,
                            style: const TextStyle(
                              fontSize: 12,
                              color: LawrenceColors.textSecondary,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.bar_chart,
                                size: 14,
                                color: _getLevelColor(widget.course.level),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.course.level.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: _getLevelColor(widget.course.level),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: LawrenceColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    if (level == "iniciante") return const Color(0xFF30D158); // Green
    if (level == "intermediario") return const Color(0xFFFF9F0A); // Orange
    return const Color(0xFFFF453A); // Red
  }
}
