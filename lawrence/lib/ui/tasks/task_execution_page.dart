import 'package:flutter/material.dart';
import '../../presentation/form_controller.dart';
import '../theme.dart';

class TaskExecutionPage extends StatefulWidget {
  final String courseId;
  final String taskId;

  const TaskExecutionPage({
    super.key,
    required this.courseId,
    required this.taskId,
  });

  @override
  State<TaskExecutionPage> createState() => _TaskExecutionPageState();
}

class _TaskExecutionPageState extends State<TaskExecutionPage> {
  final _essayController = TextEditingController();
  String? _selectedOption;
  bool _isSubmitted = false;
  bool _isMultipleChoice = true; // Simulado para demonstração de ambos tipos

  // Feedback do Professor Simulado
  final double _score = 8.5;
  final String _feedback =
      "Muito boa execução do traçado lateral do blazer. Lembre-se de dar uma folga de vestibilidade de 1cm na cava nas próximas peças.";

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    setState(() {
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tarefa de Avaliação Prática",
          style: TextStyle(fontFamily: 'Outfit', fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: LiquidTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Alternador de demonstração de tipo de tarefa
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Simular Tipo:",
                      style: TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text(
                        "Múltipla Escolha",
                        style: TextStyle(fontSize: 10),
                      ),
                      selected: _isMultipleChoice,
                      onSelected: (val) {
                        setState(() {
                          _isMultipleChoice = true;
                          _isSubmitted = false;
                          _selectedOption = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text(
                        "Discursiva",
                        style: TextStyle(fontSize: 10),
                      ),
                      selected: !_isMultipleChoice,
                      onSelected: (val) {
                        setState(() {
                          _isMultipleChoice = false;
                          _isSubmitted = false;
                          _essayController.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Cartão com o enunciado
                Container(
                  decoration: LiquidTheme.glassDecoration(radius: 16),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ENUNCIADO DA TAREFA",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: LiquidTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isMultipleChoice
                            ? "Qual o viés angular ideal para realizar o corte de golas xale estruturadas para tecidos de alfaiataria em lã fria?"
                            : "Descreva o procedimento correto para fixação e fusão de entretelas tecidas na lapela de um blazer, incluindo temperatura, tempo e pressão ideais.",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Anatomia por Tipo de Tarefa
                if (_isMultipleChoice)
                  _buildMultipleChoiceInterface()
                else
                  _buildEssayInterface(),

                const SizedBox(height: 32),

                // 3. Teacher Feedback View (Se submetido)
                if (_isSubmitted) _buildTeacherFeedbackView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceInterface() {
    final options = {
      'A': 'Corte em ângulo de 45° exatos em relação ao fio reto.',
      'B': 'Corte em ângulo reto (90°) paralelo à ourela.',
      'C': 'Corte em viés leve de 15° para acomodação mecânica.',
      'D': 'Corte a 30° com costuras reforçadas no ombro.',
    };

    return Column(
      children: [
        ...options.entries.map((opt) {
          final isSelected = _selectedOption == opt.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: AnimatedScale(
              scale: isSelected ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: InkWell(
                onTap: _isSubmitted
                    ? null
                    : () {
                        setState(() {
                          _selectedOption = opt.key;
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? LiquidTheme.secondary.withOpacity(0.08)
                        : LiquidTheme.surface.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? LiquidTheme.secondary
                          : Colors.white10,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? LiquidTheme.secondary
                              : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            opt.key,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          opt.value,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: LiquidTheme.primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: _isSubmitted || _selectedOption == null
              ? null
              : _submitAnswer,
          child: const Text(
            "Enviar Resposta",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEssayInterface() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: LiquidTheme.glassDecoration(
            blurOpacity: 0.02,
            radius: 12,
          ),
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _essayController,
            maxLines: 8,
            readOnly: _isSubmitted,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.white,
            ), // Fonte em 17px conforme especificação
            decoration: const InputDecoration(
              hintText:
                  "Escreva sua resposta dissertativa aqui (mínimo de 6 linhas)...",
              hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: LiquidTheme.primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: _isSubmitted || _essayController.text.length < 20
              ? null
              : _submitAnswer,
          child: const Text(
            "Enviar Resposta Dissertativa",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherFeedbackView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC), // Fundo surface-pearl (#FAFAFC)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "AVALIAÇÃO DO PROFESSOR",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.black54,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0071E3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Nota: $_score",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0071E3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _feedback,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
