import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/public/public_editorial_colors.dart';
import '../../../../design_system/public/public_editorial_footer.dart';
import '../widgets/editorial_home_primary_sections.dart';
import '../widgets/editorial_home_story_sections.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _methodKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openCourses() => context.go('/courses');

  void _openLogin() => context.go('/login');

  void _scrollToMethod() {
    final targetContext = _methodKey.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PublicEditorialColors.ivory,
      child: CustomScrollView(
        controller: _scrollController,
        semanticChildCount: 11,
        slivers: [
          SliverToBoxAdapter(
            child: MaisonHeroSection(
              onExplore: _openCourses,
              onMethod: _scrollToMethod,
            ),
          ),
          const SliverToBoxAdapter(child: TrustRibbonSection()),
          SliverToBoxAdapter(
            child: LearningPathsSection(onExplore: _openCourses),
          ),
          SliverToBoxAdapter(
            child: SignatureCourseSection(onExplore: _openCourses),
          ),
          SliverToBoxAdapter(
            child: KeyedSubtree(
              key: _methodKey,
              child: const LawrenceMethodSection(),
            ),
          ),
          const SliverToBoxAdapter(child: ClassicManifestoSection()),
          const SliverToBoxAdapter(child: LearningExperienceSection()),
          const SliverToBoxAdapter(child: FounderStorySection()),
          const SliverToBoxAdapter(child: HomeFaqSection()),
          SliverToBoxAdapter(
            child: FinalInvitationSection(
              onExplore: _openCourses,
              onLogin: _openLogin,
            ),
          ),
          const SliverToBoxAdapter(child: PublicEditorialFooter()),
        ],
      ),
    );
  }
}
