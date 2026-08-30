import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/motion/public_motion.dart';
import '../../../../../design_system/public/public_editorial_colors.dart';
import '../../../../../design_system/public/public_editorial_typography.dart';
import '../../../domain/entities/course.dart';

class PublicCourseCard extends StatefulWidget {
  const PublicCourseCard({super.key, required this.course});

  final Course course;

  @override
  State<PublicCourseCard> createState() => _PublicCourseCardState();
}

class _PublicCourseCardState extends State<PublicCourseCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : PublicMotion.standard;
    final price = course.isFree
        ? 'Acesso gratuito'
        : 'R\$ ${course.monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')} / mês';
    final durationLabel = course.estimatedDurationMinutes == null
        ? '${course.lessonCount} aulas'
        : _formatDuration(course.estimatedDurationMinutes!);

    return Semantics(
      button: true,
      label:
          '${course.title}. Nível ${_humanize(course.level)}. $durationLabel. $price. Conhecer curso.',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: reduceMotion
              ? 1
              : _pressed
              ? PublicMotion.pressedScale
              : 1,
          duration: PublicMotion.fast,
          child: Material(
            color: PublicEditorialColors.white.withValues(alpha: .42),
            child: InkWell(
              onTap: () => context.go('/courses/${course.slug}'),
              onHighlightChanged: (value) => setState(() => _pressed = value),
              focusColor: PublicEditorialColors.wine.withValues(alpha: .12),
              hoverColor: Colors.transparent,
              child: AnimatedContainer(
                duration: duration,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _hovered
                        ? PublicEditorialColors.wine
                        : PublicEditorialColors.ink.withValues(alpha: .18),
                  ),
                  boxShadow: _hovered
                      ? [
                          BoxShadow(
                            color: PublicEditorialColors.ink.withValues(
                              alpha: .12,
                            ),
                            blurRadius: 26,
                            offset: const Offset(0, 12),
                          ),
                        ]
                      : const [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRect(
                        child: AnimatedScale(
                          scale: _hovered && !reduceMotion ? 1.025 : 1,
                          duration: duration,
                          curve: PublicMotion.entranceCurve,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                _categoryImage(course.category),
                                fit: BoxFit.cover,
                                semanticLabel:
                                    course.coverAltText ??
                                    'Imagem editorial do curso ${course.title}',
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color(0x991A0B10),
                                    ],
                                    stops: [.46, 1],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                bottom: 17,
                                child: Text(
                                  course.category.toUpperCase(),
                                  style: PublicEditorialTypography.eyebrow(
                                    color: PublicEditorialColors.ivory,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 14,
                              runSpacing: 8,
                              children: [
                                _Meta(label: _humanize(course.level)),
                                _Meta(label: durationLabel),
                                if (course.certificateEnabled)
                                  const _Meta(label: 'Certificado'),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              course.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: PublicEditorialTypography.courseTitle(
                                color: PublicEditorialColors.ink,
                              ).copyWith(fontSize: 34),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              course.summary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: PublicEditorialTypography.caption(
                                color: PublicEditorialColors.mutedInk,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    price,
                                    style:
                                        PublicEditorialTypography.buttonLabel(
                                          color: PublicEditorialColors.ink,
                                        ),
                                  ),
                                ),
                                AnimatedSlide(
                                  duration: duration,
                                  offset: _hovered
                                      ? const Offset(.16, 0)
                                      : Offset.zero,
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: PublicEditorialColors.wine,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: PublicEditorialColors.antiqueGold,
        ),
      ),
      const SizedBox(width: 7),
      Text(
        label,
        style: PublicEditorialTypography.caption(
          color: PublicEditorialColors.mutedInk,
        ).copyWith(fontSize: 13),
      ),
    ],
  );
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

String _humanize(String value) {
  if (value == 'intermediario') return 'Intermediário';
  if (value == 'avancado') return 'Avançado';
  if (value.isEmpty) return 'Todos os níveis';
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

String _formatDuration(int minutes) {
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  return '${hours}h de conteúdo';
}
