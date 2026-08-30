import 'package:flutter/material.dart';

import '../../../../../design_system/public/public_editorial_colors.dart';
import '../../../../../design_system/public/public_editorial_typography.dart';
import '../../../domain/entities/course.dart';

class PublicCourseCurriculum extends StatelessWidget {
  const PublicCourseCurriculum({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 800;
    return ColoredBox(
      color: PublicEditorialColors.ivory,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 24 : 72,
              vertical: mobile ? 94 : 138,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROGRAMA DO CURSO',
                  style: PublicEditorialTypography.eyebrow(
                    color: PublicEditorialColors.wine,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'O percurso, página por página.',
                        style: PublicEditorialTypography.sectionDisplay(
                          color: PublicEditorialColors.ink,
                          size: mobile ? 54 : 82,
                        ),
                      ),
                    ),
                    if (!mobile)
                      Text(
                        '${course.modules.length} ${course.modules.length == 1 ? 'módulo' : 'módulos'} · ${course.lessonCount} ${course.lessonCount == 1 ? 'aula' : 'aulas'}',
                        style: PublicEditorialTypography.caption(
                          color: PublicEditorialColors.mutedInk,
                        ),
                      ),
                  ],
                ),
                if (mobile) ...[
                  const SizedBox(height: 14),
                  Text(
                    '${course.modules.length} ${course.modules.length == 1 ? 'módulo' : 'módulos'} · ${course.lessonCount} ${course.lessonCount == 1 ? 'aula' : 'aulas'}',
                    style: PublicEditorialTypography.caption(
                      color: PublicEditorialColors.mutedInk,
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                if (course.modules.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(38),
                    decoration: BoxDecoration(
                      color: PublicEditorialColors.parchment.withValues(
                        alpha: .45,
                      ),
                      border: Border.all(
                        color: PublicEditorialColors.ink.withValues(alpha: .16),
                      ),
                    ),
                    child: Text(
                      'O currículo deste curso ainda não foi publicado.',
                      style: PublicEditorialTypography.body(
                        color: PublicEditorialColors.mutedInk,
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: PublicEditorialColors.ink.withValues(
                            alpha: .24,
                          ),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < course.modules.length;
                          index++
                        )
                          _ModuleTile(
                            index: index,
                            module: course.modules[index],
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

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.index, required this.module});

  final int index;
  final Module module;

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(vertical: 18),
      childrenPadding: const EdgeInsets.only(left: 62, bottom: 24),
      iconColor: PublicEditorialColors.wine,
      collapsedIconColor: PublicEditorialColors.wine,
      shape: Border(
        bottom: BorderSide(
          color: PublicEditorialColors.ink.withValues(alpha: .20),
        ),
      ),
      collapsedShape: Border(
        bottom: BorderSide(
          color: PublicEditorialColors.ink.withValues(alpha: .20),
        ),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: PublicEditorialTypography.eyebrow(
                color: PublicEditorialColors.wine,
              ),
            ),
          ),
          Expanded(
            child: Text(
              module.title,
              style: PublicEditorialTypography.courseTitle(
                color: PublicEditorialColors.ink,
              ).copyWith(fontSize: 34),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 58, top: 6),
        child: Text(
          '${module.lessons.length} ${module.lessons.length == 1 ? 'aula' : 'aulas'}',
          style: PublicEditorialTypography.caption(
            color: PublicEditorialColors.mutedInk,
          ),
        ),
      ),
      children: [
        for (
          var lessonIndex = 0;
          lessonIndex < module.lessons.length;
          lessonIndex++
        )
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 17,
                  color: PublicEditorialColors.antiqueGold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    module.lessons[lessonIndex].title,
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
  );
}
