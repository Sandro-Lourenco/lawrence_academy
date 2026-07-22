import 'package:flutter/material.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class DashboardHeader extends StatelessWidget {
  final String studentName;

  const DashboardHeader({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'LAWRENCE',
                  style: TextStyle(
                    letterSpacing: 2.0,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: LawrenceColors.textPrimary,
                  ),
                ),
                Text(
                  'ACADEMY',
                  style: TextStyle(
                    letterSpacing: 1.2,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: LawrenceColors.accentGold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: LawrenceColors.textPrimary,
                  ),
                  onPressed: () {
                    context.go('/dashboard/search');
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.bookmark_border_rounded,
                    color: LawrenceColors.textPrimary,
                  ),
                  onPressed: () {
                    context.go('/dashboard/favorites');
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.emoji_events_outlined,
                    color: LawrenceColors.textPrimary,
                  ),
                  onPressed: () {
                    context.go('/dashboard/achievements');
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: LawrenceColors.textPrimary,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Nenhuma notificação nova no momento."),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          "Bem-vinda de volta, $studentName! 👋",
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          "Continue aprendendo e aprimorando suas técnicas.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
