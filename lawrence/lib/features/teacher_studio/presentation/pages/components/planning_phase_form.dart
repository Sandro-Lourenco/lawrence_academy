import 'package:flutter/material.dart';
import '../../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../courses/domain/entities/course.dart';

/// Formulário enxuto: campos técnicos são derivados no backend.
class PlanningPhaseForm extends StatelessWidget {
  const PlanningPhaseForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.slugController,
    required this.summaryController,
    required this.subtitleController,
    required this.descriptionController,
    required this.requirementsController,
    required this.durationController,
    required this.learningObjectivesController,
    required this.targetAudienceController,
    required this.requiredMaterialsController,
    required this.competenciesController,
    required this.expectedOutcomesController,
    required this.category,
    required this.level,
    required this.courseType,
    required this.language,
    required this.prerequisiteCourseOptions,
    required this.selectedPrerequisiteCourseIds,
    required this.isSaving,
    required this.onChanged,
    required this.onCategoryChanged,
    required this.onLevelChanged,
    required this.onCourseTypeChanged,
    required this.onLanguageChanged,
    required this.onPrerequisiteCourseToggled,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController,
      slugController,
      summaryController,
      subtitleController,
      descriptionController,
      requirementsController,
      durationController,
      learningObjectivesController,
      targetAudienceController,
      requiredMaterialsController,
      competenciesController,
      expectedOutcomesController;
  final String category, level, courseType, language;
  final List<Course> prerequisiteCourseOptions;
  final Set<String> selectedPrerequisiteCourseIds;
  final bool isSaving;
  final VoidCallback onChanged, onSave;
  final ValueChanged<String> onCategoryChanged,
      onLevelChanged,
      onCourseTypeChanged,
      onLanguageChanged;
  final void Function(String courseId, bool selected)
  onPrerequisiteCourseToggled;

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: LawrenceColors.darkSurface,
        labelStyle: TextStyle(color: LawrenceColors.darkTextSecondary),
        helperStyle: TextStyle(color: LawrenceColors.darkTextSecondary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: LawrenceColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: LawrenceColors.darkAction, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: LawrenceColors.danger),
        ),
      ),
    ),
    child: Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.all(LawrenceSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [LawrenceColors.surfaceTile2, LawrenceColors.darkSurface],
          ),
          border: Border.all(color: LawrenceColors.darkAction),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do curso',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Preencha somente o essencial. Endereço e resumo serão gerados automaticamente.',
              style: TextStyle(color: LawrenceColors.darkTextSecondary),
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'complete',
                  icon: Icon(Icons.view_module_outlined),
                  label: Text('Completo'),
                ),
                ButtonSegment(
                  value: 'quick',
                  icon: Icon(Icons.bolt_outlined),
                  label: Text('Rápido'),
                ),
                ButtonSegment(
                  value: 'workshop',
                  icon: Icon(Icons.handyman_outlined),
                  label: Text('Workshop'),
                ),
              ],
              selected: {courseType},
              onSelectionChanged: (selection) =>
                  onCourseTypeChanged(selection.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.white
                      : LawrenceColors.darkTextSecondary,
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? LawrenceColors.actionPrimary
                      : LawrenceColors.darkSurface,
                ),
              ),
            ),
            if (courseType == 'quick') ...[
              const SizedBox(height: 12),
              const _QuickNotice(),
            ],
            const SizedBox(height: LawrenceSpacing.lg),
            _field(
              titleController,
              'Título',
              onChanged,
              validator: (value) => (value?.trim().length ?? 0) < 3
                  ? 'Informe ao menos 3 caracteres.'
                  : null,
              maxLength: 120,
            ),
            const SizedBox(height: LawrenceSpacing.md),
            _field(
              descriptionController,
              'Descrição',
              onChanged,
              validator: (value) => (value?.trim().length ?? 0) < 10
                  ? 'Informe ao menos 10 caracteres.'
                  : null,
              maxLength: 5000,
              minLines: 4,
              maxLines: 7,
            ),
            const SizedBox(height: LawrenceSpacing.md),
            DropdownButtonFormField<String>(
              initialValue:
                  const {
                    'costura',
                    'modelagem',
                    'bordado',
                    'negocios',
                    'outros',
                  }.contains(category)
                  ? category
                  : 'outros',
              dropdownColor: LawrenceColors.darkElevated,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: const [
                DropdownMenuItem(value: 'costura', child: Text('Costura')),
                DropdownMenuItem(value: 'modelagem', child: Text('Modelagem')),
                DropdownMenuItem(value: 'bordado', child: Text('Bordado')),
                DropdownMenuItem(value: 'negocios', child: Text('Negócios')),
                DropdownMenuItem(value: 'outros', child: Text('Outros')),
              ],
              onChanged: (value) {
                if (value != null) onCategoryChanged(value);
              },
            ),
            const SizedBox(height: LawrenceSpacing.md),
            _field(
              requirementsController,
              'Conhecimentos prévios',
              onChanged,
              helper:
                  'Informe conhecimentos ou habilidades, um item por linha.',
              validator: _listValidator,
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: LawrenceSpacing.md),
            _CoursePrerequisiteSelector(
              courses: prerequisiteCourseOptions,
              selectedIds: selectedPrerequisiteCourseIds,
              onToggled: onPrerequisiteCourseToggled,
            ),
            const SizedBox(height: LawrenceSpacing.md),
            _field(
              requiredMaterialsController,
              'Materiais necessários',
              onChanged,
              helper: 'Um item por linha. Se não houver, deixe vazio.',
              validator: _listValidator,
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: isSaving ? null : onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: LawrenceColors.actionPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(
                    MediaQuery.sizeOf(context).width <
                            LawrenceBreakpoints.tablet
                        ? double.infinity
                        : 210,
                    52,
                  ),
                ),
                icon: isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_forward),
                label: Text(isSaving ? 'Salvando…' : 'Salvar e continuar'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  static Widget _field(
    TextEditingController controller,
    String label,
    VoidCallback changed, {
    String? helper,
    String? Function(String?)? validator,
    int? maxLength,
    int minLines = 1,
    int maxLines = 1,
  }) => TextFormField(
    controller: controller,
    style: const TextStyle(color: Colors.white),
    maxLength: maxLength,
    minLines: minLines,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      alignLabelWithHint: minLines > 1,
    ),
    onChanged: (_) => changed(),
    validator: validator,
  );

  static String? _listValidator(String? value) {
    final items = (value ?? '')
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (items.length > 20) return 'Use no máximo 20 itens.';
    if (items.any((item) => item.length < 2 || item.length > 240)) {
      return 'Cada item deve ter entre 2 e 240 caracteres.';
    }
    return null;
  }
}

class _CoursePrerequisiteSelector extends StatelessWidget {
  const _CoursePrerequisiteSelector({
    required this.courses,
    required this.selectedIds,
    required this.onToggled,
  });

  final List<Course> courses;
  final Set<String> selectedIds;
  final void Function(String courseId, bool selected) onToggled;

  @override
  Widget build(BuildContext context) {
    final sortedCourses = [...courses]
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return Semantics(
      container: true,
      label: 'Cursos obrigatórios anteriores',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LawrenceColors.darkSurface,
          border: Border.all(color: LawrenceColors.darkBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cursos que precisam ser concluídos antes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecione cursos publicados. O aluno só poderá avançar depois de concluí-los.',
              style: TextStyle(color: LawrenceColors.darkTextSecondary),
            ),
            const SizedBox(height: 12),
            if (sortedCourses.isEmpty)
              const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: LawrenceColors.darkTextSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nenhum outro curso publicado está disponível.',
                      style: TextStyle(color: LawrenceColors.darkTextSecondary),
                    ),
                  ),
                ],
              )
            else
              ...sortedCourses.map((course) {
                final selected = selectedIds.contains(course.id);
                final published = course.status == 'published';
                return Material(
                  type: MaterialType.transparency,
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: published || selected
                        ? (value) => onToggled(course.id, value ?? false)
                        : null,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: LawrenceColors.actionPrimary,
                    checkColor: Colors.white,
                    title: Text(
                      course.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${_categoryLabel(course.category)} · '
                      '${published ? 'Curso publicado' : 'Remova: curso não publicado'}',
                      style: const TextStyle(
                        color: LawrenceColors.darkTextSecondary,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  static String _categoryLabel(String value) => switch (value) {
    'costura' => 'Costura',
    'modelagem' => 'Modelagem',
    'bordado' => 'Bordado',
    'negocios' => 'Negócios',
    _ => 'Outros',
  };
}

class _QuickNotice extends StatelessWidget {
  const _QuickNotice();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: LawrenceColors.actionPrimary.withValues(alpha: .22),
      border: Border.all(color: LawrenceColors.darkAction),
    ),
    child: const Row(
      children: [
        Icon(Icons.bolt, color: LawrenceColors.goldHighlight),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Curso rápido não possui módulos. Adicione aulas diretamente e escolha preço, upload ou link de vídeo nas próximas etapas.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
