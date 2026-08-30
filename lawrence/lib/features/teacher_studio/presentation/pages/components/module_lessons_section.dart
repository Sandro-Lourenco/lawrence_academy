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
    required this.onEditLessonContent,
    required this.onReplaceVideo,
    required this.onDeleteLesson,
    required this.onEditModule,
    required this.onDeleteModule,
    required this.onMoveModuleUp,
    required this.onMoveModuleDown,
    required this.canMoveModuleUp,
    required this.canMoveModuleDown,
    required this.onMoveLessonUp,
    required this.onMoveLessonDown,
    required this.onMoveLessonToModule,
    required this.onReorderLessons,
    this.isQuickCourse = false,
  });

  final Module module;
  final bool isBusy;
  final VoidCallback onAddLesson;
  final ValueChanged<Lesson> onEditLesson;
  final ValueChanged<Lesson> onEditLessonContent;
  final ValueChanged<Lesson> onReplaceVideo;
  final ValueChanged<Lesson> onDeleteLesson;
  final VoidCallback onEditModule;
  final VoidCallback onDeleteModule;
  final VoidCallback onMoveModuleUp;
  final VoidCallback onMoveModuleDown;
  final bool canMoveModuleUp;
  final bool canMoveModuleDown;
  final ValueChanged<Lesson> onMoveLessonUp;
  final ValueChanged<Lesson> onMoveLessonDown;
  final ValueChanged<Lesson> onMoveLessonToModule;
  final void Function(int oldIndex, int newIndex) onReorderLessons;
  final bool isQuickCourse;

  @override
  Widget build(BuildContext context) {
    final lessons = [...module.lessons]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: LawrenceColors.surfaceTile2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusLg),
          side: const BorderSide(color: LawrenceColors.darkAction),
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
                color: LawrenceColors.goldMid.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
              ),
              child: isQuickCourse
                  ? const Icon(Icons.bolt, color: LawrenceColors.goldHighlight)
                  : Text(
                      '${module.orderIndex + 1}',
                      style: const TextStyle(
                        color: LawrenceColors.goldHighlight,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            title: Text(
              isQuickCourse ? 'Aulas' : module.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (module.description.isNotEmpty)
                  Text(
                    module.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  lessons.isEmpty
                      ? 'Nenhuma aula criada'
                      : '${lessons.length} ${lessons.length == 1 ? 'aula' : 'aulas'} • ${module.status == 'ready' ? 'Pronto para revisão' : 'Em construção'}',
                  style: const TextStyle(color: Color(0xFFB8C1DD)),
                ),
              ],
            ),
            trailing: isQuickCourse
                ? null
                : PopupMenuButton<String>(
                    tooltip: 'Ações do módulo ${module.title}',
                    iconColor: Colors.white,
                    enableFeedback: true,
                    onSelected: (value) {
                      if (value == 'edit') onEditModule();
                      if (value == 'up') onMoveModuleUp();
                      if (value == 'down') onMoveModuleDown();
                      if (value == 'delete') onDeleteModule();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar módulo'),
                      ),
                      PopupMenuItem(
                        value: 'up',
                        enabled: canMoveModuleUp,
                        child: const Text('Mover módulo para cima'),
                      ),
                      PopupMenuItem(
                        value: 'down',
                        enabled: canMoveModuleDown,
                        child: const Text('Mover módulo para baixo'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Arquivar módulo'),
                      ),
                    ],
                  ),
            children: [
              if (lessons.isEmpty)
                _EmptyLessons(onAddLesson: isBusy ? null : onAddLesson)
              else ...[
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: lessons.length,
                  onReorder: isBusy ? (_, _) {} : onReorderLessons,
                  proxyDecorator: (child, index, animation) => Material(
                    color: Colors.transparent,
                    elevation: 10,
                    borderRadius: BorderRadius.circular(16),
                    child: child,
                  ),
                  itemBuilder: (context, index) => _LessonRow(
                    key: ValueKey(lessons[index].id),
                    lesson: lessons[index],
                    displayNumber: index + 1,
                    enabled: !isBusy,
                    onEdit: () => onEditLesson(lessons[index]),
                    onEditContent: () => onEditLessonContent(lessons[index]),
                    onReplaceVideo: () => onReplaceVideo(lessons[index]),
                    onDelete: () => onDeleteLesson(lessons[index]),
                    onMoveUp: () => onMoveLessonUp(lessons[index]),
                    onMoveDown: () => onMoveLessonDown(lessons[index]),
                    canMoveUp: index > 0,
                    canMoveDown: index < lessons.length - 1,
                    onMoveToModule: () => onMoveLessonToModule(lessons[index]),
                    canMoveToModule: !isQuickCourse,
                  ),
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
    super.key,
    required this.lesson,
    required this.displayNumber,
    required this.enabled,
    required this.onEdit,
    required this.onEditContent,
    required this.onReplaceVideo,
    required this.onDelete,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveToModule,
    required this.canMoveToModule,
  });

  final Lesson lesson;
  final int displayNumber;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onEditContent;
  final VoidCallback onReplaceVideo;
  final VoidCallback onDelete;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveToModule;
  final bool canMoveToModule;

  @override
  Widget build(BuildContext context) {
    final videoStatus = _LessonVideoStatus.fromLesson(lesson);
    return Semantics(
      container: true,
      label: 'Aula $displayNumber, ${lesson.title}, status ${lesson.status}',
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        decoration: BoxDecoration(
          color: const Color(0x99181315),
          borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
          border: Border.all(
            color: videoStatus.isFailed
                ? LawrenceColors.danger.withValues(alpha: .45)
                : const Color(0x406B4A55),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A10264F),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: LawrenceColors.goldMid,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$displayNumber',
                style: const TextStyle(
                  color: LawrenceColors.brandNavy,
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
                      color: Colors.white,
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
                        icon: videoStatus.icon,
                        label: videoStatus.label,
                        color: videoStatus.color,
                      ),
                      if (lesson.durationSeconds > 0 ||
                          lesson.estimatedDurationMinutes != null)
                        _StatusLabel(
                          icon: Icons.timer_outlined,
                          label: lesson.durationSeconds > 0
                              ? '${(lesson.durationSeconds / 60).ceil()} min reais'
                              : '${lesson.estimatedDurationMinutes} min estimados',
                          color: Color(0xFFC7D0DF),
                        ),
                      _StatusLabel(
                        icon: lesson.isRequired
                            ? Icons.assignment_turned_in_outlined
                            : Icons.low_priority,
                        label: lesson.isRequired ? 'Obrigatória' : 'Opcional',
                        color: Color(0xFFC7D0DF),
                      ),
                      _StatusLabel(
                        icon: lesson.status == 'published'
                            ? Icons.visibility_outlined
                            : Icons.edit_note_outlined,
                        label: lesson.status == 'published'
                            ? 'Pronta'
                            : 'Rascunho',
                        color: Color(0xFFC7D0DF),
                      ),
                    ],
                  ),
                  if (videoStatus.isFailed) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: enabled ? onReplaceVideo : null,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Enviar vídeo novamente'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: LawrenceColors.danger,
                        side: const BorderSide(color: LawrenceColors.danger),
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              enabled: enabled,
              tooltip: 'Ações da aula ${lesson.title}',
              icon: Icon(
                Icons.more_vert_rounded,
                color: enabled ? Colors.white : const Color(0xFF8993A8),
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'content') onEditContent();
                if (value == 'video') onReplaceVideo();
                if (value == 'up') onMoveUp();
                if (value == 'down') onMoveDown();
                if (value == 'module') onMoveToModule();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'content',
                  child: ListTile(
                    leading: Icon(Icons.view_agenda_outlined),
                    title: Text('Editar conteúdo'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar aula'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'up',
                  enabled: canMoveUp,
                  child: const ListTile(
                    leading: Icon(Icons.arrow_upward),
                    title: Text('Mover para cima'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'down',
                  enabled: canMoveDown,
                  child: const ListTile(
                    leading: Icon(Icons.arrow_downward),
                    title: Text('Mover para baixo'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (canMoveToModule)
                  const PopupMenuItem(
                    value: 'module',
                    child: ListTile(
                      leading: Icon(Icons.drive_file_move_outline),
                      title: Text('Mover para outro módulo'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'video',
                  child: ListTile(
                    leading: Icon(Icons.video_file_outlined),
                    title: Text('Trocar ou reenviar vídeo'),
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

class _LessonVideoStatus {
  const _LessonVideoStatus(
    this.label,
    this.icon,
    this.color, {
    this.isFailed = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isFailed;

  factory _LessonVideoStatus.fromLesson(Lesson lesson) {
    final jobStatus = lesson.videoJobStatus;
    final hasCurrentExternal = const {
      'youtube',
      'vimeo',
    }.contains(lesson.videoSourceType);
    if (const {
      'upload_pending',
      'uploaded',
      'processing_pending',
      'processing',
      'validating',
      'transcoding',
      'generating_hls',
      'generating_thumbnail',
    }.contains(jobStatus)) {
      return _LessonVideoStatus(
        hasCurrentExternal
            ? 'Novo upload processando · link atual mantido'
            : jobStatus == 'upload_pending'
            ? 'Aguardando envio'
            : jobStatus == 'uploaded' || jobStatus == 'processing_pending'
            ? 'Na fila de processamento'
            : 'Processando vídeo',
        jobStatus == 'upload_pending'
            ? Icons.cloud_upload_outlined
            : jobStatus == 'uploaded' || jobStatus == 'processing_pending'
            ? Icons.schedule_outlined
            : Icons.autorenew,
        jobStatus == 'processing' ||
                jobStatus == 'validating' ||
                jobStatus == 'transcoding' ||
                jobStatus == 'generating_hls' ||
                jobStatus == 'generating_thumbnail'
            ? LawrenceColors.primary
            : LawrenceColors.warning,
      );
    }
    if (const {'failed', 'dead_letter'}.contains(jobStatus)) {
      return _LessonVideoStatus(
        hasCurrentExternal
            ? 'Falha no novo upload · link atual mantido'
            : 'Falha — envie novamente',
        Icons.error_outline,
        LawrenceColors.danger,
        isFailed: true,
      );
    }
    if (const {'youtube', 'vimeo'}.contains(lesson.videoSourceType)) {
      return _LessonVideoStatus(
        lesson.videoSourceType == 'youtube'
            ? 'Link do YouTube'
            : 'Link do Vimeo',
        Icons.link_outlined,
        LawrenceColors.success,
      );
    }
    if (lesson.hlsStoragePath?.isNotEmpty == true) {
      return const _LessonVideoStatus(
        'Vídeo pronto',
        Icons.check_circle_outline,
        LawrenceColors.success,
      );
    }
    return const _LessonVideoStatus(
      'Sem vídeo',
      Icons.videocam_off_outlined,
      LawrenceColors.textSecondary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(LawrenceRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
        color: const Color(0x99181315),
        borderRadius: BorderRadius.circular(LawrenceTheme.radiusMd),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.playlist_add_outlined,
            color: Color(0xFFA63B5E),
            size: 36,
          ),
          const SizedBox(height: 12),
          const Text(
            'Este módulo ainda não possui aulas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Crie a Aula 01 para começar a organizar o conteúdo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFB8C1DD)),
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
