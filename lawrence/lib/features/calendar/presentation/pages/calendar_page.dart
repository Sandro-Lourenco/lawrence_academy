import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/tokens/lawrence_theme.dart';
import '../../../../design_system/widgets/liquid_glass_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LawrenceColors.canvasParchment,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context),

          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMonthSelector(),
                const SizedBox(height: 24),
                _buildMiniCalendar(),
                const SizedBox(height: 32),
                const Text(
                  "Agenda do Dia",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: LawrenceColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildEventList(),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.white.withOpacity(0.72),
            child: const Center(
              child: Text(
                "CALENDÁRIO",
                style: TextStyle(
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: LawrenceColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate).toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: LawrenceColors.primary,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: LawrenceColors.textPrimary,
              ),
              onPressed: () => setState(
                () => _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.chevron_right,
                color: LawrenceColors.textPrimary,
              ),
              onPressed: () => setState(
                () => _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCalendar() {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                .map(
                  (day) => Text(
                    day,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: LawrenceColors.textSecondary,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // Simplified grid for visual placeholder
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isToday =
                  day == DateTime.now().day &&
                  _selectedDate.month == DateTime.now().month;
              return Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isToday
                        ? LawrenceColors.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "$day",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isToday
                            ? Colors.white
                            : LawrenceColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return Column(
      children: [
        _buildEventItem(
          "09:00",
          "Live: Modelagem Feminina",
          "Ajustes de Molde",
          LawrenceColors.success,
        ),
        _buildEventItem(
          "14:30",
          "Prazo: Quiz de Costura",
          "Módulo 3",
          LawrenceColors.danger,
        ),
        _buildEventItem(
          "19:00",
          "Mentoria Coletiva",
          "Dúvidas sobre tecidos",
          LawrenceColors.primary,
        ),
      ],
    );
  }

  Widget _buildEventItem(
    String time,
    String title,
    String subtitle,
    Color indicatorColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: LawrenceColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LawrenceColors.borderMist),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(2),
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: LawrenceColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
