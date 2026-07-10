import 'package:flutter/material.dart';

class ReferralGoldCard extends StatefulWidget {
  final VoidCallback onTap;

  const ReferralGoldCard({
    super.key,
    required this.onTap,
  });

  @override
  State<ReferralGoldCard> createState() => _ReferralGoldCardState();
}

class _ReferralGoldCardState extends State<ReferralGoldCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_scale, _scale, 1.0),
        transformAlignment: Alignment.center,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF0D399), // Dourado claro editorial
                Color(0xFFC69C4E), // Dourado escuro
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // Avatar circular
              const CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
              ),
              const SizedBox(width: 16),
              
              // Textos descritivos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Indique e Ganhe',
                      style: TextStyle(
                        color: Color(0xFF332005),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Compartilhe com amigas e ganhe descontos na sua mensalidade!',
                      style: TextStyle(
                        color: Color(0xFF5A3E10),
                        fontSize: 11,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
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
}
