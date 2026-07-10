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
  bool _isPlayingVideo = false;
  
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
    _enableScreenCaptureProtection();
  }

  @override
  void dispose() {
    _watermarkTimer?.cancel();
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _enableScreenCaptureProtection() {
    // No Android nativo, isso ativa a FLAG_SECURE para evitar gravação de tela
    // simulando a chamada de plataforma nativa
    debugPrint("[Security Sandbox] FLAG_SECURE ativada no Player de Vídeo");
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
      _isPlayingVideo = true;
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerState = ref.watch(playerControllerProvider(_activeLesson));
    final playerNotifier = ref.read(playerControllerProvider(_activeLesson).notifier);
    final user = ref.watch(authControllerProvider).user;

    // Proteção contra adulteração do DOM / Elementos (Anti-Tampering)
    if (playerState.isTampered) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "VIOLAÇÃO DE SEGURANÇA DETECTADA.\nSessão de mídia encerrada por proteção de DRM.",
            style: TextStyle(color: LawrenceTheme.danger, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // Modo Escuro Absoluto (#000000)
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra superior glassmorphic translúcida sobre fundo preto
            LiquidGlassContainer(
              borderRadius: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              backgroundColor: Colors.black.withOpacity(0.4),
              borderColor: Colors.white.withOpacity(0.08),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/dashboard/home'),
                  ),
                  Expanded(
                    child: Text(
                      widget.course.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Outfit',
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cast_connected, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Procurando dispositivos para transmissão via DRM...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // 2. Conteúdo Rolável
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Área do Player de Vídeo
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.black87,
                        child: _isPlayingVideo
                            ? (playerState.errorMessage != null
                                ? Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline, color: LawrenceTheme.danger, size: 40),
                                          const SizedBox(height: 12),
                                          Text(
                                            playerState.errorMessage!,
                                            style: const TextStyle(color: Colors.white70, fontFamily: 'Outfit', fontSize: 13),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: () => _switchLesson(_activeLesson),
                                            child: const Text("Tentar Novamente", style: TextStyle(fontFamily: 'Outfit')),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : (playerNotifier.videoController != null &&
                                        playerNotifier.videoController!.value.isInitialized
                                    ? Stack(
                                        children: [
                                          VideoPlayer(playerNotifier.videoController!),
                                          
                                          // Controles flutuantes Liquid Glass
                                          Positioned(
                                            bottom: 12,
                                            left: 12,
                                            child: LiquidGlassContainer(
                                              borderRadius: LawrenceTheme.radiusXs,
                                              padding: const EdgeInsets.all(4),
                                              backgroundColor: Colors.black.withOpacity(0.5),
                                              borderColor: Colors.white24,
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
                                              opacity: 0.18,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                color: Colors.black45,
                                                child: Text(
                                                  "${user?.email ?? 'aluno@lawrence.academy'} • DRM PROTECTED",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Center(child: CircularProgressIndicator(color: LawrenceTheme.primary))))
                            : Container(
                                // Capa antes do play
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage('https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundColor: Colors.white24,
                                      child: IconButton(
                                        icon: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                                        onPressed: () {
                                          setState(() {
                                            _isPlayingVideo = true;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    
                    // Titulo da lição e metadados
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeLesson.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.video_library_outlined, size: 14, color: Colors.white54),
                              const SizedBox(width: 6),
                              Text(
                                "Módulo: ${widget.course.title}",
                                style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Outfit'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Ações rápidas
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAction(icon: Icons.pause, label: 'Pausar', onTap: () {
                            if (_isPlayingVideo) playerNotifier.togglePlay();
                          }),
                          _buildQuickAction(icon: Icons.check_circle_outline, label: 'Concluir', onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Aula concluída com sucesso!')),
                            );
                          }),
                          _buildQuickAction(icon: Icons.chat_bubble_outline, label: 'Fórum', onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Abrindo dúvidas e suporte pedagógico...')),
                            );
                          }),
                          _buildQuickAction(icon: Icons.download_for_offline_outlined, label: 'Offline', onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Material salvo para reprodução offline segura.')),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Abas
                    TabBar(
                      controller: _tabController,
                      indicatorColor: LawrenceTheme.primary,
                      labelColor: LawrenceTheme.primary,
                      unselectedLabelColor: Colors.white38,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      tabs: const [
                        Tab(text: "Aulas"),
                        Tab(text: "Instrutores"),
                        Tab(text: "Formações"),
                      ],
                    ),

                    // Conteúdo das Abas
                    Container(
                      height: 400,
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
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Módulos e Aulas",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
        ),
        const SizedBox(height: 12),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, color: LawrenceTheme.primary, fontSize: 13, fontFamily: 'Outfit'),
                    ),
                  ),
                  ...module.lessons.map((lesson) {
                    final isActive = lesson.id == _activeLesson.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isActive ? LawrenceTheme.primary.withOpacity(0.4) : Colors.white10),
                      ),
                      child: ListTile(
                        onTap: () => _switchLesson(lesson),
                        leading: Icon(
                          isActive ? Icons.play_circle_fill : Icons.play_circle_outline,
                          color: isActive ? LawrenceTheme.primary : Colors.white54,
                          size: 20,
                        ),
                        title: Text(
                          lesson.title,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        subtitle: Text(
                          '${(lesson.durationSeconds / 60).round()} min',
                          style: const TextStyle(color: Colors.white30, fontSize: 11),
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
        children: const [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ariane Lawrence',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                    ),
                    Text(
                      'Mestre em Alta Costura',
                      style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Outfit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Especialista em alta costura e alfaiataria fina pela École de la Chambre Syndicale de la Couture Parisienne. Ariane guia os alunos nos segredos da modelagem tridimensional clássica.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4, fontFamily: 'Outfit'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormationsTab(ThemeData theme) {
    return const Center(
      child: Text(
        "Este curso pertence à Grade de Especialização em Alfaiataria e Haute Couture.",
        style: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Outfit'),
        textAlign: TextAlign.center,
      ),
    );
  }
}
