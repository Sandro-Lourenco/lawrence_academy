import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/motion/public_motion.dart';
import '../../../../../design_system/public/public_editorial_colors.dart';
import '../../../../../design_system/public/public_editorial_typography.dart';
import '../../../../../design_system/public/public_glass_button.dart';
import '../../../../../design_system/public/public_editorial_footer.dart';
import '../../../domain/entities/course.dart';
import '../../controllers/catalog_filters_controller.dart';
import 'digital_books_section.dart';
import 'public_course_card.dart';

class PublicCatalogContent extends ConsumerWidget {
  const PublicCatalogContent({
    super.key,
    required this.courses,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearFilters,
    required this.onRetry,
  });

  final AsyncValue<List<Course>> courses;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogFiltersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CatalogHero(
          controller: searchController,
          onChanged: onSearchChanged,
          onClear: onClearFilters,
        ),
        _EditorialTrustBand(),
        if (!filters.hasActiveFilters)
          _FeaturedCourse(courses: courses, onRetry: onRetry),
        _CoursesCollection(
          courses: courses,
          filters: filters,
          onClearFilters: onClearFilters,
          onRetry: onRetry,
        ),
        const DigitalBooksSection(),
        const _CatalogFinale(),
        const PublicEditorialFooter(),
      ],
    );
  }
}

class _CatalogHero extends StatelessWidget {
  const _CatalogHero({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;
    return ColoredBox(
      color: PublicEditorialColors.noir,
      child: SizedBox(
        height: mobile ? 900 : (width >= 1100 ? 1080 : 800),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: mobile
                  ? Alignment.bottomCenter
                  : Alignment.centerRight,
              child: SizedBox(
                width: mobile ? double.infinity : width * .48,
                height: mobile ? 360 : double.infinity,
                child: Image.asset(
                  'assets/images/couture_atelier_hero.webp',
                  fit: BoxFit.cover,
                  alignment: const Alignment(.15, 0),
                  semanticLabel:
                      'Ateliê de moda com tecidos e ferramentas de criação',
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: mobile ? Alignment.topCenter : Alignment.centerLeft,
                  end: mobile ? Alignment.bottomCenter : Alignment.centerRight,
                  colors: mobile
                      ? const [
                          PublicEditorialColors.noir,
                          PublicEditorialColors.noir,
                          Color(0xE6100C0D),
                          Color(0x33100C0D),
                        ]
                      : const [
                          PublicEditorialColors.noir,
                          Color(0xFF100C0D),
                          Color(0xF2100C0D),
                          Color(0x33100C0D),
                        ],
                  stops: mobile
                      ? const [0, .53, .7, 1]
                      : const [0, .42, .61, 1],
                ),
              ),
            ),
            Positioned(
              right: mobile ? -20 : width * .37,
              top: mobile ? 104 : 110,
              child: ExcludeSemantics(
                child: Text(
                  'C',
                  style: PublicEditorialTypography.sectionDisplay(
                    color: PublicEditorialColors.ivory.withValues(alpha: .06),
                    size: mobile ? 260 : 430,
                  ).copyWith(height: .72),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      mobile ? 24 : 72,
                      mobile ? 114 : 146,
                      mobile ? 24 : 72,
                      mobile ? 350 : 76,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: mobile ? 620 : 690,
                        ),
                        child: PublicReveal(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FORMAÇÕES LAWRENCE · COLEÇÃO 01',
                                style: PublicEditorialTypography.eyebrow(
                                  color: PublicEditorialColors.champagne,
                                ),
                              ),
                              const SizedBox(height: 25),
                              Text(
                                'Técnica para vestir a sua assinatura.',
                                style: PublicEditorialTypography.heroDisplay(
                                  context,
                                  color: PublicEditorialColors.ivory,
                                ),
                              ),
                              const SizedBox(height: 25),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 570,
                                ),
                                child: Text(
                                  'Encontre formações em costura, modelagem e alta-costura com uma jornada clara, prática e feita para avançar no seu ritmo.',
                                  style: PublicEditorialTypography.bodyLarge(
                                    color: PublicEditorialColors.parchment,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 34),
                              _EditorialSearchField(
                                controller: controller,
                                onChanged: onChanged,
                                onClear: onClear,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialSearchField extends StatelessWidget {
  const _EditorialSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Semantics(
    textField: true,
    label: 'Buscar cursos Lawrence',
    child: Container(
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        color: PublicEditorialColors.ivory.withValues(alpha: .96),
        border: Border.all(
          color: PublicEditorialColors.white.withValues(alpha: .74),
        ),
        boxShadow: [
          BoxShadow(
            color: PublicEditorialColors.noir.withValues(alpha: .26),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: PublicEditorialTypography.body(color: PublicEditorialColors.ink),
        decoration: InputDecoration(
          hintText: 'O que você quer aprender?',
          hintStyle: PublicEditorialTypography.body(
            color: PublicEditorialColors.mutedInk,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: PublicEditorialColors.wine,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  tooltip: 'Limpar busca',
                  icon: const Icon(Icons.close_rounded),
                  color: PublicEditorialColors.wine,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    ),
  );
}

class _EditorialTrustBand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    const items = [
      ('01', 'Projetos práticos'),
      ('02', 'Progresso no seu ritmo'),
      ('03', 'Certificado por curso'),
      ('04', 'Assinatura individual'),
    ];
    return ColoredBox(
      color: PublicEditorialColors.wine,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 24 : 72,
              vertical: 23,
            ),
            child: Wrap(
              spacing: mobile ? 22 : 48,
              runSpacing: 14,
              alignment: WrapAlignment.spaceBetween,
              children: items
                  .map(
                    (item) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.$1,
                          style: PublicEditorialTypography.eyebrow(
                            color: PublicEditorialColors.champagne,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.$2,
                          style: PublicEditorialTypography.caption(
                            color: PublicEditorialColors.ivory,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCourse extends StatelessWidget {
  const _FeaturedCourse({required this.courses, required this.onRetry});

  final AsyncValue<List<Course>> courses;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => courses.when(
    loading: () => const SizedBox.shrink(),
    error: (_, _) => const SizedBox.shrink(),
    data: (items) {
      if (items.isEmpty) return const SizedBox.shrink();
      final featured =
          items.where((course) => course.isFeatured).firstOrNull ?? items.first;
      final mobile = MediaQuery.sizeOf(context).width < 800;
      return ColoredBox(
        color: PublicEditorialColors.ivory,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 24 : 72,
                vertical: mobile ? 86 : 132,
              ),
              child: _FeaturedCourseCard(course: featured),
            ),
          ),
        ),
      );
    },
  );
}

class _FeaturedCourseCard extends StatefulWidget {
  const _FeaturedCourseCard({required this.course});

  final Course course;

  @override
  State<_FeaturedCourseCard> createState() => _FeaturedCourseCardState();
}

class _FeaturedCourseCardState extends State<_FeaturedCourseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final mobile = MediaQuery.sizeOf(context).width < 800;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : PublicMotion.standard;
    final durationLabel = course.estimatedDurationMinutes == null
        ? '${course.lessonCount} aulas'
        : _featuredDuration(course.estimatedDurationMinutes!);
    final price = course.isFree
        ? 'Acesso gratuito'
        : 'R\$ ${course.monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')} / mês';

    final image = ClipRect(
      child: AnimatedScale(
        duration: duration,
        curve: PublicMotion.entranceCurve,
        scale: _hovered && !reduceMotion ? 1.018 : 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _featureImage(course.category),
              fit: BoxFit.cover,
              alignment: const Alignment(0, .08),
              semanticLabel:
                  course.coverAltText ??
                  'Imagem editorial do curso ${course.title}',
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: mobile ? Alignment.topCenter : Alignment.centerLeft,
                  end: mobile ? Alignment.bottomCenter : Alignment.centerRight,
                  colors: mobile
                      ? const [Colors.transparent, Color(0x66100C0D)]
                      : const [Colors.transparent, Color(0x12100C0D)],
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                color: PublicEditorialColors.ivory.withValues(alpha: .92),
                child: Text(
                  'EDIÇÃO 01',
                  style: PublicEditorialTypography.eyebrow(
                    color: PublicEditorialColors.wine,
                  ).copyWith(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final copy = Stack(
      children: [
        Positioned(
          right: -14,
          top: -34,
          child: ExcludeSemantics(
            child: Text(
              '01',
              style: PublicEditorialTypography.sectionDisplay(
                color: PublicEditorialColors.ivory.withValues(alpha: .045),
                size: mobile ? 150 : 205,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            mobile ? 30 : 52,
            mobile ? 38 : 46,
            mobile ? 30 : 48,
            mobile ? 36 : 42,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 1,
                    color: PublicEditorialColors.champagne,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'CURSO EM DESTAQUE',
                      style: PublicEditorialTypography.eyebrow(
                        color: PublicEditorialColors.champagne,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: mobile ? 22 : 28),
              Text(
                course.title,
                maxLines: mobile ? 4 : 3,
                overflow: TextOverflow.ellipsis,
                style: PublicEditorialTypography.sectionDisplay(
                  color: PublicEditorialColors.ivory,
                  size: mobile ? 46 : 55,
                ).copyWith(height: .92),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 18,
                runSpacing: 10,
                children: [
                  _FeaturedMeta(
                    icon: Icons.signal_cellular_alt_rounded,
                    label: _featuredHumanize(course.level),
                  ),
                  _FeaturedMeta(
                    icon: Icons.schedule_outlined,
                    label: durationLabel,
                  ),
                  if (course.certificateEnabled)
                    const _FeaturedMeta(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Certificado',
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                course.summary,
                maxLines: mobile ? 4 : 3,
                overflow: TextOverflow.ellipsis,
                style: PublicEditorialTypography.body(
                  color: PublicEditorialColors.parchment,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                height: 1,
                color: PublicEditorialColors.ivory.withValues(alpha: .16),
              ),
              const SizedBox(height: 22),
              if (mobile) ...[
                Text(
                  price,
                  style: PublicEditorialTypography.buttonLabel(
                    color: PublicEditorialColors.ivory,
                  ),
                ),
                const SizedBox(height: 18),
                PublicGlassButton(
                  label: 'Conhecer curso',
                  tone: PublicGlassButtonTone.ivory,
                  expand: true,
                  onPressed: () => context.go('/courses/${course.slug}'),
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        price,
                        style: PublicEditorialTypography.buttonLabel(
                          color: PublicEditorialColors.ivory,
                        ),
                      ),
                    ),
                    PublicGlassButton(
                      label: 'Conhecer curso',
                      tone: PublicGlassButtonTone.ivory,
                      onPressed: () => context.go('/courses/${course.slug}'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );

    return Semantics(
      container: true,
      label: 'Curso em destaque: ${course.title}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: duration,
          decoration: BoxDecoration(
            color: PublicEditorialColors.plum,
            border: Border.all(
              color: _hovered
                  ? PublicEditorialColors.antiqueGold.withValues(alpha: .64)
                  : PublicEditorialColors.wine.withValues(alpha: .22),
            ),
            boxShadow: [
              BoxShadow(
                color: PublicEditorialColors.ink.withValues(
                  alpha: _hovered ? .18 : .10,
                ),
                blurRadius: _hovered ? 34 : 22,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: mobile
              ? Column(
                  children: [
                    SizedBox(height: 300, width: double.infinity, child: image),
                    copy,
                  ],
                )
              : SizedBox(
                  height: 620,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 13, child: image),
                      Expanded(flex: 9, child: copy),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _FeaturedMeta extends StatelessWidget {
  const _FeaturedMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: PublicEditorialColors.champagne),
      const SizedBox(width: 7),
      Text(
        label,
        style: PublicEditorialTypography.caption(
          color: PublicEditorialColors.parchment,
        ).copyWith(fontSize: 13),
      ),
    ],
  );
}

class _CoursesCollection extends StatelessWidget {
  const _CoursesCollection({
    required this.courses,
    required this.filters,
    required this.onClearFilters,
    required this.onRetry,
  });

  final AsyncValue<List<Course>> courses;
  final CatalogFilters filters;
  final VoidCallback onClearFilters;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return ColoredBox(
      color: PublicEditorialColors.ivory,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              mobile ? 24 : 72,
              0,
              mobile ? 24 : 72,
              mobile ? 96 : 142,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESCOLHA A SUA PRÓXIMA TÉCNICA',
                  style: PublicEditorialTypography.eyebrow(
                    color: PublicEditorialColors.wine,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Todos os cursos',
                  style: PublicEditorialTypography.sectionDisplay(
                    color: PublicEditorialColors.ink,
                    size: mobile ? 56 : 92,
                  ),
                ),
                const SizedBox(height: 30),
                const _EditorialFilters(),
                const SizedBox(height: 42),
                courses.when(
                  loading: () => const _LoadingGrid(),
                  error: (_, _) => _CatalogMessage(
                    title: 'Não foi possível carregar a coleção.',
                    message:
                        'Verifique sua conexão e tente novamente. A página continua pronta para quando você voltar.',
                    actionLabel: 'Tentar novamente',
                    onPressed: onRetry,
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return _CatalogMessage(
                        title: 'Nenhum curso com essa combinação.',
                        message:
                            'Retire um filtro ou experimente outra técnica para encontrar um novo ponto de partida.',
                        actionLabel: 'Limpar filtros',
                        onPressed: onClearFilters,
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${items.length} ${items.length == 1 ? 'formação encontrada' : 'formações encontradas'}',
                          semanticsLabel:
                              '${items.length} ${items.length == 1 ? 'curso encontrado' : 'cursos encontrados'}',
                          style: PublicEditorialTypography.caption(
                            color: PublicEditorialColors.mutedInk,
                          ),
                        ),
                        const SizedBox(height: 22),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 1120
                                ? 3
                                : constraints.maxWidth >= 680
                                ? 2
                                : 1;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 28,
                                    mainAxisExtent: columns == 1 ? 590 : 610,
                                  ),
                              itemBuilder: (context, index) =>
                                  PublicCourseCard(course: items[index]),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorialFilters extends ConsumerWidget {
  const _EditorialFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogFiltersProvider);
    final notifier = ref.read(catalogFiltersProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterGroup(
          label: 'Área',
          children: [
            _FilterChoice(
              label: 'Todas',
              selected: filters.category == null,
              onPressed: () => notifier.setCategory(null),
            ),
            _FilterChoice(
              label: 'Costura',
              selected: filters.category == 'costura',
              onPressed: () => notifier.setCategory('costura'),
            ),
            _FilterChoice(
              label: 'Modelagem',
              selected: filters.category == 'modelagem',
              onPressed: () => notifier.setCategory('modelagem'),
            ),
            _FilterChoice(
              label: 'Alfaiataria',
              selected: filters.category == 'alfaiataria',
              onPressed: () => notifier.setCategory('alfaiataria'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _FilterGroup(
          label: 'Nível e acesso',
          children: [
            _FilterChoice(
              label: 'Iniciante',
              selected: filters.level == 'iniciante',
              onPressed: () => notifier.setLevel(
                filters.level == 'iniciante' ? null : 'iniciante',
              ),
            ),
            _FilterChoice(
              label: 'Intermediário',
              selected: filters.level == 'intermediario',
              onPressed: () => notifier.setLevel(
                filters.level == 'intermediario' ? null : 'intermediario',
              ),
            ),
            _FilterChoice(
              label: 'Avançado',
              selected: filters.level == 'avancado',
              onPressed: () => notifier.setLevel(
                filters.level == 'avancado' ? null : 'avancado',
              ),
            ),
            _FilterChoice(
              label: 'Gratuitos',
              selected: filters.access == 'free',
              onPressed: () =>
                  notifier.setAccess(filters.access == 'free' ? 'all' : 'free'),
            ),
            _FilterChoice(
              label: 'Assinatura',
              selected: filters.access == 'paid',
              onPressed: () =>
                  notifier.setAccess(filters.access == 'paid' ? 'all' : 'paid'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: PublicEditorialTypography.eyebrow(
          color: PublicEditorialColors.mutedInk,
        ),
      ),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: children),
    ],
  );
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        focusColor: PublicEditorialColors.wine.withValues(alpha: .12),
        child: AnimatedContainer(
          duration: PublicMotion.accessibleDuration(context, PublicMotion.fast),
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? PublicEditorialColors.wine
                : PublicEditorialColors.white.withValues(alpha: .48),
            border: Border.all(
              color: selected
                  ? PublicEditorialColors.wine
                  : PublicEditorialColors.ink.withValues(alpha: .28),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: PublicEditorialColors.wine.withValues(alpha: .18),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const [],
          ),
          child: Text(
            label,
            style: PublicEditorialTypography.buttonLabel(
              color: selected
                  ? PublicEditorialColors.ivory
                  : PublicEditorialColors.ink,
            ).copyWith(fontSize: 13),
          ),
        ),
      ),
    ),
  );
}

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(44),
    decoration: BoxDecoration(
      color: PublicEditorialColors.parchment.withValues(alpha: .44),
      border: Border.all(
        color: PublicEditorialColors.ink.withValues(alpha: .16),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PublicEditorialTypography.courseTitle(
            color: PublicEditorialColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          message,
          style: PublicEditorialTypography.body(
            color: PublicEditorialColors.mutedInk,
          ),
        ),
        const SizedBox(height: 26),
        PublicGlassButton(label: actionLabel, onPressed: onPressed),
      ],
    ),
  );
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Carregando cursos',
    child: LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1120
            ? 3
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: columns,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 24,
            mainAxisExtent: 540,
          ),
          itemBuilder: (_, _) => Container(
            decoration: BoxDecoration(
              color: PublicEditorialColors.parchment.withValues(alpha: .52),
              border: Border.all(
                color: PublicEditorialColors.ink.withValues(alpha: .10),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _CatalogFinale extends StatelessWidget {
  const _CatalogFinale();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: PublicEditorialColors.wine,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Column(
            children: [
              Text(
                'O clássico começa pelo domínio.',
                textAlign: TextAlign.center,
                style: PublicEditorialTypography.sectionDisplay(
                  color: PublicEditorialColors.ivory,
                  size: 64,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Escolha uma formação e dê forma ao seu próximo capítulo.',
                textAlign: TextAlign.center,
                style: PublicEditorialTypography.body(
                  color: PublicEditorialColors.parchment,
                ),
              ),
              const SizedBox(height: 30),
              PublicGlassButton(
                label: 'Voltar ao início',
                tone: PublicGlassButtonTone.ivory,
                icon: Icons.arrow_upward_rounded,
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _featureImage(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('model') || normalized.contains('moulage')) {
    return 'assets/images/couture_draping_portrait.webp';
  }
  return 'assets/images/couture_pattern_table.webp';
}

String _featuredHumanize(String value) {
  if (value == 'intermediario') return 'Intermediário';
  if (value == 'avancado') return 'Avançado';
  if (value.isEmpty) return 'Todos os níveis';
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

String _featuredDuration(int minutes) {
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  return '${hours}h de conteúdo';
}
