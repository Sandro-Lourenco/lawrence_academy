import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../controllers/catalog_filters_controller.dart';

class FiltersSidebar extends ConsumerWidget {
  final VoidCallback? onClose;

  const FiltersSidebar({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogFiltersProvider);
    final notifier = ref.read(catalogFiltersProvider.notifier);

    return Material(
      color: LawrenceColors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LawrenceRadii.card),
        side: const BorderSide(color: LawrenceColors.borderMist),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filtros',
                    style: TextStyle(
                      color: LawrenceColors.brandNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    tooltip: 'Fechar filtros',
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            _FilterGroup(
              label: 'Categoria',
              selected: filters.category,
              values: const {
                'costura': 'Costura',
                'modelagem': 'Modelagem',
                'alfaiataria': 'Alfaiataria',
              },
              onSelected: notifier.setCategory,
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            _FilterGroup(
              label: 'Nível',
              selected: filters.level,
              values: const {
                'iniciante': 'Iniciante',
                'intermediario': 'Intermediário',
                'avancado': 'Avançado',
              },
              onSelected: notifier.setLevel,
            ),
            if (filters.hasActiveFilters) ...[
              const SizedBox(height: LawrenceSpacing.lg),
              OutlinedButton.icon(
                onPressed: notifier.clear,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Limpar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String label;
  final String? selected;
  final Map<String, String> values;
  final ValueChanged<String?> onSelected;

  const _FilterGroup({
    required this.label,
    required this.selected,
    required this.values,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Filtro por $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: LawrenceColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: LawrenceSpacing.sm),
          Wrap(
            spacing: LawrenceSpacing.xs,
            runSpacing: LawrenceSpacing.xs,
            children: [
              for (final entry in values.entries)
                FilterChip(
                  label: Text(entry.value),
                  selected: selected == entry.key,
                  showCheckmark: true,
                  onSelected: (isSelected) =>
                      onSelected(isSelected ? entry.key : null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
