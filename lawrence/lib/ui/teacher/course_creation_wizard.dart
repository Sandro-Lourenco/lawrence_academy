import 'package:flutter/material.dart';
import '../theme.dart';

class CourseCreationWizard extends StatefulWidget {
  const CourseCreationWizard({super.key});

  @override
  State<CourseCreationWizard> createState() => _CourseCreationWizardState();
}

class _CourseCreationWizardState extends State<CourseCreationWizard> {
  int _currentStep = 0;
  
  // Passo 1: Informações Básicas
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  String _category = "Modelagem";
  String _level = "Iniciante";

  // Passo 2: Grade Curricular (Reorderable List)
  final List<String> _lessons = [
    "1. Introdução à Linha de Fio e Ourela",
    "2. Marcação da Altura de Busto",
    "3. Traçado Lateral da Pense de Cintura",
    "4. Margens de Costura e Chuleado",
  ];

  // Passo 3: Upload de Mídia
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  void _simulateUpload() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _uploadProgress = i * 0.1;
      });
    }

    setState(() {
      _isUploading = false;
      _uploadedFileName = "aula_pense_busto_raw.mp4";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criador de Cursos (Wizard)", style: TextStyle(fontFamily: 'Outfit', fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: LiquidTheme.background,
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            // Finalizar e salvar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Curso salvo e enviado para a pipeline HLS com sucesso!")),
            );
            Navigator.of(context).pop();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          // Passo 1: Informações Básicas
          Step(
            isActive: _currentStep >= 0,
            title: const Text("Básico", style: TextStyle(fontSize: 12)),
            content: _buildStepBasicInfo(),
          ),
          
          // Passo 2: Grade Curricular (Reorderable List)
          Step(
            isActive: _currentStep >= 1,
            title: const Text("Currículo", style: TextStyle(fontSize: 12)),
            content: _buildStepCurriculum(),
          ),

          // Passo 3: Upload de Mídia
          Step(
            isActive: _currentStep >= 2,
            title: const Text("Mídia", style: TextStyle(fontSize: 12)),
            content: _buildStepMediaUpload(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBasicInfo() {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              labelText: "Título do Curso",
              labelStyle: TextStyle(color: Colors.white60),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _slugController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              labelText: "Slug (URL amigável)",
              labelStyle: TextStyle(color: Colors.white60),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _category,
            dropdownColor: LiquidTheme.surface,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              labelText: "Categoria",
              labelStyle: TextStyle(color: Colors.white60),
              border: OutlineInputBorder(),
            ),
            items: ["Modelagem", "Alfaiataria", "Costura"].map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _category = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepCurriculum() {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(16),
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ordene as aulas arrastando os blocos:",
            style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ReorderableListView(
              buildDefaultDragHandles: true,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _lessons.removeAt(oldIndex);
                  _lessons.insert(newIndex, item);
                });
              },
              children: _lessons.map((lesson) {
                return ListTile(
                  key: ValueKey(lesson),
                  leading: const Icon(Icons.drag_indicator, color: Colors.white30),
                  title: Text(lesson, style: const TextStyle(fontSize: 13, color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    onPressed: () {
                      setState(() {
                        _lessons.remove(lesson);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepMediaUpload() {
    return Container(
      decoration: LiquidTheme.glassDecoration(radius: 16),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Envio de Vídeo Bruto",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "O arquivo MP4 bruto enviado será processado de forma assíncrona na pipeline HLS.",
            style: TextStyle(fontSize: 12, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          if (_isUploading) ...[
            LinearProgressIndicator(value: _uploadProgress, color: LiquidTheme.primary, backgroundColor: Colors.white10),
            const SizedBox(height: 16),
            Text(
              "Enviando ao Supabase Storage... ${( _uploadProgress * 100).toInt()}%",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ] else if (_uploadedFileName != null) ...[
            const Icon(Icons.check_circle, color: LiquidTheme.secondary, size: 48),
            const SizedBox(height: 16),
            Text(
              "Upload concluído: $_uploadedFileName",
              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ] else ...[
            InkWell(
              onTap: _simulateUpload,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12, style: BorderStyle.values[1]), // tracejado simples
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: LiquidTheme.primary, size: 36),
                    SizedBox(height: 8),
                    Text(
                      "Clique ou Arraste o arquivo MP4 aqui",
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
