import 'package:flutter/material.dart';

import '../../../../../design_system/tokens/lawrence_theme.dart';

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
    required this.isSaving,
    required this.onChanged,
    required this.onCategoryChanged,
    required this.onLevelChanged,
    required this.onCourseTypeChanged,
    required this.onLanguageChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController slugController;
  final TextEditingController summaryController;
  final TextEditingController subtitleController;
  final TextEditingController descriptionController;
  final TextEditingController requirementsController;
  final TextEditingController durationController;
  final TextEditingController learningObjectivesController;
  final TextEditingController targetAudienceController;
  final TextEditingController requiredMaterialsController;
  final TextEditingController competenciesController;
  final TextEditingController expectedOutcomesController;
  final String category;
  final String level;
  final String courseType;
  final String language;
  final bool isSaving;
  final VoidCallback onChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<String> onCourseTypeChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < LawrenceBreakpoints.tablet;
          return Container(
            padding: EdgeInsets.all(
              compact ? LawrenceSpacing.md : LawrenceSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: LawrenceColors.canvas,
              border: Border.all(color: LawrenceColors.borderMist),
              borderRadius: BorderRadius.circular(LawrenceRadii.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Planejamento do curso',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: LawrenceColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: LawrenceSpacing.xs),
                const Text(
                  'Fase 1 de 5 · Defina a proposta e as informações que identificam o curso.',
                  style: TextStyle(color: LawrenceColors.textSecondary),
                ),
                const SizedBox(height: LawrenceSpacing.lg),
                _CourseTypeSelector(
                  value: courseType,
                  onChanged: onCourseTypeChanged,
                  compact: compact,
                ),
                const SizedBox(height: LawrenceSpacing.xl),
                const _SectionTitle('Informações básicas'),
                const SizedBox(height: LawrenceSpacing.md),
                TextFormField(
                  controller: titleController,
                  textInputAction: TextInputAction.next,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Nome do curso',
                    hintText: 'Ex.: Modelagem feminina do básico ao vestido',
                    helperText: 'Use um nome claro que descreva o tema principal.',
                  ),
                  onChanged: (_) => onChanged(),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe o nome do curso.'
                      : null,
                ),
                const SizedBox(height: LawrenceSpacing.md),
                TextFormField(
                  controller: subtitleController,
                  textInputAction: TextInputAction.next,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Subtítulo',
                    hintText: 'Da tomada de medidas à construção dos primeiros moldes',
                    helperText: 'Complemente o nome sem repetir a mesma informação.',
                  ),
                  onChanged: (_) => onChanged(),
                ),
                const SizedBox(height: LawrenceSpacing.md),
                TextFormField(
                  controller: slugController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Endereço do curso',
                    hintText: 'modelagem-feminina',
                    helperText: 'Use letras minúsculas, números e hífens.',
                  ),
                  onChanged: (_) => onChanged(),
                  validator: (value) {
                    final slug = value?.trim() ?? '';
                    if (slug.isEmpty) return 'Informe o endereço do curso.';
                    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
                      return 'Use apenas letras minúsculas, números e hífens.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: LawrenceSpacing.md),
                TextFormField(
                  controller: summaryController,
                  minLines: 2,
                  maxLines: 3,
                  maxLength: 240,
                  decoration: const InputDecoration(
                    labelText: 'Descrição curta',
                    hintText: 'Explique o resultado principal para o aluno.',
                    helperText: 'Este texto aparece em cards e listagens.',
                  ),
                  onChanged: (_) => onChanged(),
                  validator: (value) => value == null || value.trim().length < 10
                      ? 'Escreva ao menos 10 caracteres.'
                      : null,
                ),
                const SizedBox(height: LawrenceSpacing.md),
                TextFormField(
                  controller: descriptionController,
                  minLines: 5,
                  maxLines: 8,
                  maxLength: 5000,
                  decoration: const InputDecoration(
                    labelText: 'Descrição completa',
                    hintText: 'Apresente o método, a sequência e a transformação proposta.',
                    helperText: 'Não repita apenas a descrição curta.',
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => onChanged(),
                ),
                const SizedBox(height: LawrenceSpacing.lg),
                if (compact)
                  Column(
                    children: [
                      _categoryField(),
                      const SizedBox(height: LawrenceSpacing.md),
                      _levelField(),
                      const SizedBox(height: LawrenceSpacing.md),
                      _languageField(),
                      const SizedBox(height: LawrenceSpacing.md),
                      _durationField(),
                    ],
                  )
                else
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _categoryField()),
                          const SizedBox(width: LawrenceSpacing.md),
                          Expanded(child: _levelField()),
                        ],
                      ),
                      const SizedBox(height: LawrenceSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _languageField()),
                          const SizedBox(width: LawrenceSpacing.md),
                          Expanded(child: _durationField()),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: LawrenceSpacing.xl),
                const _SectionTitle('Pré-requisitos'),
                const SizedBox(height: LawrenceSpacing.xs),
                const Text(
                  'Informe um item por linha. Deixe em branco se não houver conhecimento anterior necessário.',
                  style: TextStyle(color: LawrenceColors.textSecondary),
                ),
                const SizedBox(height: LawrenceSpacing.md),
                TextFormField(
                  controller: requirementsController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Pré-requisitos do curso',
                    hintText: 'Conhecimentos básicos de costura\nSaber usar fita métrica',
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => onChanged(),
                ),
                const SizedBox(height: LawrenceSpacing.lg),
                const _ContractNotice(),
                const SizedBox(height: LawrenceSpacing.xl),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : onSave,
                    style: FilledButton.styleFrom(
                      minimumSize: Size(compact ? double.infinity : 220, 52),
                    ),
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_forward),
                    label: Text(
                      isSaving ? 'Salvando rascunho' : 'Salvar e continuar',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _categoryField() => DropdownButtonFormField<String>(
    value: category,
    decoration: const InputDecoration(
      labelText: 'Categoria',
      helperText: 'Selecione o tema principal.',
    ),
    items: const [
      DropdownMenuItem(value: 'modelagem', child: Text('Modelagem')),
      DropdownMenuItem(value: 'costura', child: Text('Costura')),
      DropdownMenuItem(value: 'corte', child: Text('Corte')),
      DropdownMenuItem(value: 'fashion_design', child: Text('Fashion design')),
      DropdownMenuItem(value: 'style_design', child: Text('Style design')),
      DropdownMenuItem(value: 'mini_curso', child: Text('Minicurso')),
    ],
    onChanged: (value) {
      if (value != null) onCategoryChanged(value);
    },
  );

  Widget _levelField() => DropdownButtonFormField<String>(
    value: level,
    decoration: const InputDecoration(
      labelText: 'Nível',
      helperText: 'Considere o conhecimento necessário para começar.',
    ),
    items: const [
      DropdownMenuItem(value: 'iniciante', child: Text('Iniciante')),
      DropdownMenuItem(value: 'intermediario', child: Text('Intermediário')),
      DropdownMenuItem(value: 'avancado', child: Text('Avançado')),
    ],
    onChanged: (value) {
      if (value != null) onLevelChanged(value);
    },
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: LawrenceColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _CourseTypeSummary extends StatelessWidget {
  const _CourseTypeSummary();

  @override
  Widget build(BuildContext context) => Semantics(
    selected: true,
    label: 'Tipo selecionado: Curso completo',
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LawrenceSpacing.md),
      decoration: BoxDecoration(
        color: LawrenceColors.infoSurface,
        border: Border.all(color: LawrenceColors.actionPrimary, width: 2),
        borderRadius: BorderRadius.circular(LawrenceRadii.card),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school_outlined, color: LawrenceColors.actionPrimary),
          SizedBox(width: LawrenceSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Curso completo',
                  style: TextStyle(
                    color: LawrenceColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: LawrenceSpacing.xxs),
                Text(
                  'Formação extensa organizada em módulos, aulas, materiais e atividades.',
                  style: TextStyle(color: LawrenceColors.textSecondary),
                ),
                SizedBox(height: LawrenceSpacing.xs),
                Text(
                  'Os demais formatos dependem de definição do produto.',
                  style: TextStyle(
                    color: LawrenceColors.info,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: LawrenceColors.actionPrimary),
        ],
      ),
    ),
  );
}

class _ContractNotice extends StatelessWidget {
  const _ContractNotice();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(LawrenceSpacing.md),
    decoration: BoxDecoration(
      color: LawrenceColors.warningSurface,
      borderRadius: BorderRadius.circular(LawrenceRadii.control),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, color: LawrenceColors.warning),
        SizedBox(width: LawrenceSpacing.sm),
        Expanded(
          child: Text(
            'Objetivos de aprendizagem, público-alvo, materiais e competências serão adicionados quando o contrato dessa estrutura for aprovado.',
            style: TextStyle(color: LawrenceColors.textPrimary, height: 1.4),
          ),
        ),
      ],
    ),
  );
}
