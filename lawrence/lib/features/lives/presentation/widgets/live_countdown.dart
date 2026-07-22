import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../design_system/tokens/lawrence_theme.dart';

class LiveCountdown extends StatefulWidget {
  final DateTime scheduledFor;

  const LiveCountdown({super.key, required this.scheduledFor});

  @override
  State<LiveCountdown> createState() => _LiveCountdownState();
}

class _LiveCountdownState extends State<LiveCountdown> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    if (widget.scheduledFor.isAfter(now)) {
      setState(() {
        _timeLeft = widget.scheduledFor.difference(now);
      });
    } else {
      setState(() {
        _timeLeft = Duration.zero;
      });
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft == Duration.zero) return const SizedBox.shrink();

    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours.remainder(24);
    final minutes = _timeLeft.inMinutes.remainder(60);
    // final seconds = _timeLeft.inSeconds.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (days > 0) ...[
          _buildTimeBlock(days.toString().padLeft(2, '0'), 'DIAS'),
          _buildSeparator(),
        ],
        _buildTimeBlock(hours.toString().padLeft(2, '0'), 'HORAS'),
        _buildSeparator(),
        _buildTimeBlock(minutes.toString().padLeft(2, '0'), 'MIN'),
      ],
    );
  }

  Widget _buildTimeBlock(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: LawrenceTheme.surfaceTile1,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LawrenceTheme.borderMist),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontFamily: 'Outfit',
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: LawrenceTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        children: [
          Text(
            ':',
            style: TextStyle(
              color: LawrenceTheme.surfaceTile1,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12), // offset label height
        ],
      ),
    );
  }
}
