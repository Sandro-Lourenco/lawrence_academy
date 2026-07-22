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
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: () => context.go('/courses/${course.slug}'),
          child: AnimatedScale(
            scale: reduceMotion || !_pressed ? 1 : .98,
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 120),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 140,
                    color: LawrenceColors.surfaceSubtle,
                    alignment: Alignment.center,
                    child: ExcludeSemantics(
                      child: Icon(
                        _categoryIcon(course.category),
                        size: 52,
                        color: LawrenceColors.actionPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(LawrenceSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppStatusBadge(
                          label: course.isFree ? 'Gratuito' : 'Assinatura mensal',
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
                          style: const TextStyle(
                            color: LawrenceColors.actionPrimary,
                            fontSize: 12,
                            letterSpacing: .8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: LawrenceSpacing.xs),
                        Text(
                          course.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: LawrenceColors.brandNavy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: LawrenceSpacing.sm),
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
                          style: const TextStyle(
                            color: LawrenceColors.textPrimary,
                            fontWeight: FontWeight.w800,
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
        Icon(icon, size: 18, color: LawrenceColors.textSecondary),
        const SizedBox(width: LawrenceSpacing.xs),
        Text(label, style: const TextStyle(color: LawrenceColors.textSecondary)),
      ],
    );
  }
}
