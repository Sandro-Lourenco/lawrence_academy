import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_error.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/student_page_header.dart';
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
      if (!mounted) return;
      ref.read(catalogFiltersProvider.notifier).replace(filters);
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
    ref.listen<CatalogFilters>(catalogFiltersProvider, (previous, next) {
      if (_searchController.text != next.query) {
        _searchController.value = TextEditingValue(
          text: next.query,
          selection: TextSelection.collapsed(offset: next.query.length),
        );
      }
      _writeFiltersToUrl(next);
    });

    final courses = ref.watch(filteredCoursesProvider);
    final width = MediaQuery.sizeOf(context).width;
    final showSidebar = width >= LawrenceBreakpoints.desktop;
    final content = _CatalogContent(
      courses: courses,
      showSidebar: showSidebar,
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
          padding: const EdgeInsets.all(LawrenceSpacing.lg),
          child: content,
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) ref.read(catalogFiltersProvider.notifier).setQuery(value);
    });
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    ref.read(catalogFiltersProvider.notifier).clear();
  }

  void _writeFiltersToUrl(CatalogFilters filters) {
    final router = GoRouter.maybeOf(context);
    if (router == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = GoRouterState.of(context);
      final path = state.uri.path == '/' ? '/courses' : state.uri.path;
      final uri = Uri(path: path, queryParameters: filters.toQueryParameters());
      if (uri.toString() != state.uri.toString()) {
        context.replace(uri.toString());
      }
    });
  }

  Future<void> _showFilters(BuildContext context) {
    return showModalBottomSheet<void>(
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
}

class _CatalogContent extends ConsumerWidget {
  final AsyncValue<List<Course>> courses;
  final bool showSidebar;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilters;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;

  const _CatalogContent({
    required this.courses,
    required this.showSidebar,
    required this.searchController,
    required this.onSearchChanged,
    required this.onOpenFilters,
    required this.onRetry,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogFiltersProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StudentPageHeader(
              title: 'Cursos',
              subtitle: 'Aprenda moda, modelagem e costura no seu ritmo.',
            ),
            const SizedBox(height: LawrenceSpacing.xl),
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Buscar cursos',
                hintText: 'Título, tema ou categoria',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        onPressed: onClearFilters,
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: LawrenceSpacing.md),
            Wrap(
              spacing: LawrenceSpacing.xs,
              runSpacing: LawrenceSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _AccessChip(value: 'all', label: 'Todos'),
                _AccessChip(value: 'free', label: 'Gratuitos'),
                _AccessChip(value: 'paid', label: 'Assinatura mensal'),
                if (!showSidebar)
                  OutlinedButton.icon(
                    onPressed: onOpenFilters,
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(
                      filters.category == null && filters.level == null
                          ? 'Filtros'
                          : 'Filtros ativos',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSidebar) ...[
                  const SizedBox(width: 280, child: FiltersSidebar()),
                  const SizedBox(width: LawrenceSpacing.lg),
                ],
                Expanded(
                  child: courses.when(
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
                              title: 'Nenhum curso encontrado',
                              description:
                                  'Tente outro termo ou remova os filtros selecionados.',
                              actionLabel: 'Limpar filtros',
                              onActionPressed: onClearFilters,
                            ),
                          )
                        : _CourseResults(courses: items),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
              fontWeight: FontWeight.w600,
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
            final itemWidth =
                (constraints.maxWidth - (columns - 1) * LawrenceSpacing.md) /
                columns;
            return Wrap(
              spacing: LawrenceSpacing.md,
              runSpacing: LawrenceSpacing.md,
              children: [
                for (final course in courses)
                  SizedBox(
                    width: itemWidth,
                    child: CourseCard(course: course),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final itemWidth =
            (constraints.maxWidth - (columns - 1) * LawrenceSpacing.md) /
            columns;
        return Wrap(
          spacing: LawrenceSpacing.md,
          runSpacing: LawrenceSpacing.md,
          children: [
            for (var index = 0; index < 6; index++)
              SizedBox(
                width: itemWidth,
                child: const AppSkeletonState(
                  width: double.infinity,
                  height: 360,
                  borderRadius: LawrenceRadii.card,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AccessChip extends ConsumerWidget {
  final String value;
  final String label;

  const _AccessChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(catalogFiltersProvider).access == value;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) =>
          ref.read(catalogFiltersProvider.notifier).setAccess(value),
    );
  }
}
