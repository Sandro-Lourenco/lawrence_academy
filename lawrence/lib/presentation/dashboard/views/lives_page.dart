import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lawrence/core/theme.dart';
import 'package:lawrence/shared/widgets/liquid_glass_card.dart';

class LivesPage extends StatelessWidget {
  const LivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final upcomingLives = [
      {
        'title': 'Modelagem Avançada de Ombros e Mangas Puff',
        'instructor': 'Ariane Lawrence',
        'datetime': 'Amanhã, às 19:30',
        'tag': 'Live VIP',
      },
      {
        'title': 'Modelagem Tridimensional e Draping',
        'instructor': 'Ariane Lawrence',
        'datetime': '12 de Julho, às 20:00',
        'tag': 'Masterclass',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transmissões ao Vivo',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: LawrenceTheme.surfaceTile1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acompanhe as mentorias exclusivas e tire suas dúvidas em tempo real.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: LawrenceTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ...upcomingLives.map((live) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: LiquidGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: LawrenceTheme.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              live['tag']!,
                              style: const TextStyle(
                                color: LawrenceTheme.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            live['datetime']!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: LawrenceTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        live['title']!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: LawrenceTheme.surfaceTile1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: LawrenceTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Instrutor: ${live['instructor']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sala de mentoria abrirá 10 minutos antes da transmissão.',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LawrenceTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.videocam_outlined),
                        label: const Text('Entrar na Transmissão'),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
