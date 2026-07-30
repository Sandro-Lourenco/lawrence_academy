import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_error.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../domain/entities/course.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/catalog_filters_controller.dart';
import '../widgets/course_card.dart';
import '../widgets/filters_sidebar.dart';

class CatalogPage extends ConsumerStatefulWidget {
  final bool embeddedInScrollView;

  const CatalogPage({super.key, this.embeddedInScrollView = false});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _filtersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filtersInitialized) return;
    _filtersInitialized = true;
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    final filters = CatalogFilters.fromQueryParameters(
      GoRouterState.of(context).uri.queryParameters,
    );
    _searchController.text = filters.query;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(catalogFiltersProvider.notifier).replace(filters);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CatalogFilters>(catalogFiltersProvider, (_, next) {
      if (_searchController.text != next.query) {
        _searchController.value = TextEditingValue(
          text: next.query,
          selection: TextSelection.collapsed(offset: next.query.length),
        );
      }
      _writeFiltersToUrl(next);
    });

    final content = _CatalogContent(
      courses: ref.watch(filteredCoursesProvider),
      searchController: _searchController,
      onSearchChanged: _onSearchChanged,
      onOpenFilters: () => _showFilters(context),
      onRetry: () => ref.read(catalogNotifierProvider.notifier).refresh(),
      onClearFilters: _clearFilters,
    );

    if (widget.embeddedInScrollView) {
      return Material(color: LawrenceColors.canvasParchment, child: content);
    }
    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      body: RefreshIndicator(
        color: LawrenceColors.actionPrimary,
        onRefresh: () => ref.read(catalogNotifierProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: content,
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (mounted) ref.read(catalogFiltersProvider.notifier).setQuery(value);
    });
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    ref.read(catalogFiltersProvider.notifier).clear();
    setState(() {});
  }

  void _writeFiltersToUrl(CatalogFilters filters) {
    final router = GoRouter.maybeOf(context);
    if (router == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = GoRouterState.of(context);
      final uri = Uri(
        path: state.uri.path == '/' ? '/courses' : state.uri.path,
        queryParameters: filters.toQueryParameters(),
      );
      if (uri.toString() != state.uri.toString()) context.replace(uri.toString());
    });
  }

  Future<void> _showFilters(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: FiltersSidebar(onClose: () => Navigator.pop(sheetContext)),
      ),
    ),
  );
}

class _CatalogContent extends ConsumerWidget {
  final AsyncValue<List<Course>> courses;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilters;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;

  const _CatalogContent({
    required this.courses,
    required this.searchController,
    required this.onSearchChanged,
    required this.onOpenFilters,
    required this.onRetry,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogFiltersProvider);
    final desktop = MediaQuery.sizeOf(context).width >= LawrenceBreakpoints.desktop;
    final searching = filters.query.trim().isNotEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            desktop ? 40 : 20,
            desktop ? 40 : 24,
            desktop ? 40 : 20,
            64,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CatalogHero(
                searching: searching,
                query: filters.query,
                controller: searchController,
                onChanged: onSearchChanged,
                onClear: onClearFilters,
              ),
              const SizedBox(height: LawrenceSpacing.xl),
              _ContentSelector(filters: filters),
              const SizedBox(height: LawrenceSpacing.xl),
              if (!searching && filters.contentType != 'books') ...[
                _FeaturedCourseStrip(courses: courses, onRetry: onRetry),
                const SizedBox(height: LawrenceSpacing.xxl),
              ],
              if (!searching && filters.contentType == 'all') ...[
                const _BooksPreview(),
                const SizedBox(height: LawrenceSpacing.xxl),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (desktop) ...[
                    const SizedBox(width: 260, child: FiltersSidebar()),
                    const SizedBox(width: LawrenceSpacing.xl),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!desktop)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: onOpenFilters,
                              icon: const Icon(Icons.tune_rounded),
                              label: Text(
                                filters.hasActiveFacets
                                    ? 'Filtros ativos'
                                    : 'Filtrar resultados',
                              ),
                            ),
                          ),
                        if (!desktop) const SizedBox(height: LawrenceSpacing.md),
                        if (filters.contentType == 'books')
                          const _BooksEmptyState()
                        else
                          _CourseResultsState(
                            courses: courses,
                            query: filters.query,
                            onRetry: onRetry,
                            onClear: onClearFilters,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogHero extends StatelessWidget {
  final bool searching;
  final String query;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _CatalogHero({
    required this.searching,
    required this.query,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 280),
      child: Column(
        key: ValueKey(searching),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            searching ? 'Resultados da pesquisa' : 'Explore o catálogo',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: LawrenceColors.brandNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: LawrenceSpacing.sm),
          Text(
            searching
                ? 'Cursos e conteúdos encontrados para “$query”. Refine pelos filtros abaixo.'
                : 'Cursos profissionais de moda, costura e modelagem para transformar conhecimento em prática.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LawrenceColors.textSecondary,
            ),
          ),
          const SizedBox(height: LawrenceSpacing.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: TextField(
              key: const Key('catalog-search-field'),
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'O que você quer aprender?',
                hintText: 'Título, técnica ou categoria',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar pesquisa',
                        onPressed: onClear,
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSelector extends ConsumerWidget {
  final CatalogFilters filters;

  const _ContentSelector({required this.filters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      container: true,
      label: 'Tipo de conteúdo',
      child: Wrap(
        spacing: 0,
        runSpacing: LawrenceSpacing.xs,
        children: [
          _ContentButton(
            label: 'Tudo',
            value: 'all',
            selected: filters.contentType == 'all',
          ),
          _ContentButton(
            label: 'Cursos',
            value: 'courses',
            selected: filters.contentType == 'courses',
          ),
          _ContentButton(
            label: 'Livros Lawrence',
            value: 'books',
            selected: filters.contentType == 'books',
          ),
        ],
      ),
    );
  }
}

class _ContentButton extends ConsumerWidget {
  final String label;
  final String value;
  final bool selected;

  const _ContentButton({
    required this.label,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? LawrenceColors.actionPrimary
              : LawrenceColors.canvas,
          foregroundColor:
              selected ? LawrenceColors.canvas : LawrenceColors.actionPrimary,
          side: const BorderSide(color: LawrenceColors.actionPrimary),
          shape: const RoundedRectangleBorder(),
        ),
        onPressed: () => ref
            .read(catalogFiltersProvider.notifier)
            .setContentType(value),
        child: Text(label),
      ),
    );
  }
}

class _FeaturedCourseStrip extends StatelessWidget {
  final AsyncValue<List<Course>> courses;
  final VoidCallback onRetry;

  const _FeaturedCourseStrip({required this.courses, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return courses.when(
      loading: () => const AppSkeletonState(
        width: double.infinity,
        height: 208,
        borderRadius: LawrenceRadii.control,
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final featured = items.firstWhere(
          (course) => course.isFeatured,
          orElse: () => items.first,
        );
        return Container(
          decoration: const BoxDecoration(
            color: LawrenceColors.brandNavy,
            border: Border(
              left: BorderSide(color: LawrenceColors.actionPrimary, width: 5),
            ),
          ),
          padding: const EdgeInsets.all(LawrenceSpacing.xl),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 700;
              final info = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURSO EM DESTAQUE',
                    style: TextStyle(
                      color: LawrenceColors.actionOnDark,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: LawrenceSpacing.sm),
                  Text(
                    featured.title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: LawrenceSpacing.sm),
                  Text(
                    featured.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 17),
                  ),
                ],
              );
              final action = FilledButton.icon(
                style: FilledButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                ),
                onPressed: () => context.go('/courses/${featured.slug}'),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Conhecer curso'),
              );
              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        info,
                        const SizedBox(height: LawrenceSpacing.lg),
                        action,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: info),
                        const SizedBox(width: LawrenceSpacing.xl),
                        action,
                      ],
                    );
            },
          ),
        );
      },
    );
  }
}

class _BooksPreview extends StatelessWidget {
  const _BooksPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF0FB),
      padding: const EdgeInsets.all(LawrenceSpacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          const copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      color: LawrenceColors.actionPrimary,
                      size: 36,
                    ),
                    SizedBox(height: LawrenceSpacing.md),
                    Text(
                      'Explore os livros da Lawrence',
                      style: TextStyle(
                        color: LawrenceColors.brandNavy,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: LawrenceSpacing.sm),
                    Text(
                      'Leitura guiada, referências práticas e cadernos de apoio para estudar no seu ritmo.',
                      style: TextStyle(
                        color: LawrenceColors.textSecondary,
                        fontSize: 17,
                      ),
                    ),
                  ],
                );
          final action = OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(),
                  ),
                  onPressed: null,
                  icon: const Icon(Icons.schedule_rounded),
                  label: const Text('Biblioteca em preparação'),
                );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                copy,
                const SizedBox(height: LawrenceSpacing.lg),
                action,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(flex: 2, child: copy),
              const SizedBox(width: LawrenceSpacing.xl),
              Expanded(child: action),
            ],
          );
        },
      ),
    );
  }
}

class _BooksEmptyState extends StatelessWidget {
  const _BooksEmptyState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 400,
      child: AppEmptyState(
        title: 'Livros Lawrence em preparação',
        description:
            'A biblioteca será publicada aqui. Nenhum título fictício é exibido enquanto o acervo real não estiver disponível.',
        icon: Icons.auto_stories_outlined,
      ),
    );
  }
}

class _CourseResultsState extends StatelessWidget {
  final AsyncValue<List<Course>> courses;
  final String query;
  final VoidCallback onRetry;
  final VoidCallback onClear;

  const _CourseResultsState({
    required this.courses,
    required this.query,
    required this.onRetry,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return courses.when(
      loading: () => const _CatalogSkeleton(),
      error: (error, _) {
        final appError = AppError.fromException(error);
        return SizedBox(
          height: 440,
          child: AppErrorState(
            title: appError.title,
            message: appError.message,
            onRetry: onRetry,
          ),
        );
      },
      data: (items) => items.isEmpty
          ? SizedBox(
              height: 440,
              child: AppEmptyState(
                title: query.isEmpty
                    ? 'Nenhum curso publicado'
                    : 'Nenhum resultado para “$query”',
                description:
                    'Tente outro termo ou remova os filtros selecionados.',
                actionLabel: 'Limpar filtros',
                onActionPressed: onClear,
              ),
            )
          : _CourseResults(courses: items),
    );
  }
}

class _CourseResults extends StatelessWidget {
  final List<Course> courses;

  const _CourseResults({required this.courses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            '${courses.length} ${courses.length == 1 ? 'curso encontrado' : 'cursos encontrados'}',
            style: const TextStyle(
              color: LawrenceColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: LawrenceSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 560
                    ? 2
                    : 1;
            final width =
                (constraints.maxWidth - (columns - 1) * LawrenceSpacing.md) /
                columns;
            return Wrap(
              spacing: LawrenceSpacing.md,
              runSpacing: LawrenceSpacing.md,
              children: [
                for (var index = 0; index < courses.length; index++)
                  SizedBox(
                    width: width,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : Duration(milliseconds: 180 + index.clamp(0, 5) * 45),
                      builder: (_, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: CourseCard(course: courses[index]),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: LawrenceSpacing.md,
      runSpacing: LawrenceSpacing.md,
      children: [
        for (var index = 0; index < 6; index++)
          const SizedBox(
            width: 280,
            child: AppSkeletonState(
              width: double.infinity,
              height: 390,
              borderRadius: LawrenceRadii.control,
            ),
          ),
      ],
    );
  }
}
