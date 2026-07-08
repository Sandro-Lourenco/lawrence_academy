import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/subscription_provider.dart';
import '../../data/repositories.dart';
import '../theme.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(subscriptionFutureProvider);
    final coursesAsync = ref.watch(courseRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Banner Flutuante de Carência (Grace Period)
            subAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
              data: (sub) {
                if (sub != null && sub.isInGracePeriod) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: LiquidTheme.glassDecoration(
                        blurOpacity: 0.15,
                        borderOpacity: 0.25,
                        radius: 12,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        color: LiquidTheme.warningPastel.withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: LiquidTheme.warningPastel, size: 24),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Atenção com a sua assinatura",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: LiquidTheme.warningPastel,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Houve um problema com sua cobrança recente. Suas aulas estão liberadas temporariamente. Atualize seus dados de faturamento antes que seu acesso seja suspenso.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: LiquidTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LiquidTheme.warningPastel,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onPressed: () {
                                // Redirecionar para o portal do Stripe
                              },
                              child: const Text(
                                "Atualizar Cartão",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // 2. Layout Responsivo de Conteúdo
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Builder(
                builder: (context) {
                  final isDesktop = MediaQuery.of(context).size.width >= 900;
                  
                  final leftColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card de Onboarding (Se for novo aluno)
                      _buildOnboardingCard(),
                      const SizedBox(height: 24),

                      // Card de Continuar Assistindo (Zeigarnik progress)
                      _buildContinueWatchingCard(context),
                      const SizedBox(height: 32),

                      const Text(
                        "Minhas Próximas Atividades",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: LiquidTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActivityCalendar(),
                    ],
                  );

                  final rightColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Widget de Indicação Premium Dourado
                      _buildReferralCard(),
                      const SizedBox(height: 24),

                      // Transmissões de Ateliê ao Vivo
                      _buildLiveSessionsCard(),
                    ],
                  );

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: leftColumn),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: rightColumn),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leftColumn,
                        const SizedBox(height: 24),
                        rightColumn,
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingCard() {
    return Container(
      width: double.infinity,
      decoration: LiquidTheme.glassDecoration(
        blurOpacity: 0.10,
        borderOpacity: 0.12,
        radius: 16,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LiquidTheme.auraGradient.createShader(bounds),
            child: const Text(
              "Bem-vinda de volta à Alta Costura",
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Sua jornada na Lawrence Academy está apenas começando. Que tal explorar novas técnicas de modelagem hoje?",
            style: TextStyle(fontSize: 13, color: LiquidTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: LiquidTheme.glassDecoration(
        blurOpacity: 0.06,
        borderOpacity: 0.08,
        radius: 16,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CONTINUAR ASSISTINDO",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: LiquidTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_circle_fill, color: LiquidTheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Modelagem Básica: Montagem da Pense de Busto",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: LiquidTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Módulo 1 - Aula 3 • Faltam 12 minutos",
                      style: TextStyle(fontSize: 12, color: LiquidTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    // Progresso Linear
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(LiquidTheme.primary),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCalendar() {
    return Container(
      width: double.infinity,
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildActivityItem("Hoje, 14:00", "Live Mentoria: Revisão de Moldes de Alfaiataria", true),
          const Divider(color: Colors.white10),
          _buildActivityItem("Amanhã, 09:00", "Prazo: Envio da Tarefa Prática do Módulo 2", false),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String date, String title, bool isActive) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? LiquidTheme.primary.withOpacity(0.1) : Colors.white.withOpacity(0.02),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? Icons.calendar_today : Icons.schedule,
          color: isActive ? LiquidTheme.primary : LiquidTheme.textSecondary,
          size: 18,
        ),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: LiquidTheme.textPrimary)),
      subtitle: Text(date, style: const TextStyle(fontSize: 11, color: LiquidTheme.textSecondary)),
    );
  }

  Widget _buildReferralCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LiquidTheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LiquidTheme.accentGold.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: LiquidTheme.accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                "INDIQUE E GANHE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: LiquidTheme.accentGold.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Indique um amigo para a Lawrence Academy. Ele ganha 10% de desconto na primeira fatura e você recebe R\$ 20,00 de saldo na próxima fatura!",
            style: TextStyle(fontSize: 12, color: LiquidTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: LiquidTheme.accentGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () {},
            child: const Text("Copiar Link de Indicação", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSessionsCard() {
    return Container(
      width: double.infinity,
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "ATELIÊ AO VIVO",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: LiquidTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Modelagem Tridimensional com Draping na Seda",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: LiquidTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            "Com Ariane Lawrence • Transmitindo agora",
            style: TextStyle(fontSize: 11, color: LiquidTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: LiquidTheme.primary,
              padding: EdgeInsets.zero,
            ),
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined, size: 18),
            label: const Text("Entrar na Sala", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
