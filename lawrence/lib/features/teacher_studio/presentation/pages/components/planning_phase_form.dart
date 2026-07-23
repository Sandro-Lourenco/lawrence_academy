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
                const SizedBox(height: LawrenceSpacing.xl),
                const _SectionTitle('Objetivos pedagógicos'),
                const SizedBox(height: LawrenceSpacing.xs),
                const Text(
                  'Estruture um item por linha. Você poderá reorganizar e refinar esses itens posteriormente.',
                  style: TextStyle(color: LawrenceColors.textSecondary),
                ),
                const SizedBox(height: LawrenceSpacing.md),
                _structuredListField(
                  controller: learningObjectivesController,
                  label: 'O que o aluno aprenderá',
                  hint:
                      'Tirar medidas corporais com precisão\nConstruir uma base de saia',
                  required: true,
                ),
                const SizedBox(height: LawrenceSpacing.md),
                _structuredListField(
                  controller: targetAudienceController,
                  label: 'Público-alvo',
                  hint:
                      'Pessoas iniciantes em modelagem\nCostureiras que desejam criar moldes próprios',
                  required: true,
                ),
                const SizedBox(height: LawrenceSpacing.md),
                _structuredListField(
                  controller: requiredMaterialsController,
                  label: 'Materiais necessários',
                  hint: 'Fita métrica\nPapel kraft\nRégua de modelagem',
                ),
                const SizedBox(height: LawrenceSpacing.md),
                _structuredListField(
                  controller: competenciesController,
                  label: 'Competências desenvolvidas',
                  hint:
                      'Leitura de medidas\nConstrução de bases\nAjuste de modelagem',
                ),
                const SizedBox(height: LawrenceSpacing.md),
                _structuredListField(
                  controller: expectedOutcomesController,
                  label: 'Resultados esperados',
                  hint:
                      'Criar moldes básicos com autonomia\nCorrigir ajustes simples de vestibilidade',
                ),
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

  Widget _languageField() => DropdownButtonFormField<String>(
    value: language,
    decoration: const InputDecoration(
      labelText: 'Idioma',
      helperText: 'Idioma principal das aulas e materiais.',
    ),
    items: const [
      DropdownMenuItem(value: 'pt-BR', child: Text('Português (Brasil)')),
      DropdownMenuItem(value: 'en', child: Text('Inglês')),
      DropdownMenuItem(value: 'es', child: Text('Espanhol')),
    ],
    onChanged: (value) {
      if (value != null) onLanguageChanged(value);
    },
  );

  Widget _durationField() => TextFormField(
    controller: durationController,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      labelText: 'Carga horária estimada (minutos)',
      hintText: 'Ex.: 720',
      helperText: 'A duração real será calculada a partir das aulas.',
    ),
    onChanged: (_) => onChanged(),
    validator: (value) {
      if (value == null || value.trim().isEmpty) return null;
      final minutes = int.tryParse(value.trim());
      if (minutes == null || minutes < 1 || minutes > 100000) {
        return 'Informe uma duração entre 1 e 100000 minutos.';
      }
      return null;
    },
  );

  Widget _structuredListField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
  }) => TextFormField(
    controller: controller,
    minLines: 3,
    maxLines: 6,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: 'Um item por linha · máximo de 20 itens.',
      alignLabelWithHint: true,
    ),
    onChanged: (_) => onChanged(),
    validator: (value) {
      final items = (value ?? '')
          .split('\n')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (required && items.isEmpty) return 'Adicione pelo menos um item.';
      if (items.length > 20) return 'Use no máximo 20 itens.';
      if (items.any((item) => item.length > 240)) {
        return 'Cada item deve ter no máximo 240 caracteres.';
      }
      return null;
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

class _CourseTypeSelector extends StatelessWidget {
  const _CourseTypeSelector({
    required this.value,
    required this.onChanged,
    required this.compact,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const options = [
      (
        value: 'complete',
        title: 'Curso completo',
        description: 'Formação extensa organizada em módulos e aulas.',
        example: 'Ex.: Modelagem do básico ao avançado',
        icon: Icons.school_outlined,
      ),
      (
        value: 'quick',
        title: 'Curso rápido',
        description: 'Conteúdo curto para uma habilidade específica.',
        example: 'Ex.: Como fazer barra invisível',
        icon: Icons.bolt_outlined,
      ),
      (
        value: 'workshop',
        title: 'Workshop ou oficina',
        description: 'Encontro prático, turma ou experiência ao vivo.',
        example: 'Ex.: Oficina de acabamentos',
        icon: Icons.groups_outlined,
      ),
    ];

    final cards = options
        .map(
          (option) => _CourseTypeCard(
            selected: value == option.value,
            title: option.title,
            description: option.description,
            example: option.example,
            icon: option.icon,
            onTap: () => onChanged(option.value),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Qual tipo de curso você deseja criar?'),
        const SizedBox(height: LawrenceSpacing.xs),
        const Text(
          'O formato orienta a organização inicial; regras comerciais são configuradas separadamente.',
          style: TextStyle(color: LawrenceColors.textSecondary),
        ),
        const SizedBox(height: LawrenceSpacing.md),
        if (compact)
          Column(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                SizedBox(width: double.infinity, child: cards[index]),
                if (index < cards.length - 1)
                  const SizedBox(height: LawrenceSpacing.sm),
              ],
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                Expanded(child: cards[index]),
                if (index < cards.length - 1)
                  const SizedBox(width: LawrenceSpacing.sm),
              ],
            ],
          ),
      ],
    );
  }
}

class _CourseTypeCard extends StatelessWidget {
  const _CourseTypeCard({
    required this.selected,
    required this.title,
    required this.description,
    required this.example,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String description;
  final String example;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '$title. $description. $example',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LawrenceRadii.card),
      child: Container(
        constraints: const BoxConstraints(minHeight: 184),
        padding: const EdgeInsets.all(LawrenceSpacing.md),
        decoration: BoxDecoration(
          color: selected ? LawrenceColors.infoSurface : LawrenceColors.canvas,
          border: Border.all(
            color: selected
                ? LawrenceColors.actionPrimary
                : LawrenceColors.borderMist,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(LawrenceRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: LawrenceColors.actionPrimary),
                const Spacer(),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected
                      ? LawrenceColors.actionPrimary
                      : LawrenceColors.textDisabled,
                ),
              ],
            ),
            const SizedBox(height: LawrenceSpacing.md),
            Text(
              title,
              style: const TextStyle(
                color: LawrenceColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: LawrenceSpacing.xs),
            Text(
              description,
              style: const TextStyle(color: LawrenceColors.textSecondary),
            ),
            const SizedBox(height: LawrenceSpacing.xs),
            Text(
              example,
              style: const TextStyle(
                color: LawrenceColors.info,
                fontSize: 13,
              ),
            ),
          ],
        ),
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
