import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({super.key, required this.course});

  final Course course;

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final price = course.isFree
        ? 'Gratuito'
        : 'R\$ ${course.monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')} por mês';
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      label:
          '${course.title}. Nível ${course.level}. ${course.lessonCount} aulas. $price. Abrir detalhes.',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          focusColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: .12),
          hoverColor: Colors.transparent,
          splashColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: .10),
          onFocusChange: (value) => setState(() => _focused = value),
          onHighlightChanged: (value) => setState(() => _pressed = value),
          onTap: () => context.go('/dashboard/courses/${course.id}'),
          child: AnimatedScale(
            scale: reduceMotion
                ? 1
                : _pressed
                ? .985
                : _hovered
                ? 1.01
                : 1,
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            child: AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(LawrenceRadii.card),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(LawrenceRadii.card),
                border: Border.all(
                  color: _hovered || _focused
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .72)
                      : LawrenceColors.borderMist,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(LawrenceRadii.card),
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 152,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _categoryImage(course.category),
                              fit: BoxFit.cover,
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0x9917283B),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: LawrenceSpacing.md,
                              bottom: LawrenceSpacing.sm,
                              child: Icon(
                                _categoryIcon(course.category),
                                size: 28,
                                color: LawrenceColors.darkTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(LawrenceSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppStatusBadge(
                              label: course.isFree
                                  ? 'Gratuito'
                                  : 'Assinatura mensal',
                              icon: course.isFree
                                  ? Icons.lock_open_rounded
                                  : Icons.autorenew_rounded,
                              tone: course.isFree
                                  ? AppStatusTone.success
                                  : AppStatusTone.info,
                            ),
                            const SizedBox(height: LawrenceSpacing.sm),
                            Text(
                              course.category.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                letterSpacing: .8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: LawrenceSpacing.xs),
                            Text(
                              course.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: LawrenceSpacing.sm),
                            Text(
                              course.summary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: LawrenceSpacing.md),
                            Wrap(
                              spacing: LawrenceSpacing.md,
                              runSpacing: LawrenceSpacing.xs,
                              children: [
                                _Metadata(
                                  icon: Icons.signal_cellular_alt_rounded,
                                  label: course.level,
                                ),
                                _Metadata(
                                  icon: Icons.play_lesson_outlined,
                                  label: '${course.lessonCount} aulas',
                                ),
                              ],
                            ),
                            const SizedBox(height: LawrenceSpacing.md),
                            Text(
                              price,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(minHeight: 56),
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .08),
                        padding: const EdgeInsets.symmetric(
                          horizontal: LawrenceSpacing.md,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'VER CURSO',
                              style: TextStyle(
                                color: LawrenceColors.actionPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .7,
                              ),
                            ),
                            SizedBox(width: LawrenceSpacing.xs),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: LawrenceColors.actionPrimary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final value = category.toLowerCase();
    if (value.contains('model')) return Icons.architecture_outlined;
    if (value.contains('bord')) return Icons.auto_awesome_outlined;
    if (value.contains('costur')) return Icons.content_cut_outlined;
    return Icons.school_outlined;
  }

  String _categoryImage(String category) {
    final value = category.toLowerCase();
    if (value.contains('model') || value.contains('moulage')) {
      return 'assets/images/couture_draping_portrait.webp';
    }
    if (value.contains('costur') || value.contains('medid')) {
      return 'assets/images/couture_pattern_table.webp';
    }
    return 'assets/images/couture_atelier_hero.webp';
  }
}

class _Metadata extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Metadata({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: LawrenceSpacing.xs),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
