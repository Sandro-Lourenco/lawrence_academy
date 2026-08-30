import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../../../design_system/widgets/status_badge.dart';
import '../../../../design_system/widgets/student_page_scaffold.dart';
import '../../../../design_system/widgets/couture_primary_button.dart';
import '../../domain/entities/activity.dart';
import '../../../tasks/domain/entities/task_submission.dart';
import '../controllers/activities_controller.dart';
import '../widgets/activity_status_presentation.dart';
import '../../../../app/providers/service_repositories.dart';
import 'package:uuid/uuid.dart';

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
  final bool _isUploading = false;
  final double _uploadProgress = 0.0;

  // Submission state
  bool _isSubmitting = false;
  bool _hasSubmitted = false;
  TaskSubmission? _submission;
  late final String _idempotencyKey;

  @override
  void initState() {
    super.initState();
    _idempotencyKey = const Uuid().v4();
  }

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  Future<void> _submitActivity(Activity activity) async {
    setState(() => _isSubmitting = true);
    try {
      final option = switch (activity.type) {
        ActivityType.quiz =>
          _selectedQuizIndex == null
              ? null
              : activity.options.keys.elementAt(_selectedQuizIndex!),
        ActivityType.trueFalse =>
          _selectedTrueFalse == null
              ? null
              : (_selectedTrueFalse! ? 'true' : 'false'),
        _ => null,
      };
      final submission = await ref
          .read(taskRepositoryProvider)
          .submitTask(
            activity.id,
            selectedOption: option,
            textAnswer: activity.type == ActivityType.essay
                ? _essayController.text.trim()
                : null,
            idempotencyKey: _idempotencyKey,
          );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _hasSubmitted = true;
        _submission = submission;
      });
      ref.invalidate(activitiesNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            submission.isCorrect == true
                ? 'Resposta correta! Excelente trabalho.'
                : submission.isCorrect == false
                ? 'Resposta incorreta. Confira a alternativa correta abaixo.'
                : 'Atividade submetida com sucesso!',
          ),
          backgroundColor: submission.isCorrect == false
              ? LawrenceColors.danger
              : LawrenceColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível enviar. Sua resposta foi mantida; tente novamente.',
          ),
          backgroundColor: LawrenceColors.danger,
        ),
      );
    }
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
              final mobile = constraints.maxWidth < 700;
              final overview = _buildOverview(activity, status, deadline);
              final workspace = _buildWorkspace(activity);

              if (mobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 18),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: LawrenceColors.borderMist),
                        ),
                      ),
                      child: Row(
                        children: [
                          AppStatusBadge(
                            label: status.label,
                            icon: status.icon,
                            tone: status.tone,
                          ),
                          const Spacer(),
                          Text(
                            deadline,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: LawrenceSpacing.lg),
                    workspace,
                  ],
                );
              }
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
    final choiceActivity =
        activity.type == ActivityType.quiz ||
        activity.type == ActivityType.trueFalse;
    final hasChoiceResult =
        choiceActivity &&
        (_submission?.status == 'graded' ||
            activity.status == ActivityStatus.graded);
    if (!hasChoiceResult &&
        (_hasSubmitted ||
            activity.status == ActivityStatus.submitted ||
            activity.status == ActivityStatus.graded)) {
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
        innerWorkspace = _buildQuizWorkspace(activity);
        break;
      case ActivityType.trueFalse:
        innerWorkspace = _buildTrueFalseWorkspace(activity);
        break;
      case ActivityType.essay:
        innerWorkspace = _buildEssayWorkspace(activity);
        break;
      case ActivityType.upload:
        innerWorkspace = _buildUploadWorkspace();
        break;
      case ActivityType.project:
        innerWorkspace =
            const SizedBox.shrink(); // Handled by project_detail_page
        break;
    }

    final mobile = MediaQuery.sizeOf(context).width < 700;
    final content = Padding(
      padding: EdgeInsets.all(mobile ? 0 : LawrenceSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.type == ActivityType.quiz ||
                    activity.type == ActivityType.trueFalse
                ? 'Selecione uma alternativa'
                : 'Área de entrega',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: LawrenceColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: LawrenceSpacing.lg),
          innerWorkspace,
          const SizedBox(height: LawrenceSpacing.xl),
          const Divider(),
          const SizedBox(height: LawrenceSpacing.md),
          SizedBox(
            width: mobile ? double.infinity : null,
            child: CouturePrimaryButton(
              label: 'PRÓXIMA ATIVIDADE',
              icon: Icons.arrow_forward_rounded,
              loading: _isSubmitting,
              onPressed:
                  _isSubmitting || !_canSubmit(activity) || hasChoiceResult
                  ? null
                  : () => _submitActivity(activity),
            ),
          ),
        ],
      ),
    );
    if (mobile) return content;
    return Card(
      child: Padding(padding: EdgeInsets.zero, child: content),
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

  Widget _buildQuizWorkspace(Activity activity) {
    final options = activity.options.entries.toList(growable: false);
    final selectedKey =
        _submission?.selectedOption ??
        activity.selectedOption ??
        (_selectedQuizIndex == null ? null : options[_selectedQuizIndex!].key);
    final correctKey = _submission?.correctOption ?? activity.correctOption;
    final hasResult = correctKey != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activity.description ?? activity.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LawrenceColors.textPrimary,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.md),
        for (int i = 0; i < options.length; i++) ...[
          _AnswerOptionTile(
            letter: String.fromCharCode(65 + i),
            text: options[i].value.toString(),
            selected: selectedKey == options[i].key,
            correct: hasResult && correctKey == options[i].key,
            incorrect:
                hasResult &&
                selectedKey == options[i].key &&
                correctKey != options[i].key,
            enabled: !hasResult,
            onTap: () => setState(() => _selectedQuizIndex = i),
          ),
          const SizedBox(height: 14),
        ],
        if (hasResult)
          _AnswerResultBanner(
            correct: selectedKey == correctKey,
            correctAnswer: _correctAnswerLabel(options, correctKey),
          ),
      ],
    );
  }

  String _correctAnswerLabel(
    List<MapEntry<String, dynamic>> options,
    String? correctKey,
  ) {
    final index = options.indexWhere((entry) => entry.key == correctKey);
    if (index < 0) return 'Alternativa informada pelo professor';
    return '${String.fromCharCode(65 + index)} — ${options[index].value}';
  }

  Widget _buildTrueFalseWorkspace(Activity activity) {
    final selected =
        _submission?.selectedOption ??
        activity.selectedOption ??
        (_selectedTrueFalse == null
            ? null
            : (_selectedTrueFalse! ? 'true' : 'false'));
    final correct = _submission?.correctOption ?? activity.correctOption;
    final hasResult = correct != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activity.description ?? activity.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LawrenceColors.textPrimary,
          ),
        ),
        const SizedBox(height: LawrenceSpacing.md),
        _AnswerOptionTile(
          letter: 'V',
          text: 'Verdadeiro',
          selected: selected == 'true',
          correct: hasResult && correct == 'true',
          incorrect: hasResult && selected == 'true' && correct != 'true',
          enabled: !hasResult,
          onTap: () => setState(() => _selectedTrueFalse = true),
        ),
        const SizedBox(height: 14),
        _AnswerOptionTile(
          letter: 'F',
          text: 'Falso',
          selected: selected == 'false',
          correct: hasResult && correct == 'false',
          incorrect: hasResult && selected == 'false' && correct != 'false',
          enabled: !hasResult,
          onTap: () => setState(() => _selectedTrueFalse = false),
        ),
        if (hasResult) ...[
          const SizedBox(height: LawrenceSpacing.lg),
          _AnswerResultBanner(
            correct: selected == correct,
            correctAnswer: correct == 'true' ? 'V — Verdadeiro' : 'F — Falso',
          ),
        ],
      ],
    );
  }

  Widget _buildEssayWorkspace(Activity activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activity.description ?? activity.title,
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
            onTap: null,
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
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.correct,
    required this.incorrect,
    required this.enabled,
    required this.onTap,
  });

  final String letter;
  final String text;
  final bool selected;
  final bool correct;
  final bool incorrect;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final accent = correct
        ? LawrenceColors.success
        : incorrect
        ? LawrenceColors.danger
        : selected
        ? Theme.of(context).colorScheme.primary
        : LawrenceColors.brandNavy;
    final surface = correct
        ? LawrenceColors.successSurface
        : incorrect
        ? LawrenceColors.dangerSurface
        : selected
        ? LawrenceColors.surfaceSubtle
        : LawrenceColors.brandNavy;
    final foreground = correct || incorrect || selected
        ? LawrenceColors.brandNavy
        : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Alternativa $letter. $text',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            constraints: BoxConstraints(minHeight: mobile ? 84 : 112),
            decoration: BoxDecoration(
              color: surface,
              border: Border(
                left: BorderSide(color: accent, width: 10),
                top: BorderSide(color: accent.withValues(alpha: .28)),
                right: BorderSide(color: accent.withValues(alpha: .28)),
                bottom: BorderSide(color: accent.withValues(alpha: .28)),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: mobile ? 64 : 112,
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: foreground.withValues(alpha: .72),
                        fontFamily: 'Georgia',
                        fontSize: mobile ? 38 : 54,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: mobile ? 84 : 112,
                  color: accent.withValues(alpha: .22),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: mobile ? 16 : 24,
                      vertical: mobile ? 14 : 20,
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: foreground,
                        fontSize: mobile ? 16 : 18,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (correct || incorrect)
                  Padding(
                    padding: EdgeInsets.only(right: mobile ? 12 : 24),
                    child: Icon(
                      correct
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: accent,
                      size: 34,
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

class _AnswerResultBanner extends StatelessWidget {
  const _AnswerResultBanner({
    required this.correct,
    required this.correctAnswer,
  });

  final bool correct;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final tone = correct ? LawrenceColors.success : LawrenceColors.danger;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: LawrenceSpacing.md),
      padding: const EdgeInsets.all(LawrenceSpacing.xl),
      color: correct
          ? LawrenceColors.successSurface
          : LawrenceColors.dangerSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? 'RESPOSTA CORRETA' : 'RESPOSTA INCORRETA',
            style: TextStyle(
              color: tone,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: LawrenceSpacing.sm),
          Text(
            correct
                ? 'Muito bem. Você pode continuar o percurso.'
                : 'A alternativa correta é: $correctAnswer',
            style: const TextStyle(fontSize: 18, height: 1.45),
          ),
        ],
      ),
    );
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
