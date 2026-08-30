import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/public/public_editorial_colors.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/catalog_filters_controller.dart';
import '../widgets/public_catalog/public_catalog_content.dart';

class PublicCatalogPage extends ConsumerStatefulWidget {
  const PublicCatalogPage({super.key});

  @override
  ConsumerState<PublicCatalogPage> createState() => _PublicCatalogPageState();
}

class _PublicCatalogPageState extends ConsumerState<PublicCatalogPage> {
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

    return Scaffold(
      backgroundColor: PublicEditorialColors.ivory,
      body: RefreshIndicator(
        color: PublicEditorialColors.wine,
        onRefresh: () => ref.read(catalogNotifierProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: PublicCatalogContent(
            courses: ref.watch(filteredCoursesProvider),
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onClearFilters: _clearFilters,
            onRetry: () => ref.read(catalogNotifierProvider.notifier).refresh(),
          ),
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
    if (GoRouter.maybeOf(context) == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = GoRouterState.of(context);
      final uri = Uri(
        path: '/courses',
        queryParameters: filters.toQueryParameters(),
      );
      if (uri.toString() != state.uri.toString()) {
        context.replace(uri.toString());
      }
    });
  }
}
