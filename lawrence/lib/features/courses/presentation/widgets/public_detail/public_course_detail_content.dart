import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/motion/public_motion.dart';
import '../../../../../design_system/public/public_editorial_colors.dart';
import '../../../../../design_system/public/public_editorial_typography.dart';
import '../../../../../design_system/public/public_editorial_footer.dart';
import '../../../domain/entities/course.dart';
import 'public_course_curriculum.dart';
import 'public_course_purchase.dart';
import 'public_course_trailer.dart';

class PublicCourseDetailContent extends StatelessWidget {
  const PublicCourseDetailContent({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _CourseHero(course: course),
      _EditorialIndex(course: course),
      _CourseOutcomes(course: course),
      _CourseManifesto(course: course),
      PublicCourseTrailer(course: course),
      PublicCourseCurriculum(course: course),
      _AudienceAndMaterials(course: course),
      _CourseFaq(course: course),
      PublicCourseClosingOffer(course: course),
      const PublicEditorialFooter(),
    ],
  );
}

class _CourseHero extends StatelessWidget {
  const _CourseHero({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 800;
    final subtitle = course.subtitle.trim().isNotEmpty
        ? course.subtitle
        : course.summary;
    final copy = Padding(
      padding: EdgeInsets.fromLTRB(
        mobile ? 24 : 72,
        mobile ? 108 : 148,
        mobile ? 24 : 62,
        mobile ? 52 : 76,
      ),
      child: PublicReveal(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.go('/courses'),
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: const Text('VOLTAR À COLEÇÃO'),
              style: TextButton.styleFrom(
                foregroundColor: PublicEditorialColors.champagne,
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 48),
                textStyle: PublicEditorialTypography.eyebrow(
                  color: PublicEditorialColors.champagne,
                ),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 1,
                  color: PublicEditorialColors.champagne,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '${_categoryLabel(course.category).toUpperCase()} · EDIÇÃO LAWRENCE',
                    style: PublicEditorialTypography.eyebrow(
                      color: PublicEditorialColors.champagne,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              course.title,
              maxLines: mobile ? 5 : 4,
              overflow: TextOverflow.ellipsis,
              style: PublicEditorialTypography.heroDisplay(
                context,
                color: PublicEditorialColors.ivory,
              ).copyWith(fontSize: mobile ? 52 : 76, height: .92),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 26),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 610),
                child: Text(
                  subtitle,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: PublicEditorialTypography.bodyLarge(
                    color: PublicEditorialColors.parchment,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            _HeroFacts(course: course),
            const SizedBox(height: 34),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 370),
              child: PublicCourseAccessButton(course: course, expand: true),
            ),
          ],
        ),
      ),
    );
    final image = Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _courseImage(course.category),
          fit: BoxFit.cover,
          alignment: const Alignment(.08, 0),
          semanticLabel:
              course.coverAltText ??
              'Mesa de ateliê representando o curso ${course.title}',
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: mobile ? Alignment.topCenter : Alignment.centerLeft,
              end: mobile ? Alignment.bottomCenter : Alignment.centerRight,
              colors: mobile
                  ? const [Color(0x66100C0D), Color(0x10100C0D)]
                  : const [Color(0xB3100C0D), Color(0x00100C0D)],
            ),
          ),
        ),
        Positioned(
          right: 28,
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: PublicEditorialColors.ivory.withValues(alpha: .92),
            child: Text(
              'ATELIÊ · CADERNO 01',
              style: PublicEditorialTypography.eyebrow(
                color: PublicEditorialColors.wine,
              ).copyWith(fontSize: 10),
            ),
          ),
        ),
      ],
    );
    return ColoredBox(
      color: PublicEditorialColors.noir,
      child: mobile
          ? Column(
              children: [
                copy,
                SizedBox(height: 390, width: double.infinity, child: image),
              ],
            )
          : SizedBox(
              height: 1120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 11, child: copy),
                  Expanded(flex: 9, child: image),
                ],
              ),
            ),
    );
  }
}

class _HeroFacts extends StatelessWidget {
  const _HeroFacts({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 20,
    runSpacing: 12,
    children: [
      if (course.estimatedDurationMinutes case final minutes? when minutes > 0)
        _Fact(icon: Icons.schedule_outlined, label: _formatDuration(minutes)),
      _Fact(
        icon: Icons.menu_book_outlined,
        label:
            '${course.modules.length} ${course.modules.length == 1 ? 'módulo' : 'módulos'}',
      ),
      _Fact(
        icon: Icons.play_circle_outline_rounded,
        label:
            '${course.lessonCount} ${course.lessonCount == 1 ? 'aula' : 'aulas'}',
      ),
      _Fact(
        icon: Icons.signal_cellular_alt_rounded,
        label: _humanize(course.level),
      ),
      if (course.certificateEnabled)
        const _Fact(
          icon: Icons.workspace_premium_outlined,
          label: 'Certificado',
        ),
    ],
  );
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 17, color: PublicEditorialColors.champagne),
      const SizedBox(width: 7),
      Text(
        label,
        style: PublicEditorialTypography.caption(
          color: PublicEditorialColors.ivory,
        ).copyWith(fontSize: 13),
      ),
    ],
  );
}

class _EditorialIndex extends StatelessWidget {
  const _EditorialIndex({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    const entries = [
      ('01', 'Resultados'),
      ('02', 'Experiência'),
      ('03', 'Programa'),
      ('04', 'Para você'),
    ];
    return ColoredBox(
      color: PublicEditorialColors.wine,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 24 : 72,
          vertical: 22,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1296),
            child: Wrap(
              spacing: mobile ? 22 : 48,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: entries
                  .map(
                    (entry) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.$1,
                          style: PublicEditorialTypography.eyebrow(
                            color: PublicEditorialColors.champagne,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          entry.$2,
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

class _CourseOutcomes extends StatelessWidget {
  const _CourseOutcomes({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final items = <String>{
      ...course.learningObjectives,
      ...course.competencies,
      ...course.expectedOutcomes,
    }.where((item) => item.trim().isNotEmpty).take(6).toList();
    if (items.isEmpty) items.add(course.summary);
    final mobile = MediaQuery.sizeOf(context).width < 800;
    return _IvorySection(
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OutcomeIntro(),
                const SizedBox(height: 42),
                _OutcomeList(items: items),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 5, child: _OutcomeIntro()),
                const SizedBox(width: 90),
                Expanded(flex: 7, child: _OutcomeList(items: items)),
              ],
            ),
    );
  }
}

class _OutcomeIntro extends StatelessWidget {
  const _OutcomeIntro();

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned(
        left: -16,
        top: -70,
        child: ExcludeSemantics(
          child: Text(
            '01',
            style: PublicEditorialTypography.sectionDisplay(
              color: PublicEditorialColors.antiqueRose.withValues(alpha: .23),
              size: 190,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 42),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O QUE VOCÊ LEVA',
              style: PublicEditorialTypography.eyebrow(
                color: PublicEditorialColors.wine,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Da medida à confiança.',
              style: PublicEditorialTypography.sectionDisplay(
                color: PublicEditorialColors.ink,
                size: 66,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _OutcomeList extends StatelessWidget {
  const _OutcomeList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var index = 0; index < items.length; index++)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: PublicEditorialColors.ink.withValues(alpha: .18),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: PublicEditorialTypography.eyebrow(
                    color: PublicEditorialColors.wine,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  items[index],
                  style: PublicEditorialTypography.bodyLarge(
                    color: PublicEditorialColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _CourseManifesto extends StatelessWidget {
  const _CourseManifesto({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 800;
    final description = course.description.trim().isNotEmpty
        ? course.description
        : course.summary;
    final photo = Image.asset(
      'assets/images/couture_draping_portrait.webp',
      fit: BoxFit.cover,
      semanticLabel: 'Trabalho de moulage em um manequim de ateliê',
    );
    final copy = Container(
      color: PublicEditorialColors.plum,
      padding: EdgeInsets.all(mobile ? 34 : 68),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A EXPERIÊNCIA',
            style: PublicEditorialTypography.eyebrow(
              color: PublicEditorialColors.champagne,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Técnica clássica. Olhar contemporâneo.',
            style: PublicEditorialTypography.sectionDisplay(
              color: PublicEditorialColors.ivory,
              size: mobile ? 48 : 68,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: PublicEditorialTypography.body(
              color: PublicEditorialColors.parchment,
            ),
          ),
        ],
      ),
    );
    return ColoredBox(
      color: PublicEditorialColors.noir,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: mobile
              ? Column(
                  children: [
                    SizedBox(height: 390, width: double.infinity, child: photo),
                    copy,
                  ],
                )
              : SizedBox(
                  height: 850,
                  child: Row(
                    children: [
                      Expanded(flex: 7, child: photo),
                      Expanded(flex: 5, child: copy),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _AudienceAndMaterials extends StatelessWidget {
  const _AudienceAndMaterials({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final audience = course.targetAudience.isEmpty
        ? ['Para quem deseja desenvolver a técnica apresentada neste curso.']
        : course.targetAudience;
    final materials = <String>[
      ...course.requirements,
      ...course.requiredMaterials,
    ];
    final mobile = MediaQuery.sizeOf(context).width < 800;
    return _IvorySection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANTES DE COMEÇAR',
            style: PublicEditorialTypography.eyebrow(
              color: PublicEditorialColors.wine,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Seu ponto de partida.',
            style: PublicEditorialTypography.sectionDisplay(
              color: PublicEditorialColors.ink,
              size: mobile ? 54 : 82,
            ),
          ),
          if (course.prerequisiteCourses.isNotEmpty) ...[
            const SizedBox(height: 34),
            _PrerequisiteCourses(courses: course.prerequisiteCourses),
          ],
          const SizedBox(height: 46),
          Flex(
            direction: mobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: mobile ? 0 : 1,
                child: _EditorialList(title: 'Para quem é', items: audience),
              ),
              SizedBox(width: mobile ? 0 : 70, height: mobile ? 46 : 0),
              Expanded(
                flex: mobile ? 0 : 1,
                child: _EditorialList(
                  title: 'O que você precisa',
                  items: materials.isEmpty
                      ? const ['Nenhum material adicional foi informado.']
                      : materials,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrerequisiteCourses extends StatelessWidget {
  const _PrerequisiteCourses({required this.courses});

  final List<CoursePrerequisite> courses;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: PublicEditorialColors.wine.withValues(alpha: .06),
      border: Border.all(
        color: PublicEditorialColors.wine.withValues(alpha: .24),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURSOS OBRIGATÓRIOS ANTERIORES',
          style: PublicEditorialTypography.eyebrow(
            color: PublicEditorialColors.wine,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Conclua estas formações antes de iniciar este curso:',
          style: TextStyle(color: PublicEditorialColors.mutedInk),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: courses
              .map(
                (course) => ActionChip(
                  avatar: const Icon(
                    Icons.school_outlined,
                    size: 18,
                    color: PublicEditorialColors.wine,
                  ),
                  label: Text(course.title),
                  tooltip: 'Abrir ${course.title}',
                  onPressed: course.slug.isEmpty
                      ? null
                      : () => context.go('/courses/${course.slug}'),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}

class _EditorialList extends StatelessWidget {
  const _EditorialList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(34),
    decoration: BoxDecoration(
      color: PublicEditorialColors.white.withValues(alpha: .42),
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
        const SizedBox(height: 24),
        for (final item in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 7),
                child: Icon(
                  Icons.circle,
                  size: 6,
                  color: PublicEditorialColors.antiqueGold,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  item,
                  style: PublicEditorialTypography.body(
                    color: PublicEditorialColors.mutedInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ],
    ),
  );
}

class _CourseFaq extends StatelessWidget {
  const _CourseFaq({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      (
        'Como funciona o acesso?',
        course.isFree
            ? 'Entre na sua conta para liberar o acesso gratuito ao curso.'
            : 'A assinatura é individual para este curso e o acesso é liberado após a confirmação do pagamento.',
      ),
      (
        'Preciso ter experiência?',
        course.requirements.isEmpty && course.prerequisiteCourses.isEmpty
            ? 'Nenhum conhecimento prévio foi informado como obrigatório para esta formação.'
            : 'Consulte os conhecimentos e cursos obrigatórios desta página antes de começar.',
      ),
      (
        'O curso oferece certificado?',
        course.certificateEnabled
            ? 'Sim. O certificado é emitido conforme os critérios de conclusão do curso.'
            : 'Este curso não informa emissão de certificado.',
      ),
    ];
    return ColoredBox(
      color: PublicEditorialColors.parchment,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 112),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'PERGUNTAS FREQUENTES',
                  textAlign: TextAlign.center,
                  style: PublicEditorialTypography.eyebrow(
                    color: PublicEditorialColors.wine,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Antes de entrar no ateliê.',
                  textAlign: TextAlign.center,
                  style: PublicEditorialTypography.sectionDisplay(
                    color: PublicEditorialColors.ink,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 42),
                for (final item in items)
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      splashColor: PublicEditorialColors.wine.withValues(
                        alpha: .08,
                      ),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 10,
                      ),
                      childrenPadding: const EdgeInsets.only(bottom: 24),
                      iconColor: PublicEditorialColors.wine,
                      collapsedIconColor: PublicEditorialColors.wine,
                      shape: Border(
                        bottom: BorderSide(
                          color: PublicEditorialColors.ink.withValues(
                            alpha: .18,
                          ),
                        ),
                      ),
                      collapsedShape: Border(
                        bottom: BorderSide(
                          color: PublicEditorialColors.ink.withValues(
                            alpha: .18,
                          ),
                        ),
                      ),
                      title: Text(
                        item.$1,
                        style: PublicEditorialTypography.bodyLarge(
                          color: PublicEditorialColors.ink,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.$2,
                            style: PublicEditorialTypography.body(
                              color: PublicEditorialColors.mutedInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IvorySection extends StatelessWidget {
  const _IvorySection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return ColoredBox(
      color: PublicEditorialColors.ivory,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width < 700 ? 24 : 72,
              vertical: width < 700 ? 92 : 136,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

String _courseImage(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('model') || normalized.contains('moulage')) {
    return 'assets/images/couture_draping_portrait.webp';
  }
  return 'assets/images/couture_pattern_table.webp';
}

String _formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final remaining = minutes % 60;
  if (hours == 0) return '$remaining min';
  if (remaining == 0) return '${hours}h';
  return '${hours}h ${remaining}min';
}

String _humanize(String value) {
  final normalized = value.toLowerCase();
  if (normalized == 'intermediario') return 'Intermediário';
  if (normalized == 'avancado') return 'Avançado';
  if (normalized.isEmpty) return 'Todos os níveis';
  return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
}

String _categoryLabel(String value) => value
    .replaceAll('_', ' ')
    .split(' ')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
    .join(' ');
