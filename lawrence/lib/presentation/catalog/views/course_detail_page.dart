import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lawrence/core/theme.dart';
import 'package:lawrence/shared/widgets/liquid_glass_card.dart';
import 'package:lawrence/shared/widgets/liquid_glass_container.dart';

class CourseDetailPage extends StatefulWidget {
  final String slug;

  const CourseDetailPage({super.key, required this.slug});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      backgroundColor: LawrenceTheme.canvasParchment, // Fundo claro #F8F9FB
      body: Stack(
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
                  _buildHeroSection(isMobile),
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
                                fontFamily: 'Outfit',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: LawrenceTheme.surfaceTile1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCurriculumAccordion(),
                            const SizedBox(height: 32),

                            // 4. RequirementsSection
                            _buildRequirementsSection(),
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
            child: _buildFloatingCheckoutBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
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
                  color: LawrenceTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "ALFAIATARIA",
                  style: TextStyle(
                    fontSize: 10,
                    color: LawrenceTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Alfaiataria Feminina Fina: Blazers Estruturados",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: LawrenceTheme.surfaceTile1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Domine o corte sob medida de blazers clássicos, técnicas de ombreiras moldadas a mão e acabamentos manuais refinados.",
                style: TextStyle(
                  fontSize: 13,
                  color: LawrenceTheme.textSecondary,
                  height: 1.4,
                  fontFamily: 'Outfit',
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
                    border: Border.all(color: LawrenceTheme.borderMist),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white70,
                          child: Icon(
                            Icons.play_circle_fill,
                            color: LawrenceTheme.primary,
                            size: 48,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Assistir ao Trailer de Introdução",
                          style: TextStyle(
                            color: LawrenceTheme.surfaceTile1,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
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
                        color: LawrenceTheme.surfaceTile1,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      "Mestra Alfaiate & Fundadora",
                      style: TextStyle(
                        fontSize: 12,
                        color: LawrenceTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Especializada em alfaiataria fina feminina por mais de 15 anos. Ensina técnicas tradicionais artesanais focadas no caimento perfeito em manequim.",
                      style: TextStyle(
                        fontSize: 12,
                        color: LawrenceTheme.textSecondary,
                        height: 1.4,
                        fontFamily: 'Outfit',
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

  Widget _buildCurriculumAccordion() {
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
            children: [
              _buildAccordionTile("Módulo 1: Fundamentos de Modelagem", [
                _buildLessonItem(
                  "1. Introdução à Fita Métrica e Ergonomia",
                  true,
                ),
                _buildLessonItem("2. Traçado Base de Corpo de Blazer", true),
              ]),
              const Divider(
                color: LawrenceTheme.borderMist,
                height: 1,
                indent: 24,
                endIndent: 24,
              ),
              _buildAccordionTile("Módulo 2: Técnicas de Montagem", [
                _buildLessonItem("3. Corte no Viés e Linha de Fio", false),
                _buildLessonItem("4. Estruturação com Entretela Tecida", false),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccordionTile(String title, List<Widget> children) {
    return ExpansionTile(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      iconColor: LawrenceTheme.surfaceTile1,
      collapsedIconColor: LawrenceTheme.textSecondary,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: LawrenceTheme.surfaceTile1,
          fontFamily: 'Outfit',
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
            ? LawrenceTheme.primary
            : LawrenceTheme.textSecondary.withOpacity(0.5),
        size: 18,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: isUnlocked
              ? LawrenceTheme.surfaceTile1
              : LawrenceTheme.textSecondary,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }

  Widget _buildRequirementsSection() {
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
            children: const [
              Text(
                "Materiais e Requisitos Necessários",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: LawrenceTheme.surfaceTile1,
                  fontFamily: 'Outfit',
                ),
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, color: LawrenceTheme.primary, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tecido encorpado (lã fria, crepe pesado ou linho estruturado, mínimo 2 metros).",
                      style: TextStyle(
                        fontSize: 13,
                        color: LawrenceTheme.textSecondary,
                        height: 1.4,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, color: LawrenceTheme.primary, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Máquina de costura reta convencional e ferro de passar industrial com vapor.",
                      style: TextStyle(
                        fontSize: 13,
                        color: LawrenceTheme.textSecondary,
                        height: 1.4,
                        fontFamily: 'Outfit',
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
                  color: LawrenceTheme.surfaceTile1,
                  fontFamily: 'Outfit',
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
        Icon(icon, color: LawrenceTheme.primary, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: LawrenceTheme.textSecondary,
              fontFamily: 'Outfit',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingCheckoutBar() {
    return LiquidGlassContainer(
      borderRadius: 0,
      borderColor: LawrenceTheme.borderMist.withOpacity(0.5),
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
                  color: LawrenceTheme.textSecondary,
                  fontFamily: 'Outfit',
                ),
              ),
              SizedBox(height: 2),
              Text(
                "R\$ 89,90 / mês",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: LawrenceTheme.surfaceTile1,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LawrenceTheme.primary,
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
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
