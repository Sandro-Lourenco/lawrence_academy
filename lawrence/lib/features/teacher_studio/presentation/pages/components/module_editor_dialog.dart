import 'package:flutter/material.dart';
import '../../../../../design_system/tokens/lawrence_theme.dart';

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (c) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: LawrenceColors.canvas,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: ModuleEditorDialog(
              initialTitle: title,
              initialOrder: order,
              initialDescription: description,
              initialStatus: status,
            ),
          ),
        ),
      );
    } else {
      return showDialog<Map<String, dynamic>>(
        context: context,
        builder: (c) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: LawrenceColors.canvas,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: LawrenceColors.borderMist),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: ModuleEditorDialog(
              initialTitle: title,
              initialOrder: order,
              initialDescription: description,
              initialStatus: status,
            ),
          ),
        ),
      );
    }
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
      text: widget.initialOrder?.toString() ?? '0',
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
        'order_index': int.tryParse(_orderController.text) ?? 0,
        'description': _descriptionController.text.trim(),
        'status': _status,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.initialTitle == null ? "Novo Módulo" : "Editar Módulo",
            style: const TextStyle(
              fontSize: 20,
              color: LawrenceColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: LawrenceColors.textPrimary),
            decoration: const InputDecoration(
              labelText: "Título do Módulo",
              labelStyle: TextStyle(color: LawrenceColors.textSecondary),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: LawrenceColors.primary, width: 2),
              ),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? "Título é obrigatório" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            maxLength: 1000,
            style: const TextStyle(color: LawrenceColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Descrição do módulo',
              labelStyle: TextStyle(color: LawrenceColors.textSecondary),
              hintText:
                  'Ex.: Fundamentos, ferramentas e preparação para os primeiros moldes.',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _orderController,
            style: const TextStyle(color: LawrenceColors.textPrimary),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Ordem (Ex: 0, 1, 2)",
              labelStyle: TextStyle(color: LawrenceColors.textSecondary),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return "Ordem é obrigatória";
              if (int.tryParse(v) == null) return "Deve ser numérico";
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Estado do módulo',
              labelStyle: TextStyle(color: LawrenceColors.textSecondary),
            ),
            items: const [
              DropdownMenuItem(value: 'draft', child: Text('Em construção')),
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
                  style: TextStyle(color: LawrenceColors.textSecondary),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LawrenceColors.primary,
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
    );
  }
}
