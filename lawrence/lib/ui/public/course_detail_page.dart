import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class CourseDetailPage extends StatefulWidget {
  final String slug;

  const CourseDetailPage({super.key, required this.slug});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 120,
            ), // Espaço para a barra flutuante inferior
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CourseHeroSection
                _buildHeroSection(isMobile),
                const SizedBox(height: 40),

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
                          const SizedBox(height: 40),

                          // 3. CurriculumAccordion
                          const Text(
                            "Grade Curricular",
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCurriculumAccordion(),
                          const SizedBox(height: 40),

                          // 4. RequirementsSection
                          _buildRequirementsSection(),
                        ],
                      ),
                    ),

                    if (!isMobile) ...[
                      const SizedBox(width: 40),
                      // Lateral fixa (Preview no Desktop)
                      Expanded(flex: 3, child: _buildSidebarSummary()),
                    ],
                  ],
                ),
              ],
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
      decoration: LiquidTheme.glassDecoration(radius: 20),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LiquidTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "ALFAIATARIA",
              style: TextStyle(
                fontSize: 10,
                color: LiquidTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Alfaiataria Feminina Fina: Blazers Estruturados",
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Domine o corte sob medida de blazers clássicos, técnicas de ombreiras moldadas a mão e acabamentos manuais refinados.",
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 24),
          // HlsTrailerPlayer Placeholder
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      color: LiquidTheme.primary,
                      size: 54,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Assistir ao Trailer de Introdução",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorCard() {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto Pill
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(35),
            ),
            child: const Icon(Icons.person, color: Colors.white54, size: 36),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ariane Lawrence",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Mestra Alfaiate & Fundadora",
                  style: TextStyle(fontSize: 12, color: LiquidTheme.primary),
                ),
                SizedBox(height: 8),
                Text(
                  "Especializada em alfaiataria fina feminina por mais de 15 anos. Ensina técnicas tradicionais artesanais focadas no caimento perfeito em manequim.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumAccordion() {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _buildAccordionTile("Módulo 1: Fundamentos de Modelagem", [
              _buildLessonItem(
                "1. Introdução à Fita Métrica e Ergonomia",
                true,
              ),
              _buildLessonItem("2. Traçado Base de Corpo de Blazer", true),
            ]),
            const Divider(color: Colors.white10, height: 1),
            _buildAccordionTile("Módulo 2: Técnicas de Montagem", [
              _buildLessonItem("3. Corte no Viés e Linha de Fio", false),
              _buildLessonItem("4. Estruturação com Entretela Tecida", false),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionTile(String title, List<Widget> children) {
    return ExpansionTile(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      children: children,
    );
  }

  Widget _buildLessonItem(String title, bool isUnlocked) {
    return ListTile(
      leading: Icon(
        isUnlocked ? Icons.play_circle_outline : Icons.lock_outline,
        color: isUnlocked ? LiquidTheme.secondary : Colors.white24,
        size: 18,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: isUnlocked ? Colors.white : Colors.white30,
        ),
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Materiais e Requisitos Necessários",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check, color: LiquidTheme.primary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Tecido encorpado (lã fria, crepe pesado ou linho estruturado, mínimo 2 metros).",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check, color: LiquidTheme.primary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Máquina de costura reta convencional e ferro de passar industrial com vapor.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarSummary() {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Este curso inclui:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryIconItem(
            Icons.ondemand_video,
            "12 horas de aulas gravadas",
          ),
          const SizedBox(height: 12),
          _buildSummaryIconItem(Icons.download, "Modelos PDF para download"),
          const SizedBox(height: 12),
          _buildSummaryIconItem(
            Icons.workspace_premium,
            "Certificado de conclusão de Alta Costura",
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryIconItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: LiquidTheme.primary, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingCheckoutBar() {
    return Container(
      height: 76,
      decoration: LiquidTheme.glassDecoration(
        blurOpacity: 0.15,
        borderOpacity: 0.20,
        radius: 0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Plano de Assinatura Completo",
                style: TextStyle(fontSize: 11, color: Colors.white60),
              ),
              Text(
                "R\$ 89,90 / mês",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LiquidTheme.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.go('/register');
            },
            child: const Text(
              "Comprar Curso",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
