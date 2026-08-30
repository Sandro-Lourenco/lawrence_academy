import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/state_widgets.dart';
import '../../domain/entities/live_event.dart';
import '../providers/lives_provider.dart';

class TeacherLiveEventsPage extends ConsumerWidget {
  const TeacherLiveEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(teacherLivesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar ao painel',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/teacher'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Eventos e lives'),
      ),
      body: events.when(
        loading: () =>
            const AppLoadingState(message: 'Carregando a agenda do ateliê'),
        error: (_, _) => AppErrorState(
          title: 'Não foi possível carregar a agenda',
          message: 'Confira sua conexão e tente novamente.',
          onRetry: () => ref.invalidate(teacherLivesProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teacherLivesProvider);
            await ref.read(teacherLivesProvider.future);
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: ListView(
                padding: const EdgeInsets.all(LawrenceSpacing.lg),
                children: [
                  Text(
                    'Agenda do ateliê',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: LawrenceSpacing.xs),
                  Text(
                    'Crie a transmissão no YouTube Studio e cole aqui o link oficial. Os horários aparecem no fuso do participante.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: LawrenceSpacing.xl),
                  if (items.isEmpty)
                    AppEmptyState(
                      icon: Icons.live_tv_outlined,
                      title: 'Nenhum evento criado',
                      description:
                          'Crie uma live para organizar o próximo encontro com seus alunos.',
                      actionLabel: 'Criar primeira live',
                      onActionPressed: () => _openEditor(context, ref),
                    ),
                  for (final event in items) _TeacherLiveTile(event: event),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova live'),
      ),
    );
  }

  static Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, [
    LiveEvent? event,
  ]) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LiveEventEditor(event: event),
    );
    if (saved == true) {
      ref.invalidate(teacherLivesProvider);
      ref.invalidate(livesProvider);
    }
  }
}

class _TeacherLiveTile extends ConsumerWidget {
  const _TeacherLiveTile({required this.event});
  final LiveEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = event.scheduledFor.toLocal();
    return Card(
      margin: const EdgeInsets.only(bottom: LawrenceSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(LawrenceSpacing.md),
        leading: const Icon(Icons.live_tv_outlined),
        title: Text(event.title),
        subtitle: Text(
          '${_formatDate(local)} · ${event.durationMinutes} min · ${event.status}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await TeacherLiveEventsPage._openEditor(context, ref, event);
            } else if (value == 'delete') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Excluir evento?'),
                  content: Text('“${event.title}” será removido da agenda.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(liveEventRepositoryProvider).delete(event.id);
                ref.invalidate(teacherLivesProvider);
                ref.invalidate(livesProvider);
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }
}

class _LiveEventEditor extends ConsumerStatefulWidget {
  const _LiveEventEditor({this.event});
  final LiveEvent? event;

  @override
  ConsumerState<_LiveEventEditor> createState() => _LiveEventEditorState();
}

class _LiveEventEditorState extends ConsumerState<_LiveEventEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _tag;
  late final TextEditingController _youtube;
  late final TextEditingController _banner;
  late DateTime _scheduledFor;
  late String _timezone;
  late String _status;
  late int _duration;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _title = TextEditingController(text: event?.title ?? '');
    _description = TextEditingController(text: event?.description ?? '');
    _tag = TextEditingController(text: event?.tag ?? 'Alta-costura');
    _youtube = TextEditingController(text: event?.youtubeUrl ?? '');
    _banner = TextEditingController(text: event?.bannerUrl ?? '');
    _scheduledFor =
        event?.scheduledFor.toLocal() ??
        DateTime.now().add(const Duration(days: 1));
    _timezone = event?.timezone ?? 'America/Sao_Paulo';
    _status = event?.status ?? 'draft';
    _duration = event?.durationMinutes ?? 60;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _tag.dispose();
    _youtube.dispose();
    _banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.event == null ? 'Nova live' : 'Editar live'),
    content: SizedBox(
      width: 640,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 3,
                maxLength: 2000,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              TextFormField(
                controller: _tag,
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _youtube,
                decoration: const InputDecoration(
                  labelText: 'Link da live no YouTube',
                ),
                validator: _validateYoutube,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _banner,
                decoration: const InputDecoration(
                  labelText: 'Imagem HTTPS (opcional)',
                ),
                validator: _validateOptionalHttps,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data e hora'),
                subtitle: Text(_formatDate(_scheduledFor)),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: _pickDateTime,
              ),
              DropdownButtonFormField<String>(
                initialValue: _timezone,
                decoration: const InputDecoration(labelText: 'Fuso horário'),
                items: const [
                  DropdownMenuItem(
                    value: 'America/Sao_Paulo',
                    child: Text('Brasília · America/Sao_Paulo'),
                  ),
                  DropdownMenuItem(
                    value: 'America/Manaus',
                    child: Text('Manaus · America/Manaus'),
                  ),
                  DropdownMenuItem(
                    value: 'Europe/Paris',
                    child: Text('Paris · Europe/Paris'),
                  ),
                ],
                onChanged: (value) => setState(() => _timezone = value!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _duration,
                      decoration: const InputDecoration(labelText: 'Duração'),
                      items: const [30, 45, 60, 90, 120]
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text('$v min'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _duration = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items:
                          const [
                                'draft',
                                'scheduled',
                                'live',
                                'ended',
                                'cancelled',
                              ]
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                      onChanged: (value) => setState(() => _status = value!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Salvando…' : 'Salvar evento'),
      ),
    ],
  );

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledFor,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledFor),
    );
    if (time != null) {
      setState(
        () => _scheduledFor = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final value = LiveEvent(
        id: widget.event?.id ?? '',
        title: _title.text,
        description: _description.text,
        instructor: widget.event?.instructor ?? '',
        scheduledFor: _scheduledFor,
        durationMinutes: _duration,
        status: _status,
        tag: _tag.text,
        youtubeUrl: _youtube.text.trim(),
        bannerUrl: _banner.text.trim().isEmpty ? null : _banner.text.trim(),
        timezone: _timezone,
      );
      final repository = ref.read(liveEventRepositoryProvider);
      if (widget.event == null) {
        await repository.create(value);
      } else {
        await repository.update(value);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: $error')),
        );
      }
    }
  }

  static String? _required(String? value) =>
      value == null || value.trim().length < 2 ? 'Campo obrigatório.' : null;
  static String? _validateYoutube(String? value) {
    final uri = Uri.tryParse(value ?? '');
    if (uri == null ||
        uri.scheme != 'https' ||
        !{
          'youtube.com',
          'www.youtube.com',
          'm.youtube.com',
          'youtu.be',
        }.contains(uri.host.toLowerCase())) {
      return 'Informe um link HTTPS oficial do YouTube.';
    }
    if (uri.host == 'youtu.be') {
      return uri.pathSegments.isEmpty ? 'Link incompleto.' : null;
    }
    return uri.path.startsWith('/live/') ||
            (uri.path == '/watch' &&
                uri.queryParameters['v']?.isNotEmpty == true)
        ? null
        : 'Use um link /watch ou /live do YouTube.';
  }

  static String? _validateOptionalHttps(String? value) =>
      value == null ||
          value.trim().isEmpty ||
          Uri.tryParse(value)?.scheme == 'https'
      ? null
      : 'A imagem deve usar HTTPS.';
}

String _formatDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
