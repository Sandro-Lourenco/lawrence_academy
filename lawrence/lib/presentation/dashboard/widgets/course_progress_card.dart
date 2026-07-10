import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lawrence/core/theme.dart';

class CourseProgressCard extends StatefulWidget {
  final String courseTitle;
  final String instructorName;
  final int progressPercentage;
  final String imageUrl;
  final VoidCallback onTap;

  const CourseProgressCard({
    super.key,
    required this.courseTitle,
    required this.instructorName,
    required this.progressPercentage,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<CourseProgressCard> createState() => _CourseProgressCardState();
}

class _CourseProgressCardState extends State<CourseProgressCard> {
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
          width: 140,
          margin: const EdgeInsets.only(right: 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem da aula com badge circular
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          widget.imageUrl,
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 90,
                                color: LawrenceTheme.borderMist,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 20,
                                    color: LawrenceTheme.textSecondary,
                                  ),
                                ),
                              ),
                        ),
                      ),
                      // Badge circular no canto superior direito
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  value: widget.progressPercentage / 100.0,
                                  strokeWidth: 2,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        LawrenceTheme.primary,
                                      ),
                                ),
                              ),
                              Text(
                                '${widget.progressPercentage}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Textos e linear progress bar no rodapé
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.courseTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: LawrenceTheme.surfaceTile1,
                              fontFamily: 'Outfit',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.instructorName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 9,
                              color: LawrenceTheme.textSecondary,
                              fontFamily: 'Outfit',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Linear progress bar no final do card
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: LinearProgressIndicator(
                      value: widget.progressPercentage / 100.0,
                      backgroundColor: LawrenceTheme.borderMist,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        LawrenceTheme.primary,
                      ),
                      minHeight: 4,
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
