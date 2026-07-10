import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. HeroSection: Fundo branco puro, título editorial XL
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
          child: Column(
            children: [
              const Text(
                "A ARTE DA ALTA COSTURA",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: LiquidTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Aprenda Modelagem e Alfaiataria sob Medida",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: isMobile ? 32 : 64,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  color: Colors.black,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: const Text(
                    "Desenvolva técnica e precisão artesanal em peças estruturadas. Do caimento perfeito em seda à construção de casacos forrados com metodologia profissional de ateliê.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A84FF), // Azul premium
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () => context.go('/courses'),
                child: const Text(
                  "Explorar Cursos",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // 2. ValuePropositionTile: Fundo pergaminho (#F8F9FB) em 3 colunas
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nossa Metodologia",
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              isMobile
                  ? Column(
                      children: [
                        _buildPropItem(
                          "Modelagem Tridimensional",
                          "Técnicas de moulage e draping aplicadas diretamente ao manequim para criar volumes orgânicos e precisos.",
                        ),
                        const SizedBox(height: 24),
                        _buildPropItem(
                          "Alfaiataria Clássica",
                          "Construção de casacos e calças com acabamentos de alfaiataria italiana e reforços de entretela tecida.",
                        ),
                        const SizedBox(height: 24),
                        _buildPropItem(
                          "Modelagem Industrial",
                          "Criação, gradação e adaptação de tabelas de medidas universais para produção em pequena e grande escala.",
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildPropItem(
                            "Modelagem Tridimensional",
                            "Técnicas de moulage e draping aplicadas diretamente ao manequim para criar volumes orgânicos e precisos.",
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: _buildPropItem(
                            "Alfaiataria Clássica",
                            "Construção de casacos e calças com acabamentos de alfaiataria italiana e reforços de entretela tecida.",
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: _buildPropItem(
                            "Modelagem Industrial",
                            "Criação, gradação e adaptação de tabelas de medidas universais para produção em pequena e grande escala.",
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // 3. FeaturedCoursesSection: Cartões de Destaque
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cursos em Destaque",
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            isMobile
                ? Column(
                    children: [
                      _buildFeatureCard(
                        context,
                        "Alfaiataria Feminina Fina",
                        "Aprenda a estruturar blazers forrados com ombreiras e golas entreteladas.",
                        "iniciante",
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context,
                        "Moulage e Draping na Seda",
                        "Manipulação tridimensional de cetins e sedas em cortes enviesados.",
                        "avancado",
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          "Alfaiataria Feminina Fina",
                          "Aprenda a estruturar blazers forrados com ombreiras e golas entreteladas.",
                          "iniciante",
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          "Moulage e Draping na Seda",
                          "Manipulação tridimensional de cetins e sedas em cortes enviesados.",
                          "avancado",
                        ),
                      ),
                    ],
                  ),
          ],
        ),

        const SizedBox(height: 48),

        // 4. SocialProofSection: Depoimentos de alunos e estrelas
        Container(
          padding: const EdgeInsets.all(40),
          decoration: LiquidTheme.glassDecoration(radius: 20),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  Icon(Icons.star, color: Colors.amber, size: 24),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "\"O curso de Alfaiataria mudou completamente a qualidade do meu trabalho. O caimento dos meus blazers finalmente alcançou o padrão de loja fina.\"",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Mariana Silveira • Aluna Certificada",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String summary,
    String level,
  ) {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LiquidTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  level.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: LiquidTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.bookmark_border,
                color: Colors.white54,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: LiquidTheme.secondary,
              padding: EdgeInsets.zero,
            ),
            onPressed: () => context.go('/courses'),
            child: const Row(
              children: [
                Text(
                  "Ver Detalhes",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
