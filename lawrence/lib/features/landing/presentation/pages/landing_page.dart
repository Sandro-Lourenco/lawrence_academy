import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_container.dart';
import '../widgets/creator_story_section.dart';

const _navy = Color(0xFF081C2C);
const _ink = Color(0xFF0D2235);
const _ivory = Color(0xFFFAF8F3);
const _paper = Color(0xFFFFE5A3);
const _gold = Color(0xFFE9A126);
const _brown = Color(0xFF543A2F);
const _muted = Color(0xFF6F6A63);

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < LawrenceBreakpoints.tablet;
        return Column(
          children: [
            _Hero(mobile: mobile),
            const _EditorialStatement(),
            _CourseCollection(mobile: mobile),
            CreatorStorySection(mobile: mobile),
            _StudentCommunity(mobile: mobile),
            _EbookLibrary(mobile: mobile),
            _Method(mobile: mobile),
            _ClosingInvitation(mobile: mobile),
          ],
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  final bool mobile;

  const _Hero({required this.mobile});

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ColoredBox(
      color: _navy,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          mobile ? 24 : 64,
          mobile ? 38 : 54,
          mobile ? 24 : 64,
          mobile ? 48 : 72,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1360),
            child: mobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCopy(mobile: true, reduceMotion: reduceMotion),
                      const SizedBox(height: 42),
                      _HeroVisual(mobile: true, reduceMotion: reduceMotion),
                    ],
                  )
                : SizedBox(
                    height: 720,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _HeroCopy(
                            mobile: false,
                            reduceMotion: reduceMotion,
                          ),
                        ),
                        const SizedBox(width: 56),
                        Expanded(
                          flex: 7,
                          child: _HeroVisual(
                            mobile: false,
                            reduceMotion: reduceMotion,
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

class _HeroCopy extends StatelessWidget {
  final bool mobile;
  final bool reduceMotion;

  const _HeroCopy({required this.mobile, required this.reduceMotion});

  @override
  Widget build(BuildContext context) {
    return _Entrance(
      reduceMotion: reduceMotion,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('ALTA COSTURA. ALTA CONFIANÇA.', light: true),
          const SizedBox(height: 26),
          Text(
            'Vista a sua\nprópria história.',
            style: TextStyle(
              color: _ivory,
              fontFamily: 'Georgia',
              fontSize: mobile ? 58 : 88,
              height: 0.94,
              letterSpacing: mobile ? -2.8 : -4.2,
            ),
          ),
          const SizedBox(height: 30),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const Text(
              'Costura, modelagem e estilo ensinados com método, precisão e '
              'sensibilidade — para transformar habilidade em independência criativa.',
              style: TextStyle(
                color: Color(0xFFD7D4CD),
                fontSize: 18,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 38),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _GoldButton(
                label: 'Explorar o catálogo',
                onPressed: () => context.go('/courses'),
              ),
              _GlassButton(
                label: 'Conhecer a Lawrence',
                onPressed: () => _scrollToCreator(context),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Wrap(
            spacing: 28,
            runSpacing: 18,
            children: [
              _HeroProof('Método de ateliê'),
              _HeroProof('Projetos autorais'),
              _HeroProof('Aprenda no seu ritmo'),
            ],
          ),
        ],
      ),
    );
  }

  void _scrollToCreator(BuildContext context) {
    final target = creatorStoryKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }
}

class _HeroVisual extends StatelessWidget {
  final bool mobile;
  final bool reduceMotion;

  const _HeroVisual({required this.mobile, required this.reduceMotion});

  @override
  Widget build(BuildContext context) {
    return _Entrance(
      reduceMotion: reduceMotion,
      offset: 30,
      child: SizedBox(
        height: mobile ? 540 : double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: mobile ? 0 : 24,
              right: 0,
              top: 0,
              bottom: mobile ? 24 : 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(42),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/atelier_sewing.webp',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.4, 0),
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: _brown),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x8A081C2C)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: mobile ? 16 : -10,
              bottom: mobile ? 0 : 34,
              child: LiquidGlassContainer(
                width: mobile ? 264 : 310,
                blurSigma: 18,
                borderRadius: 30,
                padding: const EdgeInsets.all(22),
                backgroundColor: const Color(0x30101C26),
                fallbackColor: const Color(0xF0081C2C),
                borderColor: const Color(0x70FFFFFF),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, color: _paper, size: 20),
                    SizedBox(height: 20),
                    Text(
                      'DA IDEIA À PEÇA',
                      style: TextStyle(
                        color: _paper,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Técnica para criar com liberdade.',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Georgia',
                        fontSize: 24,
                        height: 1.15,
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
}

class _EditorialStatement extends StatelessWidget {
  const _EditorialStatement();

  @override
  Widget build(BuildContext context) {
    final mobile =
        MediaQuery.sizeOf(context).width < LawrenceBreakpoints.tablet;
    return ColoredBox(
      color: _ivory,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 24 : 64,
          vertical: mobile ? 82 : 132,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              children: [
                const _Eyebrow('CRIAR É UM ATO DE AUTORIA'),
                const SizedBox(height: 24),
                Text(
                  'Não ensinamos você a copiar uma peça.\n'
                  'Ensinamos você a construir uma visão.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ink,
                    fontFamily: 'Georgia',
                    fontSize: mobile ? 40 : 64,
                    height: 1.05,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Do primeiro risco ao acabamento final, cada escolha ganha intenção.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 17, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCollection extends StatelessWidget {
  final bool mobile;

  const _CourseCollection({required this.mobile});

  @override
  Widget build(BuildContext context) {
    const courses = [
      (
        '01',
        'Costura essencial',
        'Fundamentos, máquina, construção e acabamentos que elevam cada peça.',
        'assets/images/atelier_sewing.webp',
      ),
      (
        '02',
        'Modelagem autoral',
        'Bases, volumes e proporções para transformar desenho em forma.',
        'assets/images/pattern_drafting.webp',
      ),
      (
        '03',
        'Moda & estilo',
        'Repertório visual, identidade e direção para comunicar quem você é.',
        'assets/images/landing_hero.webp',
      ),
    ];

    return ColoredBox(
      color: const Color(0xFFF0ECE4),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 24 : 64,
          vertical: mobile ? 76 : 112,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeading(
                  eyebrow: 'EXPLORE O CATÁLOGO',
                  title: 'Escolha por onde\ncomeçar a sua evolução.',
                  mobile: mobile,
                  action: _TextAction(
                    label: 'Ver todos os cursos',
                    onPressed: () => context.go('/courses'),
                  ),
                ),
                const SizedBox(height: 52),
                if (mobile)
                  ...courses.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: _CourseCard(item: item),
                    ),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: courses
                        .map(
                          (item) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 18),
                              child: _CourseCard(item: item),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatefulWidget {
  final (String, String, String, String) item;

  const _CourseCard({required this.item});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Explorar ${widget.item.$2}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => context.go('/courses'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, _hovered ? -10 : 0, 0),
            height: 520,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _navy.withValues(alpha: _hovered ? 0.18 : 0.08),
                  blurRadius: _hovered ? 40 : 20,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedScale(
                    scale: _hovered ? 1.04 : 1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    child: Image.asset(
                      widget.item.$4,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: _brown),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x08000000), Color(0xE5081C2C)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.$1,
                          style: const TextStyle(
                            color: _paper,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.item.$2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Georgia',
                            fontSize: 34,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.item.$3,
                          style: const TextStyle(
                            color: Color(0xFFD7DDE0),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Row(
                          children: [
                            Text(
                              'Explorar trilha',
                              style: TextStyle(
                                color: _paper,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 9),
                            Icon(Icons.arrow_outward, color: _paper, size: 18),
                          ],
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

class _StudentCommunity extends StatelessWidget {
  final bool mobile;

  const _StudentCommunity({required this.mobile});

  @override
  Widget build(BuildContext context) {
    const outcomes = [
      (
        Icons.content_cut,
        'Mais segurança no fazer',
        'Compreender o processo para costurar com intenção, não por tentativa.',
      ),
      (
        Icons.architecture_outlined,
        'Projetos que ganham forma',
        'Organizar ideias, construir moldes e finalizar peças com mais autonomia.',
      ),
      (
        Icons.auto_awesome_outlined,
        'Uma assinatura própria',
        'Desenvolver repertório e confiança para criar além das referências.',
      ),
    ];

    return ColoredBox(
      color: _navy,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 24 : 64,
          vertical: mobile ? 78 : 118,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              children: [
                const _Eyebrow('ALUNAS EM MOVIMENTO', light: true),
                const SizedBox(height: 22),
                Text(
                  'Uma comunidade que\naprende fazendo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ivory,
                    fontFamily: 'Georgia',
                    fontSize: mobile ? 44 : 66,
                    height: 1.03,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'A experiência Lawrence foi desenhada para acompanhar diferentes '
                  'pontos de partida e transformar prática em evolução visível.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFC8D0D5),
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 54),
                if (mobile)
                  ...outcomes.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _OutcomeCard(item: item),
                    ),
                  )
                else
                  Row(
                    children: outcomes
                        .map(
                          (item) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: _OutcomeCard(item: item),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 30),
                const Text(
                  'Depoimentos identificados serão publicados com autorização das alunas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  final (IconData, String, String) item;

  const _OutcomeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.$1, color: _gold, size: 28),
          const SizedBox(height: 38),
          Text(
            item.$2,
            style: const TextStyle(
              color: _ivory,
              fontFamily: 'Georgia',
              fontSize: 25,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            item.$3,
            style: const TextStyle(
              color: Color(0xFFB7C1C8),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _EbookLibrary extends StatelessWidget {
  final bool mobile;

  const _EbookLibrary({required this.mobile});

  @override
  Widget build(BuildContext context) {
    const books = [
      ('01', 'Fundamentos\nda forma', _brown),
      ('02', 'Caderno de\nmodelagem', _ink),
      ('03', 'Repertório\nde estilo', Color(0xFF8A5B20)),
    ];

    return ColoredBox(
      color: _paper,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 24 : 64,
          vertical: mobile ? 78 : 118,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: mobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _LibraryCopy(mobile: true),
                      const SizedBox(height: 48),
                      _BookShelf(books: books, mobile: true),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(
                        flex: 5,
                        child: _LibraryCopy(mobile: false),
                      ),
                      const SizedBox(width: 70),
                      Expanded(
                        flex: 7,
                        child: _BookShelf(books: books, mobile: false),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _LibraryCopy extends StatelessWidget {
  final bool mobile;

  const _LibraryCopy({required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow('BIBLIOTECA DA AUTORA'),
        const SizedBox(height: 22),
        Text(
          'Conhecimento para continuar criando.',
          style: TextStyle(
            color: _ink,
            fontFamily: 'Georgia',
            fontSize: mobile ? 44 : 62,
            height: 1.02,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Guias digitais da criadora da Lawrence para consultar no ateliê, '
          'aprofundar conceitos e registrar o seu próprio processo.',
          style: TextStyle(color: _brown, fontSize: 17, height: 1.6),
        ),
        const SizedBox(height: 28),
        const Text(
          'COLEÇÃO EM PREPARAÇÃO',
          style: TextStyle(
            color: _brown,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
          ),
        ),
      ],
    );
  }
}

class _BookShelf extends StatelessWidget {
  final List<(String, String, Color)> books;
  final bool mobile;

  const _BookShelf({required this.books, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: mobile ? 360 : 430,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: books
            .map(
              (book) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Transform.rotate(
                    angle: book.$1 == '02'
                        ? 0
                        : (book.$1 == '01' ? -0.035 : 0.035),
                    child: Container(
                      height: book.$1 == '02'
                          ? (mobile ? 350 : 420)
                          : (mobile ? 325 : 390),
                      padding: EdgeInsets.all(mobile ? 16 : 24),
                      decoration: BoxDecoration(
                        color: book.$3,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        border: Border.all(color: Colors.white24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 28,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LAWRENCE',
                            style: TextStyle(
                              color: _paper,
                              fontSize: mobile ? 8 : 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            book.$2,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Georgia',
                              fontSize: mobile ? 20 : 28,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(height: 1, color: Colors.white38),
                          const SizedBox(height: 12),
                          Text(
                            'CADERNO ${book.$1}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Method extends StatelessWidget {
  final bool mobile;

  const _Method({required this.mobile});

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('01', 'Observe', 'Treine o olhar e compreenda cada escolha.'),
      ('02', 'Construa', 'Transforme técnica em gesto e projeto.'),
      ('03', 'Assine', 'Refine uma linguagem que seja reconhecida como sua.'),
    ];
    return ColoredBox(
      color: _ivory,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 24 : 64,
          vertical: mobile ? 78 : 118,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              children: [
                const _Eyebrow('O MÉTODO LAWRENCE'),
                const SizedBox(height: 22),
                Text(
                  'Clareza para aprender.\nLiberdade para criar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ink,
                    fontFamily: 'Georgia',
                    fontSize: mobile ? 43 : 64,
                    height: 1.04,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 60),
                if (mobile)
                  ...steps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 34),
                      child: _MethodStep(step: step),
                    ),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: steps
                        .map((step) => Expanded(child: _MethodStep(step: step)))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodStep extends StatelessWidget {
  final (String, String, String) step;

  const _MethodStep({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          Text(
            step.$1,
            style: const TextStyle(
              color: _gold,
              fontFamily: 'Georgia',
              fontSize: 44,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: const Color(0x22543A2F)),
          const SizedBox(height: 24),
          Text(
            step.$2,
            style: const TextStyle(
              color: _ink,
              fontFamily: 'Georgia',
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.$3,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ClosingInvitation extends StatelessWidget {
  final bool mobile;

  const _ClosingInvitation({required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _navy,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: mobile ? 84 : 124,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            children: [
              const _Eyebrow('O PRÓXIMO CAPÍTULO É SEU', light: true),
              const SizedBox(height: 24),
              Text(
                'Crie com técnica.\nVista com presença.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ivory,
                  fontFamily: 'Georgia',
                  fontSize: mobile ? 52 : 78,
                  height: 0.98,
                  letterSpacing: -3,
                ),
              ),
              const SizedBox(height: 34),
              _GoldButton(
                label: 'Encontrar meu curso',
                onPressed: () => context.go('/courses'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  final Widget child;
  final bool reduceMotion;
  final double offset;

  const _Entrance({
    required this.child,
    required this.reduceMotion,
    this.offset = 22,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final bool mobile;
  final Widget? action;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.mobile,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(eyebrow),
        const SizedBox(height: 18),
        Text(
          title,
          style: TextStyle(
            color: _ink,
            fontFamily: 'Georgia',
            fontSize: mobile ? 42 : 58,
            height: 1.03,
            letterSpacing: -1.8,
          ),
        ),
      ],
    );
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          copy,
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: copy),
        ?action,
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String label;
  final bool light;

  const _Eyebrow(this.label, {this.light = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: light ? _gold : _brown,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.9,
      ),
    );
  }
}

class _HeroProof extends StatelessWidget {
  final String label;

  const _HeroProof(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: _gold, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GoldButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size(210, 56),
        backgroundColor: _gold,
        foregroundColor: _navy,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.arrow_outward, size: 18),
      label: Text(label),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GlassButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      borderRadius: 999,
      blurSigma: 14,
      backgroundColor: const Color(0x18FFFFFF),
      fallbackColor: const Color(0xFF183246),
      borderColor: const Color(0x52FFFFFF),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: _ivory,
          minimumSize: const Size(210, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _TextAction({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.arrow_forward, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: _brown,
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}
