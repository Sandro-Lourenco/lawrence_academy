import 'package:flutter/material.dart';
import 'package:lawrence/core/theme.dart';

class ModuleEditorDialog extends StatefulWidget {
  final String? initialTitle;
  final int? initialOrder;

  const ModuleEditorDialog({super.key, this.initialTitle, this.initialOrder});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String? title,
    int? order,
  }) {
    // Retorna os dados se for salvo, ou nulo se cancelar
    // Responsive: BottomSheet on Mobile, Dialog on Desktop
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
              color: LiquidTheme.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: ModuleEditorDialog(initialTitle: title, initialOrder: order),
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
            decoration: LiquidTheme.glassDecoration(radius: 24),
            padding: const EdgeInsets.all(32),
            child: ModuleEditorDialog(initialTitle: title, initialOrder: order),
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _orderController = TextEditingController(
      text: widget.initialOrder?.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'order_index': int.tryParse(_orderController.text) ?? 0,
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
              labelStyle: TextStyle(color: Colors.white60),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: LiquidTheme.primary),
              ),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? "Título é obrigatório" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _orderController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Ordem (Ex: 0, 1, 2)",
              labelStyle: TextStyle(color: Colors.white60),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return "Ordem é obrigatória";
              if (int.tryParse(v) == null) return "Deve ser numérico";
              return null;
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LiquidTheme.primary,
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
