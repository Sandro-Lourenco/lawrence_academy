import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_container.dart';
import '../controllers/catalog_filters_controller.dart';

class FiltersSidebar extends ConsumerWidget {
  final VoidCallback? onClose;

  const FiltersSidebar({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogFiltersProvider);
    final notifier = ref.read(catalogFiltersProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    return LiquidGlassContainer(
      borderRadius: LawrenceRadii.featured,
      blurSigma: 16,
      backgroundColor: scheme.surface.withValues(alpha: .72),
      fallbackColor: scheme.surface,
      borderColor: scheme.outlineVariant.withValues(alpha: .24),
      padding: const EdgeInsets.all(LawrenceSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filtros',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
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
          const _GroupLabel('Acesso'),
          _SquareChoice(
            label: 'Todos',
            selected: filters.access == 'all',
            onChanged: () => notifier.setAccess('all'),
          ),
          _SquareChoice(
            label: 'Gratuitos',
            selected: filters.access == 'free',
            onChanged: () => notifier.setAccess('free'),
          ),
          _SquareChoice(
            label: 'Assinatura mensal',
            selected: filters.access == 'paid',
            onChanged: () => notifier.setAccess('paid'),
          ),
          const SizedBox(height: LawrenceSpacing.lg),
          const _GroupLabel('Categorias'),
          _SquareChoice(
            label: 'Costura',
            selected: filters.category == 'costura',
            onChanged: () => notifier.setCategory(
              filters.category == 'costura' ? null : 'costura',
            ),
          ),
          _SquareChoice(
            label: 'Modelagem',
            selected: filters.category == 'modelagem',
            onChanged: () => notifier.setCategory(
              filters.category == 'modelagem' ? null : 'modelagem',
            ),
          ),
          _SquareChoice(
            label: 'Alfaiataria',
            selected: filters.category == 'alfaiataria',
            onChanged: () => notifier.setCategory(
              filters.category == 'alfaiataria' ? null : 'alfaiataria',
            ),
          ),
          const SizedBox(height: LawrenceSpacing.lg),
          const _GroupLabel('Nível'),
          _SquareChoice(
            label: 'Iniciante',
            selected: filters.level == 'iniciante',
            onChanged: () => notifier.setLevel(
              filters.level == 'iniciante' ? null : 'iniciante',
            ),
          ),
          _SquareChoice(
            label: 'Intermediário',
            selected: filters.level == 'intermediario',
            onChanged: () => notifier.setLevel(
              filters.level == 'intermediario' ? null : 'intermediario',
            ),
          ),
          _SquareChoice(
            label: 'Avançado',
            selected: filters.level == 'avancado',
            onChanged: () => notifier.setLevel(
              filters.level == 'avancado' ? null : 'avancado',
            ),
          ),
          if (filters.hasActiveFacets) ...[
            const SizedBox(height: LawrenceSpacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                final content = filters.contentType;
                notifier.clear();
                notifier.setContentType(content);
              },
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpar filtros'),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;

  const _GroupLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: LawrenceSpacing.sm),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    ),
  );
}

class _SquareChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onChanged;

  const _SquareChoice({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    checked: selected,
    button: true,
    child: InkWell(
      onTap: onChanged,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: LawrenceSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
