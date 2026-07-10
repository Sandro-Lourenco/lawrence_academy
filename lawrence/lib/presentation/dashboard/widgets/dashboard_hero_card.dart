import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lawrence/core/theme.dart';

class DashboardHeroCard extends StatefulWidget {
  final String courseTitle;
  final String instructorName;
  final int progressPercentage;
  final String imageUrl;
  final VoidCallback onTap;

  const DashboardHeroCard({
    super.key,
    required this.courseTitle,
    required this.instructorName,
    required this.progressPercentage,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<DashboardHeroCard> createState() => _DashboardHeroCardState();
}

class _DashboardHeroCardState extends State<DashboardHeroCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_scale, _scale, 1.0),
        transformAlignment: Alignment.center,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem de Fundo com Play e Progresso Circular
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: Image.network(
                          widget.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: LawrenceTheme.borderMist,
                            child: const Center(
                              child: Icon(Icons.broken_image, color: LawrenceTheme.textSecondary),
                            ),
                          ),
                        ),
                      ),
                      // Overlay escuro
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                      ),
                      // Botão Play no Centro
                      const Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white24,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: LawrenceTheme.primary,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Selo "CURSO EM ANDAMENTO"
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'CURSO EM ANDAMENTO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      // Progresso Circular flutuando no topo direito
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 38,
                                height: 38,
                                child: CircularProgressIndicator(
                                  value: widget.progressPercentage / 100.0,
                                  strokeWidth: 3.5,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(LawrenceTheme.primary),
                                ),
                              ),
                              Text(
                                '${widget.progressPercentage}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Textos e botão "Continuar agora"
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.courseTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: LawrenceTheme.surfaceTile1,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.instructorName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: LawrenceTheme.textSecondary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LawrenceTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continuar agora',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
