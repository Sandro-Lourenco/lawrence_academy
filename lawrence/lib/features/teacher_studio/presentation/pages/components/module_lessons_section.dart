import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../courses/domain/entities/course.dart';

class ModuleLessonsSection extends StatelessWidget {
  const ModuleLessonsSection({
    super.key,
    required this.module,
    required this.isBusy,
    required this.onAddLesson,
    required this.onEditLesson,
    required this.onReplaceVideo,
    required this.onDeleteLesson,
    required this.onEditModule,
    required this.onDeleteModule,
  });

  final Module module;
  final bool isBusy;
  final VoidCallback onAddLesson;
  final ValueChanged<Lesson> onEditLesson;
  final ValueChanged<Lesson> onReplaceVideo;
  final ValueChanged<Lesson> onDeleteLesson;
  final VoidCallback onEditModule;
  final VoidCallback onDeleteModule;

  @override
  Widget build(BuildContext context) {
    final lessons = [...module.lessons]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: LawrenceColors.canvas,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusLg),
          side: const BorderSide(color: LawrenceColors.borderMist),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: LawrenceColors.primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
              ),
              child: Text(
                '${module.orderIndex + 1}',
                style: const TextStyle(
                  color: LawrenceColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(
              module.title,
              style: const TextStyle(
                color: LawrenceColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              lessons.isEmpty
                  ? 'Nenhuma aula criada'
                  : '${lessons.length} ${lessons.length == 1 ? 'aula' : 'aulas'}',
              style: const TextStyle(color: LawrenceColors.textSecondary),
            ),
            trailing: PopupMenuButton<String>(
              tooltip: 'Ações do módulo ${module.title}',
              onSelected: (value) {
                if (value == 'edit') onEditModule();
                if (value == 'delete') onDeleteModule();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar módulo')),
                PopupMenuItem(value: 'delete', child: Text('Arquivar módulo')),
              ],
            ),
            children: [
              if (lessons.isEmpty)
                _EmptyLessons(onAddLesson: isBusy ? null : onAddLesson)
              else ...[
                for (var index = 0; index < lessons.length; index++)
                  _LessonRow(
                    lesson: lessons[index],
                    displayNumber: index + 1,
                    enabled: !isBusy,
                    onEdit: () => onEditLesson(lessons[index]),
                    onReplaceVideo: () => onReplaceVideo(lessons[index]),
                    onDelete: () => onDeleteLesson(lessons[index]),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onAddLesson,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Adicionar outra aula'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.displayNumber,
    required this.enabled,
    required this.onEdit,
    required this.onReplaceVideo,
    required this.onDelete,
  });

  final Lesson lesson;
  final int displayNumber;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onReplaceVideo;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasVideo = lesson.hlsStoragePath != null;
    return Semantics(
      container: true,
      label: 'Aula $displayNumber, ${lesson.title}, status ${lesson.status}',
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        decoration: BoxDecoration(
          color: LawrenceColors.canvasParchment,
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: LawrenceColors.textPrimary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$displayNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: LawrenceColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _StatusLabel(
                        icon: hasVideo
                            ? Icons.check_circle_outline
                            : Icons.schedule_outlined,
                        label: hasVideo ? 'Vídeo pronto' : 'Vídeo pendente',
                        color: hasVideo
                            ? LawrenceColors.success
                            : LawrenceColors.warning,
                      ),
                      _StatusLabel(
                        icon: lesson.status == 'published'
                            ? Icons.visibility_outlined
                            : Icons.edit_note_outlined,
                        label: lesson.status == 'published'
                            ? 'Publicada'
                            : 'Rascunho',
                        color: LawrenceColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              enabled: enabled,
              tooltip: 'Ações da aula ${lesson.title}',
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'video') onReplaceVideo();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar aula'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'video',
                  child: ListTile(
                    leading: Icon(Icons.video_file_outlined),
                    title: Text('Trocar vídeo'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.archive_outlined,
                      color: LawrenceColors.danger,
                    ),
                    title: Text('Arquivar aula'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class _EmptyLessons extends StatelessWidget {
  const _EmptyLessons({required this.onAddLesson});

  final VoidCallback? onAddLesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LawrenceColors.canvasParchment,
        borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.playlist_add_outlined,
            color: LawrenceColors.primary,
            size: 36,
          ),
          const SizedBox(height: 12),
          const Text(
            'Este módulo ainda não possui aulas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LawrenceColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Crie a Aula 01 para começar a organizar o conteúdo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: LawrenceColors.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAddLesson,
            icon: const Icon(Icons.add),
            label: const Text('Criar primeira aula'),
          ),
        ],
      ),
    );
  }
}
