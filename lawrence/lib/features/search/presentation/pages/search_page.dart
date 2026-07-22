import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../controllers/search_controller.dart';
import '../../../courses/domain/entities/course.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white.withOpacity(0.72),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: LawrenceColors.canvas,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LawrenceColors.borderMist),
          ),
          child: TextField(
            autofocus: true,
            onChanged: (val) =>
                ref.read(searchNotifierProvider.notifier).onQueryChanged(val),
            decoration: const InputDecoration(
              hintText: "Cursos, aulas ou técnicas...",
              prefixIcon: Icon(
                Icons.search,
                color: LawrenceColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
      body: _buildContent(context, searchState),
    );
  }

  Widget _buildContent(BuildContext context, SearchState state) {
    if (state.query.isEmpty) {
      return const AppEmptyState(
        title: "O que você quer aprender hoje?",
        description:
            "Digite o nome de um curso, professor ou técnica para começar.",
        icon: Icons.manage_search_rounded,
      );
    }

    if (state.isSearching) {
      return const AppLoadingState();
    }

    if (state.results.isEmpty) {
      return AppEmptyState(
        title: "Nenhum resultado para \"${state.query}\"",
        description:
            "Tente usar termos mais genéricos ou verifique a ortografia.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final course = state.results[index];
        return _buildResultTile(context, course);
      },
    );
  }

  Widget _buildResultTile(BuildContext context, Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LawrenceColors.borderMist),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: LawrenceColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.import_contacts_rounded,
            color: LawrenceColors.primary,
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          course.category.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: LawrenceColors.accentGold,
            letterSpacing: 1,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: LawrenceColors.textSecondary,
        ),
        onTap: () => context.go('/courses/${course.slug}'),
      ),
    );
  }
}
