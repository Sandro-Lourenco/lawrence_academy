import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:lawrence/core/theme.dart';
import 'package:lawrence/data/models/course_dto.dart';
import 'package:lawrence/presentation/player_controller.dart';
import 'package:lawrence/shared/widgets/liquid_glass_card.dart';
import 'package:lawrence/shared/widgets/liquid_glass_container.dart';
import 'package:lawrence/presentation/auth/controllers/auth_controller.dart';

class CoursePlayerPage extends ConsumerStatefulWidget {
  final Course course;
  final Lesson initialLesson;

  const CoursePlayerPage({
    super.key,
    required this.course,
    required this.initialLesson,
  });

  @override
  ConsumerState<CoursePlayerPage> createState() => _CoursePlayerPageState();
}

class _CoursePlayerPageState extends ConsumerState<CoursePlayerPage> with TickerProviderStateMixin {
  late Lesson _activeLesson;
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  bool _isPlayingVideo = false; // Controla se o player de vídeo está ativo no topo
  
  // Marca d'água dinâmica
  Timer? _watermarkTimer;
  double _watermarkX = 40.0;
  double _watermarkY = 40.0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _activeLesson = widget.initialLesson;
    _tabController = TabController(length: 3, vsync: this);
    _startWatermarkMovement();
  }

  @override
  void dispose() {
    _watermarkTimer?.cancel();
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _startWatermarkMovement() {
    _watermarkTimer?.cancel();
    _watermarkTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) return;
      setState(() {
        _watermarkX = 20.0 + _random.nextDouble() * 200;
        _watermarkY = 20.0 + _random.nextDouble() * 120;
      });
    });
  }

  void _switchLesson(Lesson newLesson) {
    setState(() {
      _activeLesson = newLesson;
      _isPlayingVideo = true; // Iniciar reprodução do vídeo
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerState = ref.watch(playerControllerProvider(_activeLesson));
    final playerNotifier = ref.read(playerControllerProvider(_activeLesson).notifier);
    final user = ref.watch(authControllerProvider).user;

    // Proteção contra adulteração (Anti-Tampering)
    if (playerState.isTampered) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "VIOLAÇÃO DE SEGURANÇA DETECTADA.\nSessão encerrada.",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: LawrenceTheme.canvasParchment, // Fundo claro #F8F9FB
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra superior glassmorphic (Top App Bar)
            LiquidGlassContainer(
              borderRadius: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              backgroundColor: Colors.white.withOpacity(0.72),
              borderColor: LawrenceTheme.borderMist.withOpacity(0.5),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: LawrenceTheme.surfaceTile1),
                    onPressed: () => context.go('/dashboard/home'),
                  ),
                  Expanded(
                    child: Text(
                      widget.course.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cast_connected, color: LawrenceTheme.surfaceTile1),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Procurando dispositivos para transmissão...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // 2. Conteúdo Rolável (Player + Landing Info)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Se estiver reproduzindo vídeo, exibe o Player de Vídeo no topo
                    if (_isPlayingVideo) ...[
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: Colors.black,
                          child: playerState.errorMessage != null
                              ? Center(child: Text(playerState.errorMessage!, style: const TextStyle(color: Colors.white70)))
                              : playerNotifier.videoController != null &&
                                      playerNotifier.videoController!.value.isInitialized
                                  ? Stack(
                                      children: [
                                        // Player de vídeo
                                        VideoPlayer(playerNotifier.videoController!),

                                        // Controles glassmorphic simplificados
                                        Positioned(
                                          bottom: 12,
                                          left: 12,
                                          child: LiquidGlassContainer(
                                            borderRadius: LawrenceTheme.radiusXs,
                                            padding: const EdgeInsets.all(4),
                                            backgroundColor: Colors.black.withOpacity(0.5),
                                            child: IconButton(
                                              icon: Icon(
                                                playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              onPressed: () => playerNotifier.togglePlay(),
                                            ),
                                          ),
                                        ),

                                        // Marca d'água dinâmica sobreposta (OWASP / LGPD)
                                        Positioned(
                                          left: _watermarkX,
                                          top: _watermarkY,
                                          key: const Key("secure-watermark-widget"),
                                          child: Opacity(
                                            opacity: 0.15,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              color: Colors.black45,
                                              child: Text(
                                                "${user?.email ?? 'aluno@lawrence.academy'} • IP: 189.24.91.x",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Center(child: CircularProgressIndicator(color: LawrenceTheme.primary)),
                        ),
                      ),
                    ] else ...[
                      // Se não estiver reproduzindo, exibe a capa editorial (conforme foto de referência)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail em formato losango
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDE8E8), // Fundo rosa/vermelho claro
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFFE02424),
                                      size: 36,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.course.title,
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: LawrenceTheme.surfaceTile1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.thumb_up_alt_outlined, size: 14, color: LawrenceTheme.textSecondary),
                                          const SizedBox(width: 4),
                                          Text('9.8', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.access_time, size: 14, color: LawrenceTheme.textSecondary),
                                          const SizedBox(width: 4),
                                          Text('6h de curso', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Botões de Ação Principais (Solid White Cards com interatividade e escala 0.97)
                            LiquidGlassCard(
                              onTap: () {
                                setState(() {
                                  _isPlayingVideo = true;
                                });
                              },
                              borderColor: LawrenceTheme.primary.withOpacity(0.08),
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.play_arrow_rounded, color: LawrenceTheme.primary, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Continuar onde parou',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: LawrenceTheme.surfaceTile1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            LiquidGlassCard(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Iniciando download offline seguro encryptado...')),
                                );
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.file_download_outlined, color: LawrenceTheme.surfaceTile1, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Baixar curso: 613 MB',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: LawrenceTheme.surfaceTile1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            LiquidGlassCard(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Turma adicionada ao seu plano de estudos.')),
                                );
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.add, color: LawrenceTheme.surfaceTile1, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Adicionar a um plano',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: LawrenceTheme.surfaceTile1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 3. Ícones de Ações Rápidas Horizontais (Pausar, Concluir, Fórum, Apagar)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAction(icon: Icons.pause, label: 'Pausar', onTap: () {
                            if (_isPlayingVideo) playerNotifier.togglePlay();
                          }),
                          _buildQuickAction(icon: Icons.flag_outlined, label: 'Concluir', onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Aula concluída! Parabéns!')),
                            );
                          }),
                          _buildQuickAction(icon: Icons.chat_bubble_outline, label: 'Fórum', onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Abrindo dúvidas e fórum da turma...')),
                            );
                          }),
                          _buildQuickAction(icon: Icons.delete_outline, label: 'Apagar', onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Limpando cache offline desta aula.')),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Abas: Aulas, Instrutores, Formações
                    TabBar(
                      controller: _tabController,
                      indicatorColor: LawrenceTheme.primary,
                      labelColor: LawrenceTheme.primary,
                      unselectedLabelColor: LawrenceTheme.textSecondary,
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: "Aulas"),
                        Tab(text: "Instrutores"),
                        Tab(text: "Formações"),
                      ],
                    ),

                    // 5. Conteúdo das Abas (Auto-ajustável para evitar overflows)
                    Container(
                      height: 400, // Limite para rolagem local das abas
                      padding: const EdgeInsets.all(20.0),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLessonsTab(theme),
                          _buildInstructorsTab(theme),
                          _buildFormationsTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LawrenceTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(icon, color: LawrenceTheme.surfaceTile1, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: LawrenceTheme.surfaceTile1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsTab(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Aulas e Exercícios do Módulo",
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: widget.course.modules.length,
            itemBuilder: (context, modIdx) {
              final module = widget.course.modules[modIdx];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      module.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LawrenceTheme.primary,
                      ),
                    ),
                  ),
                  ...module.lessons.map((lesson) {
                    final isActive = lesson.id == _activeLesson.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: LiquidGlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        onTap: () => _switchLesson(lesson),
                        borderColor: isActive ? LawrenceTheme.primary.withOpacity(0.2) : null,
                        child: Row(
                          children: [
                            Icon(
                              isActive ? Icons.play_circle_fill : Icons.play_circle_outline,
                              color: isActive ? LawrenceTheme.primary : LawrenceTheme.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.title,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                      color: LawrenceTheme.surfaceTile1,
                                    ),
                                  ),
                                  Text(
                                    '${(lesson.durationSeconds / 60).round()} min / 24 MB',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 18),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstructorsTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ariane Lawrence',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Fundadora e Diretora Criativa',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Especialista em alta costura e alfaiataria fina pela École de la Chambre Syndicale de la Couture Parisienne. Ariane guia os alunos nos segredos da modelagem tridimensional clássica.',
            style: theme.textTheme.bodyMedium?.copyWith(color: LawrenceTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildFormationsTab(ThemeData theme) {
    return const Center(
      child: Text(
        "Este curso faz parte da Formação Modelagem e Alta Costura Avançada.",
        style: TextStyle(color: LawrenceTheme.textSecondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}
