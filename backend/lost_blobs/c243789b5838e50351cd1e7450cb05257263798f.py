import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../pages/catalog_page.dart';

class FiltersSidebar extends ConsumerWidget {
  final VoidCallback onClose;

  const FiltersSidebar({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCat = ref.watch(categoryFilterProvider);
    final selectedLevel = ref.watch(levelFilterProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
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
                      onPressed: onClose,
                    ),
                ],
              ),
              const SizedBox(height: 24),

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
                ref,
                "Modelagem",
                "modelagem",
                categoryFilterProvider,
              ),
              _buildFilterChip(
                ref,
                "Alfaiataria",
                "alfaiataria",
                categoryFilterProvider,
              ),
              _buildFilterChip(
                ref,
                "Costura",
                "costura",
                categoryFilterProvider,
              ),

              const SizedBox(height: 32),

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
              _buildFilterChip(
                ref,
                "Iniciante",
                "iniciante",
                levelFilterProvider,
              ),
              _buildFilterChip(
                ref,
                "Intermediário",
                "intermediario",
                levelFilterProvider,
              ),
              _buildFilterChip(
                ref,
                "Avançado",
                "avancado",
                levelFilterProvider,
              ),

              if (Scrollable.maybeOf(context) != null)
                const SizedBox(height: 32)
              else
                const Spacer(),
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
  }

  Widget _buildFilterChip(
    WidgetRef ref,
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
                ? LawrenceColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? LawrenceColors.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? LawrenceColors.primary
                        : LawrenceColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
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
