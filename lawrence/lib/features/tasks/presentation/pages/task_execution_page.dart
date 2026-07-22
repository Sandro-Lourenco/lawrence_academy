import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note: You would normally inject the repository properly via a provider.
// For this scaffolding, we assume a provider `taskExecutionControllerProvider` exists.

class TaskExecutionPage extends ConsumerStatefulWidget {
  final String lessonId;
  final String courseId;

  const TaskExecutionPage({
    super.key,
    required this.lessonId,
    required this.courseId,
  });

  @override
  ConsumerState<TaskExecutionPage> createState() => _TaskExecutionPageState();
}

class _TaskExecutionPageState extends ConsumerState<TaskExecutionPage> {
  // This would ideally come from the global provider.
  // late final provider = taskExecutionControllerProvider(widget.lessonId);

  @override
  void initState() {
    super.initState();
    // Load tasks on init
    // ref.read(provider.notifier).loadTasks(widget.lessonId, widget.courseId);
  }

  Future<bool> _onWillPop() async {
    // Show warning if there are unsaved drafts
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text(
              'You have unsaved answers. Do you really want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(provider);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Atividades')),
        body: const Center(
          child: Text(
            'Task Execution Page Scaffold. (Requires Provider Setup)',
          ),
        ),
      ),
    );
  }
}
