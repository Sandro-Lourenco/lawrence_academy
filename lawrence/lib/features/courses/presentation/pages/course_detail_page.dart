import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_card.dart';
import '../../../../design_system/widgets/liquid_glass_container.dart';
import '../../application/course_detail_provider.dart';
import '../../domain/entities/course.dart';

class CourseDetailPage extends ConsumerStatefulWidget {
  final String slug;

  const CourseDetailPage({super.key, required this.slug});

  @override
  ConsumerState<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends ConsumerState<CourseDetailPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    final courseAsync = ref.watch(courseDetailBySlugProvider(widget.slug));

    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment, // Fundo claro #F8F9FB
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: LawrenceColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/courses');
            }
          },
        ),
        title: Text(
          "Detalhes do Curso",
          style: theme.textTheme.titleLarge?.copyWith(
            color: LawrenceColors.textPrimary,
          ),
        ),
      ),
      body: courseAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: LawrenceColors.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: LawrenceColors.danger,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "Erro ao carregar curso: $err",
                  style: const TextStyle(
                    color: LawrenceColors.textPrimary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (course) {
          if (course == null) {
            return const Center(
              child: Text(
                "Curso não encontrado.",
                style: TextStyle(color: LawrenceColors.textPrimary),
              ),
            );
          }
          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: 120,
                ), // Espaço para a barra flutuante inferior
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. CourseHeroSection
                      _buildHeroSection(course, isMobile),
                      const SizedBox(height: 32),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Coluna Principal
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 2. InstructorAuthorityCard
                                _buildInstructorCard(),
                                const SizedBox(height: 32),

                                // 3. CurriculumAccordion
                                const Text(
                                  "Grade Curricular",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: LawrenceColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildCurriculumAccordion(course),
                                const SizedBox(height: 32),

                                // 4. RequirementsSection
                                _buildRequirementsSection(course),
                              ],
                            ),
                          ),

                          if (!isMobile) ...[
                            const SizedBox(width: 32),
                            // Lateral fixa (Preview no Desktop)
                            Expanded(flex: 3, child: _buildSidebarSummary()),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 5. FloatingStickyCheckoutBar
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildFloatingCheckoutBar(course),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(Course course, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      padding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: LawrenceColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  course.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: LawrenceColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                course.title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: LawrenceColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                course.summary,
                style: const TextStyle(
                  fontSize: 13,
                  color: LawrenceColors.textSecondary,
                  height: 1.4,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),
              // HlsTrailerPlayer Placeholder
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LawrenceColors.borderMist),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white70,
                          child: Icon(
                            Icons.play_circle_fill,
                            color: LawrenceColors.primary,
                            size: 48,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Assistir ao Trailer de Introdução",
                          style: TextStyle(
                            color: LawrenceColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      padding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ariane Lawrence",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: LawrenceColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      "Mestra Alfaiate & Fundadora",
                      style: TextStyle(
                        fontSize: 12,
                        color: LawrenceColors.primary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Especializada em alfaiataria fina feminina por mais de 15 anos. Ensina técnicas tradicionais artesanais focadas no caimento perfeito em manequim.",
                      style: TextStyle(
                        fontSize: 12,
                        color: LawrenceColors.textSecondary,
                        height: 1.4,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurriculumAccordion(Course course) {
    if (course.modules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.28)),
        ),
        child: const Center(
          child: Text(
            "Nenhum módulo cadastrado para este curso.",
            style: TextStyle(color: LawrenceColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
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
            children: List.generate(course.modules.length, (index) {
              final module = course.modules[index];
              return Column(
                children: [
                  _buildAccordionTile(
                    "Módulo ${index + 1}: ${module.title}",
                    module.lessons
                        .map((lesson) => _buildLessonItem(lesson.title, true))
                        .toList(),
                  ),
                  if (index < course.modules.length - 1)
                    const Divider(
                      color: LawrenceColors.borderMist,
                      height: 1,
                      indent: 24,
                      endIndent: 24,
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionTile(String title, List<Widget> children) {
    return ExpansionTile(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: LawrenceColors.textPrimary,
      collapsedIconColor: LawrenceColors.textSecondary,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: LawrenceColors.textPrimary,
          fontFamily: 'Inter',
        ),
      ),
      children: children,
    );
  }

  Widget _buildLessonItem(String title, bool isUnlocked) {
    return ListTile(
      leading: Icon(
        isUnlocked ? Icons.play_circle_outline : Icons.lock_outline,
        color: isUnlocked
            ? LawrenceColors.primary
            : LawrenceColors.textSecondary.withOpacity(0.5),
        size: 18,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: isUnlocked
              ? LawrenceColors.textPrimary
              : LawrenceColors.textSecondary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildRequirementsSection(Course course) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      padding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Materiais e Requisitos Necessários",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: LawrenceColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.check, color: LawrenceColors.primary, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tecido encorpado (lã fria, crepe pesado ou linho estruturado, mínimo 2 metros).",
                      style: TextStyle(
                        fontSize: 13,
                        color: LawrenceColors.textSecondary,
                        height: 1.4,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.check, color: LawrenceColors.primary, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Máquina de costura reta convencional e ferro de passar industrial com vapor.",
                      style: TextStyle(
                        fontSize: 13,
                        color: LawrenceColors.textSecondary,
                        height: 1.4,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      padding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Este curso inclui:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: LawrenceColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryIconItem(
                Icons.ondemand_video,
                "12 horas de aulas gravadas",
              ),
              const SizedBox(height: 12),
              _buildSummaryIconItem(
                Icons.download,
                "Modelos PDF para download",
              ),
              const SizedBox(height: 12),
              _buildSummaryIconItem(
                Icons.workspace_premium,
                "Certificado de conclusão de Alta Costura",
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSummaryIconItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: LawrenceColors.primary, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: LawrenceColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingCheckoutBar(Course course) {
    return LiquidGlassContainer(
      borderRadius: 0,
      borderColor: LawrenceColors.borderMist.withOpacity(0.5),
      backgroundColor: Colors.white.withOpacity(0.72),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Plano de Assinatura Completo",
                style: TextStyle(
                  fontSize: 10,
                  color: LawrenceColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 2),
              Text(
                "R\$ 89,90 / mês",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: LawrenceColors.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LawrenceColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              context.go('/register');
            },
            child: const Text(
              "Comprar Curso",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
