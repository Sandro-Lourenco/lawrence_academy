import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../domain/entities/activity.dart';
import '../controllers/activities_controller.dart';
import '../widgets/activity_status_presentation.dart';

final activityDetailProvider = Provider.family<AsyncValue<Activity?>, String>((
  ref,
  activityId,
) {
  return ref.watch(activitiesNotifierProvider).whenData((items) {
    for (final activity in items) {
      if (activity.id == activityId) return activity;
    }
    return null;
  });
});

class ActivityDetailPage extends ConsumerStatefulWidget {
  final String activityId;

  const ActivityDetailPage({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends ConsumerState<ActivityDetailPage> {
  // Quiz states
  int? _selectedQuizIndex;
  bool? _selectedTrueFalse;

  // Essay state
  final _essayController = TextEditingController();

  // Upload state
  String? _uploadedFileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Submission state
  bool _isSubmitting = false;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  Future<void> _submitActivity(Activity activity) async {
    setState(() => _isSubmitting = true);
    // Simulate network submission
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _hasSubmitted = true;
    });

    // Show success banner following Nielsen's usability heuristics (visibility of status)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Atividade submetida com sucesso!'),
        backgroundColor: LawrenceColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityDetailProvider(widget.activityId));

    return activityAsync.when(
      loading: () => StudentPageScaffold(
        title: 'Detalhes da Atividade',
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => context.go('/dashboard/activities'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        body: const SizedBox(
          height: 420,
          child: AppLoadingState(message: 'Carregando atividade'),
        ),
      ),
      error: (_, _) => StudentPageScaffold(
        title: 'Detalhes da Atividade',
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => context.go('/dashboard/activities'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        body: SizedBox(
          height: 420,
          child: AppErrorState(
            title: 'Não foi possível carregar esta atividade',
            message: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref.invalidate(activitiesNotifierProvider),
          ),
        ),
      ),
      data: (activity) {
        if (activity == null) {
          return StudentPageScaffold(
            title: 'Atividade indisponível',
            leading: IconButton(
              tooltip: 'Voltar',
              onPressed: () => context.go('/dashboard/activities'),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            body: SizedBox(
              height: 420,
              child: AppEmptyState(
                title: 'Atividade não encontrada',
                description:
                    'Esta atividade não está disponível ou deixou de existir.',
                icon: Icons.lock_outline_rounded,
                actionLabel: 'Voltar às atividades',
                onActionPressed: () => context.go('/dashboard/activities'),
              ),
            ),
          );
        }

        final status = _hasSubmitted
            ? activityStatusPresentation(ActivityStatus.submitted)
            : activityStatusPresentation(activity.status);
        final deadline = activity.deadline == null
            ? 'Sem prazo definido'
            : DateFormat('dd/MM/yyyy - HH:mm').format(activity.deadline!);

        return StudentPageScaffold(
          title: activity.title,
          subtitle: activity.courseName,
          leading: IconButton(
            tooltip: 'Voltar às atividades',
            onPressed: () => context.go('/dashboard/activities'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final overview = _buildOverview(activity, status, deadline);
              final workspace = _buildWorkspace(activity);

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    overview,
                    const SizedBox(height: LawrenceSpacing.md),
                    workspace,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: workspace),
                  const SizedBox(width: LawrenceSpacing.lg),
                  Expanded(flex: 2, child: overview),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOverview(
    Activity activity,
    ActivityStatusPresentation status,
    String deadline,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppStatusBadge(
              label: status.label,
              icon: status.icon,
              tone: status.tone,
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            Text(
              'Informações Gerais',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: LawrenceSpacing.md),
            _DetailRow(
              icon: Icons.school_outlined,
              label: 'Curso',
              value: activity.courseName,
            ),
            const Divider(height: LawrenceSpacing.xl),
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Responsável',
              value: activity.teacherName,
            ),
            const Divider(height: LawrenceSpacing.xl),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Prazo de Entrega',
              value: deadline,
            ),
            if (activity.grade != null && !_hasSubmitted) ...[
              const Divider(height: LawrenceSpacing.xl),
              _DetailRow(
                icon: Icons.workspace_premium_outlined,
                label: 'Nota Final',
                value: NumberFormat('0.##', 'pt_BR').format(activity.grade),
              ),
            ],
            if (activity.feedback?.trim().isNotEmpty == true &&
                !_hasSubmitted) ...[
              const SizedBox(height: LawrenceSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(LawrenceSpacing.md),
                decoration: BoxDecoration(
                  color: LawrenceColors.successSurface,
                  borderRadius: BorderRadius.circular(LawrenceRadii.control),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback do Professor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: LawrenceColors.success,
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.xs),
                    Text(
                      activity.feedback!,
                      style: const TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspace(Activity activity) {
    if (_hasSubmitted ||
        activity.status == ActivityStatus.submitted ||
        activity.status == ActivityStatus.graded) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(LawrenceSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 72,
                color: LawrenceColors.success,
              ),
              const SizedBox(height: LawrenceSpacing.md),
              Text(
                'Atividade Entregue',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: LawrenceSpacing.xs),
              const Text(
                'Sua resposta foi enviada com sucesso e está salva no sistema. Acompanhe a correção e feedbacks nesta página.',
                textAlign: TextAlign.center,
                style: TextStyle(color: LawrenceColors.textSecondary),
              ),
              const SizedBox(height: LawrenceSpacing.lg),
              OutlinedButton.icon(
                onPressed: () => context.go('/dashboard/activities'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar para atividades'),
              ),
            ],
          ),
        ),
      );
    }

    Widget innerWorkspace;
    switch (activity.type) {
      case ActivityType.quiz:
        innerWorkspace = _buildQuizWorkspace();
        break;
      case ActivityType.trueFalse:
        innerWorkspace = _buildTrueFalseWorkspace();
        break;
      case ActivityType.essay:
        innerWorkspace = _buildEssayWorkspace();
        break;
      case ActivityType.upload:
        innerWorkspace = _buildUploadWorkspace();
        break;
      case ActivityType.project:
        innerWorkspace =
            const SizedBox.shrink(); // Handled by project_detail_page
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LawrenceSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Área de Entrega',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: LawrenceSpacing.xs),
            const Text(
              'Responda com atenção antes de submeter.',
              style: TextStyle(color: LawrenceColors.textSecondary),
            ),
            const SizedBox(height: LawrenceSpacing.lg),
            innerWorkspace,
            const SizedBox(height: LawrenceSpacing.xl),
            const Divider(),
            const SizedBox(height: LawrenceSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _isSubmitting || !_canSubmit(activity)
                    ? null
                    : () => _submitActivity(activity),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSubmitting ? 'Enviando...' : 'Submeter Atividade',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit(Activity activity) {
    switch (activity.type) {
      case ActivityType.quiz:
        return _selectedQuizIndex != null;
      case ActivityType.trueFalse:
        return _selectedTrueFalse != null;
      case ActivityType.essay:
        return _essayController.text.trim().length >= 10;
      case ActivityType.upload:
        return _uploadedFileName != null;
      case ActivityType.project:
        return false;
    }
  }

  Widget _buildQuizWorkspace() {
    final options = [
      'Alternativa A: Introdução teórica e prática inicial.',
      'Alternativa B: Foco no acabamento fino e costura invisível.',
      'Alternativa C: Métodos de modelagem plana avançada.',
      'Alternativa D: Organização de ateliê e marketing básico.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Questão 1:\nQual dos seguintes conceitos é fundamental para o desenvolvimento da modelagem plana sob medida?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LawrenceColors.textPrimary,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.md),
        for (int i = 0; i < options.length; i++)
          RadioListTile<int>(
            value: i,
            groupValue: _selectedQuizIndex,
            title: Text(options[i]),
            onChanged: (val) => setState(() => _selectedQuizIndex = val),
          ),
      ],
    );
  }

  Widget _buildTrueFalseWorkspace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classifique a afirmação como Verdadeira ou Falsa:\n"A costura francesa é ideal para tecidos pesados como jeans e brim estruturado."',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LawrenceColors.textPrimary,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.md),
        RadioListTile<bool>(
          value: true,
          groupValue: _selectedTrueFalse,
          title: const Text('Verdadeiro (V)'),
          onChanged: (val) => setState(() => _selectedTrueFalse = val),
        ),
        RadioListTile<bool>(
          value: false,
          groupValue: _selectedTrueFalse,
          title: const Text('Falso (F)'),
          onChanged: (val) => setState(() => _selectedTrueFalse = val),
        ),
      ],
    );
  }

  Widget _buildEssayWorkspace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enunciado da Redação:\nDescreva as principais diferenças e aplicações práticas entre a costura inglesa e a costura francesa no acabamento de roupas finas.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LawrenceColors.textPrimary,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.md),
        TextField(
          controller: _essayController,
          maxLines: 8,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText:
                'Escreva sua resposta dissertativa aqui (mínimo de 10 caracteres)...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_essayController.text.length} caracteres',
            style: const TextStyle(
              color: LawrenceColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadWorkspace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instruções de Envio:\nPor favor, tire uma foto nítida do seu exercício de costura reta e faça o upload do arquivo para avaliação do tutor.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LawrenceColors.textPrimary,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.lg),
        if (_uploadedFileName != null)
          Container(
            padding: const EdgeInsets.all(LawrenceSpacing.md),
            decoration: BoxDecoration(
              color: LawrenceColors.successSurface,
              borderRadius: BorderRadius.circular(LawrenceRadii.control),
              border: Border.all(
                color: LawrenceColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  color: LawrenceColors.success,
                ),
                const SizedBox(width: LawrenceSpacing.sm),
                Expanded(
                  child: Text(
                    _uploadedFileName!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: LawrenceColors.danger),
                  onPressed: () => setState(() => _uploadedFileName = null),
                ),
              ],
            ),
          )
        else if (_isUploading)
          Column(
            children: [
              LinearProgressIndicator(
                value: _uploadProgress,
                color: LawrenceColors.primary,
                backgroundColor: LawrenceColors.borderMist,
              ),
              const SizedBox(height: LawrenceSpacing.xs),
              Text(
                'Enviando arquivo: ${(_uploadProgress * 100).toInt()}%',
                style: const TextStyle(color: LawrenceColors.textSecondary),
              ),
            ],
          )
        else
          InkWell(
            onTap: _startFakeUpload,
            borderRadius: BorderRadius.circular(LawrenceRadii.card),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: LawrenceColors.canvasParchment,
                borderRadius: BorderRadius.circular(LawrenceRadii.card),
                border: Border.all(
                  color: LawrenceColors.borderMist,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: LawrenceColors.primary,
                  ),
                  SizedBox(height: LawrenceSpacing.sm),
                  Text(
                    'Selecionar arquivo do dispositivo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: LawrenceColors.primary,
                    ),
                  ),
                  SizedBox(height: LawrenceSpacing.xxs),
                  Text(
                    'JPG, PNG ou PDF de até 20MB',
                    style: TextStyle(
                      fontSize: 13,
                      color: LawrenceColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _startFakeUpload() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() {
        _uploadProgress = i / 10.0;
      });
    }

    setState(() {
      _isUploading = false;
      _uploadedFileName = 'exercicio_costura_reta.png';
    });
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: LawrenceColors.textSecondary),
        const SizedBox(width: LawrenceSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: LawrenceSpacing.xxs),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ],
    );
  }
}
