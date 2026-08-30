import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../shared/widgets/golden_editorial_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(
        0xFF000000,
      ), // Base color starts black for Hero
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroSection(isMobile)),
          SliverToBoxAdapter(child: _buildHistorySection(isMobile)),
          SliverToBoxAdapter(child: _buildCoursesSection(isMobile)),
          SliverToBoxAdapter(child: _buildFooterSection()),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF000000),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 120,
        vertical: 140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                "Um encontro\ncom a arte\nda costura",
                style: GoogleFonts.playfairDisplay(
                  fontSize: isMobile ? 64 : 127,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -3.8,
                  height: 0.9,
                  color: Colors.white,
                ),
              )
              .animate()
              .fadeIn(duration: 1000.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
          const SizedBox(height: 60),
          GoldenEditorialButton(
            text: "Cursos",
            onPressed: () {},
          ).animate().fadeIn(delay: 500.ms, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildHistorySection(bool isMobile) {
    return Container(
      color: const Color(0xFFF4EFE6), // Light beige background
      padding: const EdgeInsets.only(top: 185, bottom: 280),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top part: "10" and "anos de história e tradição"
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 40,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFBF953F),
                          Color(0xFFFCF6BA),
                          Color(0xFFB38728),
                          Color(0xFFFBF5B7),
                          Color(0xFFAA771C),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        "10",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isMobile ? 180 : 380,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                          letterSpacing: -15,
                          color: Colors
                              .white, // Color doesn't matter for ShaderMask srcIn
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
                    Text(
                          "anos de\nhistória\ne tradição",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: isMobile ? 60 : 130,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            height: 0.9,
                            letterSpacing: -2,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .slideX(begin: 0.2),
                  ],
                ),
                const SizedBox(
                  height: 120,
                ), // Spacing between Hero text and bottom paragraphs
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(
                                    0xFF333333,
                                  ).withOpacity(0.2),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "Desde 2015",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildParagraph(
                            "Ao completar 10 anos de vida, a Lawrence Academy aprofunda o olhar para a arte da costura e inaugura um novo capítulo. Nesta nova fase, o ato de costurar se estende à modelagem, criação, moulage, entre outras inúmeras manifestações artísticas da moda.",
                          ),
                          const SizedBox(height: 20),
                          _buildParagraph(
                            "A nova Lawrence Academy traz a moda para todos! Disseminando, atualizando e promovendo um verdadeiro intercâmbio para os amantes do design e da alta-costura.",
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(
                                      0xFF333333,
                                    ).withOpacity(0.2),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Desde 2015",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(width: 60),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildParagraph(
                                  "Ao completar 10 anos de vida, a Lawrence Academy aprofunda o olhar para a arte da costura e inaugura um novo capítulo. Nesta nova fase, o ato de costurar se estende à modelagem, criação, moulage, entre outras inúmeras manifestações artísticas da moda.",
                                ),
                                const SizedBox(height: 20),
                                _buildParagraph(
                                  "A nova Lawrence Academy traz a moda para todos! Disseminando, atualizando e promovendo um verdadeiro intercâmbio para os amantes do design e da alta-costura.",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF333333),
        height: 1.42,
      ),
    );
  }

  Widget _buildCoursesSection(bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 120,
        vertical: 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cursos",
            style: GoogleFonts.playfairDisplay(
              fontSize: isMobile ? 48 : 80,
              color: Colors.black87,
              height: 1.0,
            ),
          ).animate().slideX(begin: -0.1, curve: Curves.easeOut).fadeIn(),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final bool stackVertical = width < 800;

              return Flex(
                direction: stackVertical ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: stackVertical ? 0 : 1,
                    child: _buildCourseCard(
                      title: "ALFAIATARIA\nFEMININA FINA",
                      description:
                          "O curso tem carga horária progressiva e conteúdos que apresentam desafios constantes. A prática exige disciplina e muita determinação.",
                    ),
                  ),
                  SizedBox(
                    width: stackVertical ? 0 : 60,
                    height: stackVertical ? 60 : 0,
                  ),
                  Expanded(
                    flex: stackVertical ? 0 : 1,
                    child: Padding(
                      padding: EdgeInsets.only(top: stackVertical ? 0 : 80),
                      child: _buildCourseCard(
                        title: "MOULAGE E\nDRAPING",
                        description:
                            "Aprenda a arte de esculpir roupas diretamente no manequim, explorando volumes e texturas da alta-costura contemporânea.",
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 400,
          color: const Color(0xFFF0F0F0),
          child: const Center(
            child: Icon(Icons.image, color: Colors.black12, size: 48),
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1),
        const SizedBox(height: 32),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          description,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        GoldenEditorialButton(text: "CONHEÇA O CURSO", onPressed: () {}),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      child: Column(
        children: [
          Text(
            "LAWRENCE ACADEMY",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 4.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "(11) 97374-7700\ncontato@lawrenceacademy.com.br",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              height: 1.8,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 60),
          Text(
            "© 2026 Lawrence Academy. Todos os direitos reservados.",
            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
