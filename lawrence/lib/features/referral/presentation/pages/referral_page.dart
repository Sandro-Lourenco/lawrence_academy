import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_card.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String referralCode = "LAWRENCE-AB45K9";

    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      appBar: AppBar(
        title: const Text(
          "INDIQUE E GANHE",
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.72),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Referral Hero
            _buildHero(context),
            const SizedBox(height: 32),

            // 2. Referral Code Card
            _buildCodeCard(context, referralCode),
            const SizedBox(height: 32),

            // 3. Benefits Section
            const Text(
              "Como funciona?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: LawrenceColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              "1",
              "Compartilhe seu link",
              "Envie seu código exclusivo para amigas que amam costura.",
            ),
            _buildStep(
              context,
              "2",
              "Sua amiga se inscreve",
              "Ela ganha um desconto especial na primeira assinatura.",
            ),
            _buildStep(
              context,
              "3",
              "Você ganha recompensas",
              "Receba créditos e meses gratuitos conforme elas evoluem.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [LawrenceColors.primary, Color(0xFF0056B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LawrenceTheme.AppRadiusLarge),
      ),
      child: Column(
        children: const [
          Icon(Icons.stars_rounded, size: 64, color: Colors.white),
          SizedBox(height: 16),
          Text(
            "Convide amigas e ganhe meses grátis!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Espalhe a arte da costura e seja recompensada por cada nova aluna que entrar na nossa comunidade.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(BuildContext context, String code) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Seu Código Exclusivo",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: LawrenceColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: LawrenceColors.canvas,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LawrenceColors.borderMist),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: LawrenceColors.primary,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Código copiado!")),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text("COPIAR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LawrenceColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Integrar com Share Plugin futuramente
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text("COMPARTILHAR"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LawrenceColors.textPrimary,
                    side: const BorderSide(color: LawrenceColors.borderMist),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    String number,
    String title,
    String desc,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: LawrenceColors.accentGold,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LawrenceColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: LawrenceColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
