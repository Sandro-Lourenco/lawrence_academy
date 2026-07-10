import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories.dart';
import '../theme.dart';

// Provedor para buscar os cursos do repositório
final coursesFutureProvider = FutureProvider<List<Course>>((ref) {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.fetchPublishedCourses();
});

// Provedores de Estado dos Filtros
final searchFilterProvider = StateProvider<String>((ref) => "");
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final levelFilterProvider = StateProvider<String?>((ref) => null);

// Seletor computado de cursos filtrados localmente
final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final coursesAsync = ref.watch(coursesFutureProvider);
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
      decoration: BoxDecoration(
        color: LiquidTheme.background.withOpacity(0.95),
        border: Border(
          right: BorderSide(color: LiquidTheme.textPrimary.withOpacity(0.06)),
        ),
      ),
      padding: const EdgeInsets.all(24),
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
                  color: LiquidTheme.textPrimary,
                ),
              ),
              if (isDesktop)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 14),
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
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: LiquidTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          _buildFilterChip("Modelagem", "modelagem", categoryFilterProvider),
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
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: LiquidTheme.textSecondary,
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
                style: TextStyle(color: LiquidTheme.primary),
              ),
            ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: LiquidTheme.background,
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
                          icon: const Icon(Icons.filter_list),
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
                              color: LiquidTheme.primary,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                        ),
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: LiquidTheme.glassDecoration(
                            blurOpacity: 0.05,
                            borderOpacity: 0.08,
                            radius: 12,
                          ),
                          child: TextField(
                            onChanged: (val) {
                              ref.read(searchFilterProvider.notifier).state =
                                  val;
                            },
                            decoration: InputDecoration(
                              hintText:
                                  "Pesquisar por técnicas, moldes ou aulas...",
                              hintStyle: const TextStyle(
                                color: LiquidTheme.textSecondary,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: LiquidTheme.textSecondary,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                            ),
                            style: const TextStyle(
                              color: LiquidTheme.textPrimary,
                              fontSize: 14,
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
                      fontFamily: 'Outfit',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: LiquidTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de Cursos Grid
                  Expanded(
                    child: filteredCoursesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: LiquidTheme.primary,
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
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 360,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio: 0.85,
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
                ? LiquidTheme.primary.withOpacity(0.12)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? LiquidTheme.primary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.04),
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
                      ? LiquidTheme.primary
                      : LiquidTheme.textPrimary,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, size: 14, color: LiquidTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget de Estado Vazio (Ilustração Croqui de Modelagem minimalista)
class EmptyStateWidget extends ConsumerWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone desenhado a traço fino simulando ateliê
          Icon(
            Icons.design_services_outlined,
            size: 64,
            color: LiquidTheme.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 20),
          const Text(
            "Nenhum curso corresponde aos filtros selecionados",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: LiquidTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tente combinar termos diferentes ou limpar sua seleção.",
            style: TextStyle(fontSize: 12, color: LiquidTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LiquidTheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              ref.read(categoryFilterProvider.notifier).state = null;
              ref.read(levelFilterProvider.notifier).state = null;
              ref.read(searchFilterProvider.notifier).state = "";
            },
            child: const Text("Ver Todos os Cursos"),
          ),
        ],
      ),
    );
  }
}

// Card de Curso animado
class CourseCard extends StatefulWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: LiquidTheme.glassDecoration(
            blurOpacity: _isHovered ? 0.12 : 0.08,
            borderOpacity: _isHovered ? 0.18 : 0.10,
            radius: 16,
          ),
          clipBehavior: Clip.antiAlias,
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
                      decoration: LiquidTheme.glassDecoration(radius: 8),
                      child: Text(
                        widget.course.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: LiquidTheme.primary,
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
                              color: LiquidTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.course.summary,
                            style: const TextStyle(
                              fontSize: 12,
                              color: LiquidTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Nível indicador
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
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: LiquidTheme.primary,
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
    if (level == "iniciante") return const Color(0xFF34D399); // Verde Pastel
    if (level == "intermediario")
      return const Color(0xFFFBBF24); // Amarelo Pastel
    return const Color(0xFFF87171); // Vermelho Pastel
  }
}
