import 'package:flutter/material.dart';
import '../../widgets/studio_cinematic_background.dart';

class ModuleEditorDialog extends StatefulWidget {
  final String? initialTitle;
  final int? initialOrder;
  final String? initialDescription;
  final String? initialStatus;

  const ModuleEditorDialog({
    super.key,
    this.initialTitle,
    this.initialOrder,
    this.initialDescription,
    this.initialStatus,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String? title,
    int? order,
    String? description,
    String? status,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (c) => StudioModalBackdrop(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              24,
              16,
              24 + MediaQuery.viewInsetsOf(c).bottom,
            ),
            child: StudioModalPanel(
              width: 440,
              child: ModuleEditorDialog(
                initialTitle: title,
                initialOrder: order,
                initialDescription: description,
                initialStatus: status,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<ModuleEditorDialog> createState() => _ModuleEditorDialogState();
}

class _ModuleEditorDialogState extends State<ModuleEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _orderController;
  late TextEditingController _descriptionController;
  late String _status;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _orderController = TextEditingController(
      text: ((widget.initialOrder ?? 0) + 1).toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _status = widget.initialStatus ?? 'draft';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'order_index': (int.tryParse(_orderController.text) ?? 1) - 1,
        'description': _descriptionController.text.trim(),
        'status': _status,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _modalTheme(context),
      child: Material(
        color: Colors.transparent,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialTitle == null ? "Novo Módulo" : "Editar Módulo",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Título do Módulo",
                  labelStyle: TextStyle(color: Color(0xFFB8C1DD)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA63B5E), width: 2),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Título é obrigatório"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 1000,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Descrição do módulo',
                  labelStyle: TextStyle(color: Color(0xFFB8C1DD)),
                  hintText:
                      'Ex.: Fundamentos, ferramentas e preparação para os primeiros moldes.',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Ordem (começa em 1)",
                  labelStyle: TextStyle(color: Color(0xFFB8C1DD)),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Ordem é obrigatória";
                  }
                  if (int.tryParse(v) == null) return "Deve ser numérico";
                  if (int.parse(v) < 1) return "A ordem deve começar em 1";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Estado do módulo',
                  labelStyle: TextStyle(color: Color(0xFFB8C1DD)),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'draft',
                    child: Text('Em construção'),
                  ),
                  DropdownMenuItem(
                    value: 'ready',
                    child: Text('Pronto para revisão'),
                  ),
                ],
                onChanged: (value) => _status = value ?? 'draft',
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Color(0xFFB8C1DD)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B1328),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      widget.initialTitle == null ? "Criar" : "Salvar",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ThemeData _modalTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: const Color(0xFFA63B5E),
        surface: const Color(0xFF2C111B),
        onSurface: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xB20A1022),
        labelStyle: const TextStyle(color: Color(0xFFB8C1DD)),
        hintStyle: const TextStyle(color: Color(0xFF7885A5)),
        counterStyle: const TextStyle(color: Color(0xFF8F9AB7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x406B4A55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFA63B5E), width: 2),
        ),
      ),
    );
  }
}
